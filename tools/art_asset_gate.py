"""Inspect proposed exports before promotion; never modifies or crops images."""
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image

def inspect(path, expected_size=None, palette_limit=32):
    # In-memory fixtures let the same checks run without filesystem side effects.
    data = path.getvalue() if hasattr(path, "getvalue") else Path(path).read_bytes()
    with Image.open(path) as source:
        image = source.convert("RGBA")
    pixels = list(image.get_flattened_data() if hasattr(image, "get_flattened_data") else image.getdata())
    visible = {pixel for pixel in pixels if pixel[3]}
    alpha = {pixel[3] for pixel in pixels}
    errors = []
    if expected_size and image.size != tuple(expected_size):
        errors.append("frame_size_mismatch")
    if not visible:
        errors.append("empty_image")
    if len(visible) > palette_limit:
        errors.append("palette_exceeds_limit")
    if alpha - {0, 255}:
        errors.append("partial_alpha_requires_cleanup")
    if 0 not in alpha:
        errors.append("no_transparent_background")
    return {"file": "memory_fixture" if hasattr(path, "getvalue") else str(path), "sha256": hashlib.sha256(data).hexdigest(),
            "size": list(image.size), "alpha_bbox": image.getchannel("A").getbbox(),
            "visible_colors": len(visible), "partial_alpha": bool(alpha - {0, 255}),
            "errors": errors, "technical_export_pass": not errors,
            "human_acceptance": "pending", "rights_clearance": "pending"}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+", type=Path)
    parser.add_argument("--frame", nargs=2, type=int)
    parser.add_argument("--palette-limit", type=int, default=32)
    args = parser.parse_args()
    result = [inspect(path, args.frame, args.palette_limit) for path in args.files]
    print(json.dumps(result, indent=2))
    # Technical pass cannot establish provenance, licensing or cultural approval.
    raise SystemExit(any(item["errors"] for item in result))
