"""Read-only audit of saved candidates, independently from the authoring code."""
import hashlib
import io
import json
import sys
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET
from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sys.path.insert(0,str(ROOT / "tools"))
from art_asset_gate import inspect


def read(path):
    with Image.open(path) as source:
        return source.convert("RGBA")


def combine(folder, excluded=()):
    merged = Image.new("RGBA",(128,128))
    for path in sorted(folder.glob("*.png")):
        if path.stem not in excluded:
            # For bounding boxes only, union alpha; no claim about stacking order.
            merged.alpha_composite(read(path))
    return merged


def main():
    manifest = json.loads((HERE / "MANIFEST.json").read_text(encoding="utf-8"))
    for record in manifest["files"]:
        assert hashlib.sha256((HERE / record["file"]).read_bytes()).hexdigest() == record["sha256"], record["file"]
    exports = [record["file"] for record in manifest["exports"]]
    images = {name:read(HERE / name) for name in exports}
    gates = [inspect(HERE / name,(128,128),32) for name in exports]
    assert all(record["technical_export_pass"] for record in gates)
    body = combine(HERE / "layers/protagonist",("hair_six_clusters","carried_axe","body_measurement_mask"))
    bb = body.getchannel("A").getbbox()
    assert bb[3]-bb[1] == 52 and bb[2]-bb[0] <= 32 and bb[3]-1 == 90
    assert body.getchannel("A").tobytes() == read(HERE / "layers/protagonist/body_measurement_mask.png").getchannel("A").tobytes()
    hair = read(HERE / "layers/protagonist/hair_six_clusters.png")
    hb = hair.getchannel("A").getbbox()
    assert (hb[2]-hb[0],hb[3]-hb[1]) == (18,20)
    head = read(HERE / "layers/axe_neutral/head.png")
    handle = read(HERE / "layers/axe_neutral/handle.png")
    ab, sb = head.getchannel("A").getbbox(),handle.getchannel("A").getbbox()
    assert (ab[2]-ab[0],ab[3]-ab[1]) == (32,18) and sb[3]-sb[1] == 48
    assert head.tobytes() == head.transpose(Image.Transpose.FLIP_LEFT_RIGHT).tobytes()
    pivot = ((ab[0]+ab[2]-1)/2,(ab[1]+ab[3]-1)/2)
    assert list(pivot) == manifest["axe"]["rotation_pivot"]
    turned = Image.new("RGBA",(128,128))
    neutral = images["weapon_double_axe_neutral_candidate_01.png"]
    for y in range(128):
        for x in range(128):
            value = neutral.getpixel((x,y))
            if value[3]:
                destination = (int(pivot[0]+pivot[1]-y),int(pivot[1]-pivot[0]+x))
                assert 0 <= destination[0] < 128 and 0 <= destination[1] < 128
                turned.putpixel(destination,value)
    assert turned.tobytes() == images["weapon_double_axe_rotation_90_candidate_01.png"].tobytes()
    carried = Image.new("RGBA",(128,128))
    carried.alpha_composite(turned,tuple(manifest["protagonist"]["carry_translation"]))
    assert carried.tobytes() == read(HERE / "layers/protagonist/carried_axe.png").tobytes()
    for marker, expected in [("neutral_grip","left_grip"),("neutral_secondary_grip","right_grip")]:
        x,y = manifest["axe"][marker]
        tx,ty = manifest["protagonist"]["carry_translation"]
        assert [pivot[0]+pivot[1]-y+tx,pivot[1]-pivot[0]+x+ty] == manifest["protagonist"][expected]
    union = set().union(*({pixel[:3] for pixel in image.get_flattened_data() if pixel[3]} for image in images.values()))
    assert len(union) == manifest["shared_palette"]["visible_color_count"] <= 32
    for stem, export in [("protagonist",exports[0]),("axe_neutral",exports[1]),("axe_rotation_90",exports[2])]:
        with zipfile.ZipFile(HERE / f"{stem}.ora") as archive:
            assert archive.read("mimetype") == b"image/openraster"
            restored = Image.new("RGBA",(128,128))
            stack = ET.fromstring(archive.read("stack.xml")).find("stack")
            for layer in reversed(list(stack)):
                restored.alpha_composite(read(io.BytesIO(archive.read(layer.attrib["src"]))))
            assert restored.tobytes() == images[export].tobytes()
    large = read(HERE / "previews/scale_board_1280x720.png")
    small = read(HERE / "previews/scale_board_640x360.png")
    assert large.size == (1280,720) and small.size == (640,360)
    assert large.resize((640,360),Image.Resampling.NEAREST).tobytes() == small.tobytes()
    print(json.dumps({"saved_files_sha256":"pass","basic_export_gate":"pass",
        "body_size":[bb[2]-bb[0],bb[3]-bb[1]],"sole_row":bb[3]-1,
        "hair_envelope":[hb[2]-hb[0],hb[3]-hb[1]],"head_size":[32,18],
        "handle_rows":48,"quarter_turn":"pixel_exact_pass","carry_grips":"pass",
        "shared_visible_colors":len(union),"ora_recomposition":"pass",
        "scale_board_nearest_2_to_1":"pass","human_visual_acceptance":manifest["gate"]["visual_fidelity"]},indent=2))


if __name__ == "__main__":
    main()
