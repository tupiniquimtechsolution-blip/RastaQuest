"""Read-only prototype checks. Passing never authorizes final sprites or release."""
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parent


def pixels(image):
    return image.get_flattened_data() if hasattr(image, "get_flattened_data") else image.getdata()


def inspect_images(images):
    errors = []
    visible_colors = set()
    targets = [f"player_idle_{i:02}.png" for i in range(1, 5)]
    targets += [f"body_idle_{i:02}.png" for i in range(1, 5)]
    targets += ["weapon_double_axe_vertical_01.png", "weapon_double_axe_rotation_90_01.png",
                "weapon_double_axe_carried_01.png", "layers/axe_head.png", "layers/axe_shaft.png",
                "layers/body_neutral.png", "layers/weapon_in_hand.png", "layers/blades_in_hand.png",
                "layers/grip_occlusion.png"]
    if any(name not in images for name in targets):
        return {"prototype_integrity_pass": False, "errors": ["missing_required_image"], "automatic_approval": False}
    for name in targets:
        image = images[name]
        if image.size != (256, 256):
            errors.append(name + ":frame_size")
        values = list(pixels(image))
        visible_colors.update(p for p in values if p[3])
        if any(p[3] not in (0, 255) for p in values):
            errors.append(name + ":partial_alpha")
        if not any(p[3] == 0 for p in values) or not any(p[3] for p in values):
            errors.append(name + ":empty_or_opaque")
    if len(visible_colors) > 32:
        errors.append("shared_palette_exceeds32")
    if errors:
        return {"prototype_integrity_pass": False, "errors": errors, "automatic_approval": False}
    head, shaft = images["layers/axe_head.png"], images["layers/axe_shaft.png"]
    if head.getchannel("A").getbbox() != (96, 46, 160, 82):
        errors.append("head_visible_bounds_not64x36")
    if shaft.getchannel("A").getbbox() != (121, 64, 135, 160):
        errors.append("shaft_visible_height_not96")
    if head.crop((96, 46, 160, 82)).tobytes() != head.crop((96, 46, 160, 82)).transpose(Image.Transpose.FLIP_LEFT_RIGHT).tobytes():
        errors.append("head_not_symmetric")
    vertical = images["weapon_double_axe_vertical_01.png"]
    if vertical.tobytes() != Image.alpha_composite(shaft, head).tobytes():
        errors.append("weapon_does_not_match_layers")
    if images["weapon_double_axe_rotation_90_01.png"].tobytes() != vertical.transpose(Image.Transpose.ROTATE_270).tobytes():
        errors.append("rotation_not_rigid_quarter_turn")
    fixed_feet = images["body_idle_01.png"].crop((0, 160, 256, 256)).tobytes()
    body_hashes = set()
    blades = images["layers/blades_in_hand.png"].getchannel("A")
    weapon = images["layers/weapon_in_hand.png"]
    fist = images["layers/grip_occlusion.png"]
    for i in range(1, 5):
        actor, combined = images[f"body_idle_{i:02}.png"], images[f"player_idle_{i:02}.png"]
        body_hashes.add(hashlib.sha256(actor.tobytes()).hexdigest())
        if actor.crop((0, 160, 256, 256)).tobytes() != fixed_feet:
            errors.append(f"idle{i}:feet_drift")
        if actor.getchannel("A").getbbox()[3] != 180:
            errors.append(f"idle{i}:feet_edge_not180")
        if actor.getpixel((111, 132))[3] != 255:
            errors.append(f"idle{i}:grip_not_on_hand")
        if ImageChops.multiply(actor.getchannel("A"), blades).getbbox() is not None:
            errors.append(f"idle{i}:blade_body_overlap")
        expected = Image.alpha_composite(Image.alpha_composite(actor, weapon), fist)
        if expected.tobytes() != combined.tobytes():
            errors.append(f"idle{i}:layer_composition_mismatch")
    if len(body_hashes) != 3:
        errors.append("idle_not_three_distinct_rig_poses")
    return {"prototype_integrity_pass": not errors, "errors": errors,
            "shared_visible_colors": len(visible_colors), "timeline_keys": 4, "unique_rig_poses": len(body_hashes),
            "actual_drawn_poses": 1, "automatic_approval": False,
            "scope": "prototype integrity only; not final anatomy, animation quality, rights, cultural or device acceptance"}


def load_images(root=ROOT):
    manifest = json.loads((root / "MANIFEST.json").read_text(encoding="utf-8"))
    images = {}
    for record in manifest["files"]:
        path = root / record["file"]
        if hashlib.sha256(path.read_bytes()).hexdigest() != record["sha256"]:
            raise ValueError("File hash differs: " + record["file"])
        with Image.open(path) as source:
            images[record["file"]] = source.convert("RGBA")
    return images


if __name__ == "__main__":
    result = inspect_images(load_images())
    (ROOT / "VERIFICATION.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result["prototype_integrity_pass"] else 1)
