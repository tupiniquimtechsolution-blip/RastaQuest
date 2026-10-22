"""Experimental density proof from a new study; never an approved production export.

Uses the previously requested Python reconstruction workflow. This is explicit
resampling and fixed-palette mapping, not a claim that ImageGen authored native art.
"""
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent
SOURCE_SHA = "ea6a8415cdd2c5fad711ded0506e6be6850963f0cc129eaa3b7d6c16710112ad"
# Deliberately selected working ramps; not extracted automatically or owner-locked.
PALETTE = ["111014", "211719", "382326", "50302c", "6c4234", "8d543b",
           "b16c47", "d78c58", "352c2f", "554547", "80614d", "ad8967",
           "e0cba0", "fff0ca", "631c27", "a82a2b", "df3e2d", "ff6c38",
           "55351d", "8c531b", "c58a24", "f3bd35", "ffe873", "152e25",
           "28503a", "447045", "76914d", "30313c", "555865", "83838f",
           "b8b5bf", "eeecec"]


def main():
    path = ROOT / "protagonist-generated-study.png"
    if hashlib.sha256(path.read_bytes()).hexdigest() != SOURCE_SHA:
        raise ValueError("Study bytes differ from recorded source")
    source = Image.open(path).convert("RGBA")
    # Explicit estimated landmarks on the study; not native anatomical validation.
    crown, sole, axis_x = 252, 1216, 620
    ratio = 104 / (sole - crown)
    reduced = source.resize((round(source.width * ratio), round(source.height * ratio)), Image.Resampling.BOX)
    colors = [tuple(bytes.fromhex(value)) for value in PALETTE]
    palette_image = Image.new("P", (1, 1))
    palette_image.putpalette([n for c in colors for n in c] + list(colors[-1]) * (256 - len(colors)))
    indexed = reduced.convert("RGB").quantize(palette=palette_image, dither=Image.Dither.NONE)
    mapped = indexed.convert("RGBA")
    mask = reduced.getchannel("A").point(lambda value: 255 if value >= 160 else 0)
    mapped.putalpha(mask)
    canvas = Image.new("RGBA", (256, 256))
    canvas.paste(mapped, (128 - round(axis_x * ratio), 180 - round(sole * ratio)))
    out = ROOT / "protagonist-density-proof-256.png"
    canvas.save(out)
    # Review artifact only: original candidate pixels enlarged with nearest-neighbor.
    board = Image.new("RGB", (1200, 820), "#142024")
    from PIL import ImageDraw
    draw = ImageDraw.Draw(board)
    draw.rectangle((610, 70, 1190, 680), fill="#f2eee3")
    enlarged = canvas.resize((1024, 1024), Image.Resampling.NEAREST)
    crop = enlarged.crop((280, 180, 800, 760))
    board.paste(crop, (40, 90), crop)
    board.paste(crop, (640, 90), crop)
    draw.text((36, 22), "RASTA QUEST | 2x density experiment | NOT FINAL", fill="#f0cc77")
    draw.text((36, 700), "256x256 PNG / 32 colors / binary alpha / world scale 0.5", fill="#f0cc77")
    draw.text((36, 725), "Model, palette, anatomy, rigid axe and clips: pending", fill="#eef0e5")
    # At world size, canvas128 and intended body52; no gameplay scene is implied.
    thumb = canvas.resize((128, 128), Image.Resampling.NEAREST)
    board.paste(thumb, (980, 680), thumb)
    draw.text((36, 765), "Bottom right: same intended game size. Not a Godot/Android capture.", fill="#c5cec2")
    board.save(ROOT / "REVIEW_BOARD.png")
    record = {"classification": "EXPERIMENTAL_DENSITY_PROOF_NOT_FINAL", "source_sha256": SOURCE_SHA,
              "method": "BOX reduction, manually selected32-color palette mapping, alpha threshold160; no dithering",
              "source_landmarks_estimated": {"crown_y": crown, "sole_y": sole, "axis_x": axis_x},
              "frame": [256, 256], "origin": [128, 128], "intended_feet_y": 180,
              "intended_body_height": 104, "constant_visual_scale": 0.5,
              "palette_hex": PALETTE, "model_lock": "PENDING", "palette_lock": "PENDING",
              "anatomy_grip_rigid_axe": "NOT_VERIFIED", "owner_visual_acceptance": "PENDING",
              "rights_clearance": "PENDING", "clips": "NOT_AUTHORED", "runtime_promotion": False,
              "output_sha256": hashlib.sha256(out.read_bytes()).hexdigest()}
    (ROOT / "DENSITY_PROOF.json").write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
