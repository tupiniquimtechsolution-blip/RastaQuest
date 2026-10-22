"""Layered authoring prototype: fixed rigid weapon + explicitly rigged idle.

Not final production art; no gameplay imports or acceptance flags are written.
"""
import hashlib
import importlib.util
import json
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("density_source", ROOT.parent / "model-2x/build_density_proof.py")
density = importlib.util.module_from_spec(spec)
spec.loader.exec_module(density)
PALETTE = density.PALETTE


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def palette_map(source):
    palette = Image.new("P", (1, 1))
    colors = [tuple(bytes.fromhex(value)) for value in PALETTE]
    palette.putpalette([n for c in colors for n in c] + list(colors[-1]) * (256 - len(colors)))
    result = source.convert("RGB").quantize(palette=palette, dither=Image.Dither.NONE).convert("RGBA")
    result.putalpha(source.getchannel("A").point(lambda n: 255 if n >= 160 else 0))
    clean = Image.new("RGBA", result.size)
    clean.paste(result, (0, 0), result.getchannel("A"))
    return clean


def save(image, name):
    path = ROOT / name
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path)
    return {"file": name, "sha256": sha(path)}


def build():
    sources = {}
    for name in ("axe-generated-source.png", "idle-generated-attempt-01.png", "idle-body-correction-source.png"):
        path = ROOT / name
        sources[name] = {"sha256": sha(path), "size": list(Image.open(path).size)}
    expected_sources = {
        "axe-generated-source.png": "cf72ab5e9ce5c03b4e274e6daf23548da9645aded38b54a9b37bdc373408dd09",
        "idle-generated-attempt-01.png": "d996bccade1fb568f64452031ea4b81ffd4376073017a246f51ed903f3e84269",
        "idle-body-correction-source.png": "77d212a06db0a6165708a50dd81069d556c652b8ee8e80a58cec7cee68949903",
    }
    for name, digest in expected_sources.items():
        if sources[name]["sha256"] != digest:
            raise ValueError("Unexpected source: " + name)
    axe_source = Image.open(ROOT / "axe-generated-source.png").convert("RGBA")
    # Explicit layer reconstruction to the dimensional contract; head and shaft
    # have separate scale factors. This is not a claim of native hand cleanup.
    head = palette_map(axe_source.crop((378, 182, 873, 517)).resize((64, 36), Image.Resampling.BOX))
    left = head.crop((0, 0, 32, 36))
    symmetric = Image.new("RGBA", (64, 36))
    symmetric.paste(left, (0, 0))
    symmetric.paste(left.transpose(Image.Transpose.FLIP_LEFT_RIGHT), (32, 0))
    # Reconstruct the two outer edge columns at the native grid. BOX reduction
    # otherwise leaves a one-pixel transparent margin (visible width62, not64).
    for y in range(36):
        if symmetric.getpixel((1, y))[3]:
            symmetric.putpixel((0, y), symmetric.getpixel((1, y)))
            symmetric.putpixel((63, y), symmetric.getpixel((62, y)))
    shaft = palette_map(axe_source.crop((571, 345, 685, 1108)).resize((14, 96), Image.Resampling.BOX))
    shaft_left = shaft.crop((0, 0, 7, 96))
    shaft = Image.new("RGBA", (14, 96))
    shaft.paste(shaft_left, (0, 0))
    shaft.paste(shaft_left.transpose(Image.Transpose.FLIP_LEFT_RIGHT), (7, 0))
    head_layer = Image.new("RGBA", (256, 256))
    shaft_layer = Image.new("RGBA", (256, 256))
    head_layer.paste(symmetric, (96, 46))
    shaft_layer.paste(shaft, (121, 64))
    vertical = Image.alpha_composite(shaft_layer, head_layer)
    horizontal = vertical.transpose(Image.Transpose.ROTATE_270)
    carried = horizontal.rotate(-12, resample=Image.Resampling.NEAREST, center=(128, 128))
    files = [save(head_layer, "layers/axe_head.png"), save(shaft_layer, "layers/axe_shaft.png"),
             save(vertical, "weapon_double_axe_vertical_01.png"),
             save(horizontal, "weapon_double_axe_rotation_90_01.png"),
             save(carried, "weapon_double_axe_carried_01.png")]
    head_carried = head_layer.transpose(Image.Transpose.ROTATE_270).rotate(-12, resample=Image.Resampling.NEAREST, center=(128, 128))

    sheet = Image.open(ROOT / "idle-body-correction-source.png").convert("RGBA")
    # Use only the first newly authored unarmed neutral: the other generated
    # cells drift. The prototype is instead a declared3-pose layered breathing rig.
    ratio = 104 / (584 - 134)
    first = sheet.crop((0, 0, 627, 627))
    first = palette_map(first.resize((round(627 * ratio), round(627 * ratio)), Image.Resampling.BOX))
    body = Image.new("RGBA", (256, 256))
    body.paste(first, (128 - round(320 * ratio), 180 - round(584 * ratio)))
    upper = Image.new("RGBA", (256, 256))
    upper.paste(body.crop((0, 0, 256, 118)), (0, 0))
    lower = Image.new("RGBA", (256, 256))
    lower.paste(body.crop((0, 116, 256, 256)), (0, 116))
    files.extend([save(body, "layers/body_neutral.png"), save(upper, "layers/body_upper.png"),
                  save(lower, "layers/body_lower.png")])
    atlas = Image.new("RGBA", (1024, 256))
    frames, review = [], []
    grip = (111, 132)
    weapon = Image.new("RGBA", (256, 256))
    weapon.paste(carried, (grip[0] - 128, grip[1] - 128))
    blades = Image.new("RGBA", (256, 256))
    blades.paste(head_carried, (grip[0] - 128, grip[1] - 128))
    fist = Image.new("RGBA", (256, 256))
    fist.paste(body.crop((100, 126, 113, 143)), (100, 126))
    files.extend([save(weapon, "layers/weapon_in_hand.png"), save(blades, "layers/blades_in_hand.png"),
                  save(fist, "layers/grip_occlusion.png")])
    for index, lift in enumerate((0, 1, 2, 1), 1):
        torso = Image.new("RGBA", (256, 256))
        torso.paste(upper, (0, -lift))
        actor = Image.alpha_composite(torso, lower)
        combined = Image.alpha_composite(actor, weapon)
        # Explicit grip occlusion layer: keep the fist in front of the shaft.
        combined = Image.alpha_composite(combined, fist)
        files.append(save(actor, f"body_idle_{index:02}.png"))
        files.append(save(combined, f"player_idle_{index:02}.png"))
        atlas.paste(combined, ((index - 1) * 256, 0))
        frames.append({"file": f"player_idle_{index:02}.png", "duration_ms": 200, "upper_lift": lift,
                       "origin": [128, 128], "feet_edge_y": 180, "weapon_grip": list(grip)})
        background = Image.new("RGBA", (256, 256), "#142024")
        background.alpha_composite(combined)
        review.append(background.convert("RGB").resize((768, 768), Image.Resampling.NEAREST))
    files.append(save(atlas, "player_idle_atlas.png"))
    review[0].save(ROOT / "IDLE_REVIEW.gif", save_all=True, append_images=review[1:],
                   duration=200, loop=0, optimize=False)
    board = Image.new("RGB", (1200, 790), "#142024")
    draw = ImageDraw.Draw(board)
    for index, name in enumerate(("weapon_double_axe_vertical_01.png", "weapon_double_axe_rotation_90_01.png")):
        image = Image.open(ROOT / name).convert("RGBA").resize((768, 768), Image.Resampling.NEAREST)
        board.paste(image, (index * 540 - 110, -40), image)
    draw.text((35, 720), "RIGID AXE PROTOTYPE | quarter-turn uses identical pixels | NOT FINAL", fill="#e9cc83")
    draw.text((35, 747), "256x256 / origin128,128 / head64x36 and shaft96 authoring regions", fill="#d7e1d4")
    board.save(ROOT / "AXE_REVIEW.png")
    record = {"classification": "LAYERED_AUTHORING_PROTOTYPE_NOT_FINAL", "sources": sources,
              "appearance_target": {"sha256": "dd9cfe1bdf99a75a17e0a6e7de0c5322de7a13c70408b43ff872b97bcbe3fa57",
                                   "owner_decision": "Use this visual as base; not weapon/clip/final acceptance"},
              "method": "ImageGen sources; explicit head/shaft reconstruction with independent resize factors, mirror symmetry and two native blade-edge columns; fixed palette/binary alpha; exact quarter-turn; three-pose upper-body translation rig",
              "palette_hex": PALETTE, "frame": [256, 256], "scale": 0.5,
              "weapon": {"head_authoring_rect": [96, 46, 160, 82], "shaft_authoring_rect": [121, 64, 135, 160],
                         "head_center": [128, 64], "grip": [128, 128], "markers": "edge coordinates; pixel-index rotation is255-y,x",
                         "quarter_turn": "clockwise90; exact transpose of vertical PNG", "carried": "102degrees clockwise total; nearest sampling"},
              "idle": {"timeline_keys": 4, "unique_rig_poses": 3, "authored_drawn_pose_count": 1,
                       "duration_ms": 800, "frames": frames, "lower_body_and_grip": "fixed",
                       "source_sheet_other_cells": "rejected for geometry/stance drift",
                       "not_hand_drawn_four_pose_animation": True},
              "model_geometry": "PENDING", "palette_lock": "PENDING_IN_ROOM", "animation_acceptance": "PENDING",
              "weapon_visual_acceptance": "PENDING", "rights_clearance": "PENDING",
              "runtime_promotion": False, "remaining_body_clips": ["run", "jump", "fall", "attack_axe", "attack_axe_air", "hurt", "death"],
              "files": files}
    (ROOT / "MANIFEST.json").write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    build()
