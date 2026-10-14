"""Native pixel candidate authorized by Rodrigo, 2026-10-14.

Authored coordinates, no tracing/quantizing/resizing of a reference into exports.
Only review composites resize images. Run from any directory with Pillow.
Sources and outputs stay here; never writes to game/assets.
"""
import hashlib
import io
import json
import sys
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

import PIL
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sys.path.insert(0, str(ROOT / "tools"))
from art_asset_gate import inspect

PROPOSAL = ROOT / "assets/production_drafts/2026-10-10/native-authoring-kit/PALETTE_PROPOSAL.json"
REFERENCE = ROOT / "assets/production_drafts/2026-10-10/model-v03/protagonist-neutral-study-v03.png"
PALETTE = json.loads(PROPOSAL.read_text(encoding="utf-8"))
C = {entry["id"]: tuple(bytes.fromhex(entry["hex"][1:])) + (255,)
     for entry in PALETTE["colors"]}
O = "hair_deep_outline"


def blank():
    return Image.new("RGBA", (128, 128))


def poly(layer, points, fill, outline=None):
    ImageDraw.Draw(layer).polygon(points, fill=C[fill], outline=C[outline] if outline else None)


def rect(layer, box, fill):
    ImageDraw.Draw(layer).rectangle(box, fill=C[fill])


def line(layer, points, fill, width=1):
    ImageDraw.Draw(layer).line(points, fill=C[fill], width=width)


def composite(layers):
    result = blank()
    for _, layer in layers:
        result.alpha_composite(layer)
    return result


def save_ora(name, layers):
    """Standard OpenRaster archive; bottom-to-top input, top-to-bottom XML."""
    xml = ET.Element("image", {"w": "128", "h": "128", "name": name, "version": "0.0.3"})
    stack = ET.SubElement(xml, "stack")
    with zipfile.ZipFile(HERE / name, "w") as archive:
        archive.writestr("mimetype", "image/openraster", compress_type=zipfile.ZIP_STORED)
        for index, (label, layer) in reversed(list(enumerate(layers))):
            src = f"data/layer{index:02}.png"
            ET.SubElement(stack, "layer", {"name": label, "src": src, "x": "0", "y": "0",
                "opacity": "1.0", "visibility": "visible", "composite-op": "svg:src-over"})
            buf = io.BytesIO()
            layer.save(buf, format="PNG")
            archive.writestr(src, buf.getvalue())
        buf = io.BytesIO()
        composite(layers).save(buf, format="PNG")
        archive.writestr("mergedimage.png", buf.getvalue())
        archive.writestr("stack.xml", ET.tostring(xml, encoding="utf-8", xml_declaration=True))


def make_axe():
    head, handle = blank(), blank()
    # Author left blade, then mirror pixels. 32x18 head, including dark edge.
    left = blank()
    poly(left, [(53,37),(50,39),(49,42),(48,45),(48,46),(49,49),
                (51,52),(53,54),(53,51),(55,48),(59,47),(62,47),
                (62,44),(59,44),(55,42),(53,39)], "blade_shadow", O)
    poly(left, [(53,38),(51,40),(50,43),(49,45),(49,47),(50,49),
                (52,52),(52,49),(54,46),(54,44),(52,42)], "blade_base")
    line(left, [(53,38),(51,40),(50,42),(49,45),(49,47),(50,49),(52,52),(53,53)], "blade_light")
    poly(left, [(53,43),(56,44),(60,45),(60,46),(56,46),(53,48)], "blade_base")
    line(left, [(54,44),(57,45),(60,45)], "blade_light")
    head.alpha_composite(left)
    head.alpha_composite(left.transpose(Image.Transpose.FLIP_LEFT_RIGHT))
    # Even-width hub is symmetric about x=63.5; geometric ornament only.
    draw = ImageDraw.Draw(head)
    draw.ellipse((60,42,67,49), fill=C[O])
    draw.ellipse((61,43,66,48), fill=C["gold_base"])
    draw.ellipse((62,44,65,47), fill=C["gold_shadow"])
    rect(head, (63,44,64,46), "gold_light")
    rect(head, (62,51,65,54), "gold_base")
    rect(head, (63,51,64,53), "gold_light")
    # Exactly 48 occupied pixel rows, y55..102 inclusive; grip region x62..65.
    rect(handle, (62,55,65,102), O)
    rect(handle, (63,56,64,100), "leather_wood_base")
    for y in (60,65,70,75,80,85,90,95):
        rect(handle, (63,y,64,y), "leather_wood_shadow")
    rect(handle, (61,55,66,57), "gold_shadow")
    rect(handle, (62,55,65,56), "gold_base")
    rect(handle, (63,55,64,55), "gold_light")
    rect(handle, (61,97,66,99), "gold_shadow")
    rect(handle, (62,97,65,98), "band_green")
    rect(handle, (60,100,67,101), O)
    rect(handle, (61,100,66,101), "gold_base")
    rect(handle, (62,102,65,102), "gold_shadow")
    return [("handle", handle), ("head", head)]


def clockwise_at_head(image):
    # Pixel-exact quarter turn about (63.5,45.5), not an interpolated rotation.
    output = blank()
    for y in range(128):
        for x in range(128):
            pixel = image.getpixel((x,y))
            if pixel[3]:
                xx, yy = 109-y, x-18
                if not (0 <= xx < 128 and 0 <= yy < 128):
                    raise ValueError("Quarter turn clips visible pixels")
                output.putpixel((xx,yy), pixel)
    return output


def make_protagonist(axe_horizontal):
    hair = blank()
    clusters = [
        [(48,35),(51,35),(58,39),(61,42),(59,44),(55,41),(50,39),(47,37)],
        [(45,38),(49,38),(55,40),(60,42),(59,45),(54,43),(48,42),(44,41),(44,39)],
        [(46,43),(51,42),(58,42),(60,44),(56,46),(50,47),(45,49),(44,47)],
        [(49,46),(53,44),(59,43),(60,46),(56,49),(50,52),(46,52),(46,50)],
        [(53,46),(57,44),(61,44),(59,48),(56,52),(52,54),(49,54),(50,51)],
        [(59,44),(61,45),(61,50),(60,53),(57,54),(55,53),(57,49)]
    ]
    for points in clusters:
        poly(hair, points, "hair_base", O)
    for points in [[(49,36),(51,36),(57,40)],[(45,40),(49,40),(55,42)],
                   [(46,46),(50,44),(55,44)],[(48,50),(53,47),(57,45)],
                   [(52,52),(55,49),(58,46)],[(58,52),(59,49),(60,46)]]:
        line(hair, points, "skin_shadow")

    anatomy = blank()
    # Side profile: readable nose, eye, beard and exposed neck.
    poly(anatomy, [(63,39),(70,39),(72,41),(73,43),(75,44),
                   (73,45),(73,47),(70,49),(67,49),(64,47),(62,44),(62,41)], "skin_shadow", O)
    poly(anatomy, [(66,42),(71,42),(72,43),(73,44),(71,45),(72,46),
                   (70,47),(67,46),(65,44)], "skin_base")
    rect(anatomy, (67,42,70,42), "skin_light")
    rect(anatomy, (69,43,72,43), O)
    rect(anatomy, (70,43,70,43), "cloth_light")
    rect(anatomy, (73,44,74,44), "skin_light")
    line(anatomy, [(67,46),(69,48),(72,47)], "skin_deep")
    poly(anatomy, [(64,48),(67,49),(70,49),(71,53),(66,54),(62,52)], "skin_base", O)
    poly(anatomy, [(65,49),(67,50),(68,52),(64,52)], "skin_light")
    # Rounded shoulder and descending forearm; hands are composited above weapon.
    poly(anatomy, [(58,52),(61,52),(64,54),(65,57),(63,61),(60,62),
                   (59,65),(57,69),(53,69),(52,66),(54,62),(54,57)], "skin_shadow", O)
    poly(anatomy, [(58,53),(61,53),(63,55),(63,57),(60,59),(57,58),(55,57)], "skin_base")
    poly(anatomy, [(58,53),(61,54),(62,56),(59,57),(56,56)], "skin_light")
    poly(anatomy, [(55,59),(58,60),(59,62),(57,65),(54,67),(54,64)], "skin_base")
    line(anatomy, [(55,62),(55,64),(54,66)], "skin_light")
    poly(anatomy, [(73,54),(75,55),(77,58),(77,62),(78,66),(77,70),(74,70),(73,65)], "skin_shadow", O)
    line(anatomy, [(75,56),(76,59),(75,62),(77,66)], "skin_base")

    pants = blank()
    poly(pants, [(58,65),(71,65),(74,68),(76,72),(75,77),(73,82),(67,83),
                (64,77),(61,82),(55,83),(53,80),(53,76),(55,70)], "pants_shadow", O)
    poly(pants, [(59,69),(63,68),(66,70),(64,75),(60,80),(56,81),(54,79),(55,75)], "pants_base")
    poly(pants, [(69,69),(72,70),(74,73),(72,78),(70,81),(68,81),(66,77)], "pants_base")
    line(pants, [(64,71),(63,74),(61,77)], "pants_shadow")
    line(pants, [(70,72),(68,76),(68,78)], "pants_shadow")

    cloth = blank()
    poly(cloth, [(61,51),(64,52),(67,55),(70,53),(73,54),(75,61),
                (74,65),(60,65),(59,61),(63,58),(64,55)], "cloth_shadow", O)
    poly(cloth, [(62,52),(64,53),(65,55),(69,56),(72,55),(72,60),
                (70,63),(61,64),(60,62),(65,59),(66,57)], "cloth_base")
    poly(cloth, [(62,52),(63,53),(64,55),(64,58),(61,61),(60,61),(61,57)], "cloth_light")
    poly(cloth, [(70,56),(72,56),(73,60),(71,62),(69,63),(68,61)], "cloth_light")
    line(cloth, [(62,52),(65,54),(68,56),(72,57)], "band_red")
    line(cloth, [(64,52),(66,53),(69,55),(72,55)], "band_green")
    # Broad leather strap follows the approved clothing, not a necklace.
    poly(cloth, [(71,56),(73,57),(71,60),(68,62),(63,65),(60,65),
                (62,63),(67,60)], "leather_wood_shadow", O)
    line(cloth, [(71,58),(69,60),(65,63),(62,64)], "leather_wood_base", 2)
    rect(cloth, (71,56,73,58), "gold_shadow")
    rect(cloth, (72,56,72,57), "gold_base")
    # Tunic sash in red, green and yellow; no sacred motif introduced.
    poly(cloth, [(59,65),(67,66),(64,72),(59,76),(54,75),(56,70)], "band_red", O)
    line(cloth, [(64,66),(62,71),(58,75),(54,74)], "band_yellow")
    line(cloth, [(65,67),(63,72),(59,76)], "band_green")
    poly(cloth, [(70,66),(72,66),(74,75),(71,75),(70,72)], "band_red", O)
    line(cloth, [(71,67),(72,72),(73,74)], "band_yellow")

    boots = blank()
    for points in [[(55,81),(61,81),(61,85),(60,87),(64,88),(65,90),
                    (53,90),(53,87),(54,84)],
                   [(68,81),(74,81),(74,85),(75,87),(79,88),(80,90),
                    (67,90),(67,87),(68,84)]]:
        poly(boots, points, "leather_wood_shadow", O)
    poly(boots, [(55,83),(60,83),(59,86),(56,87),(54,88),(54,85)], "leather_wood_base")
    poly(boots, [(69,83),(73,83),(72,86),(75,88),(78,89),(68,89),(68,87)], "leather_wood_base")
    line(boots, [(55,89),(61,89),(63,89)], "leather_wood_base")
    for box in [(55,82,61,83),(68,82,74,83),(56,87,60,88),(72,87,75,88)]:
        rect(boots, box, "gold_shadow")
        line(boots, [(box[0]+1,box[1]),(box[2]-1,box[1])], "gold_base")

    belt = blank()
    rect(belt, (59,64,74,66), O)
    rect(belt, (60,64,73,65), "leather_wood_base")
    rect(belt, (69,63,74,67), "gold_shadow")
    rect(belt, (70,63,74,66), "gold_base")
    rect(belt, (71,64,73,65), "leather_wood_shadow")

    band = blank()
    poly(band, [(62,41),(66,40),(70,39),(73,39),(73,42),(66,43),(63,44),(62,43)], O)
    line(band, [(63,41),(67,40),(70,39),(72,39)], "band_red")
    line(band, [(63,42),(67,41),(70,40),(72,40)], "band_yellow")
    line(band, [(63,43),(67,42),(70,41),(72,41)], "band_green")

    weapon = blank()
    # Carry head center (96.5,70.5); same rigid 90-degree art as isolated study.
    weapon.alpha_composite(axe_horizontal, (33,25))
    hands = blank()
    rect(hands, (53,66,58,68), "cloth_base")
    rect(hands, (53,66,58,66), "cloth_light")
    rect(hands, (53,68,58,68), "band_red")
    rect(hands, (53,69,58,69), "band_yellow")
    poly(hands, [(53,70),(58,70),(59,72),(57,74),(54,73),(53,72)], "skin_shadow", O)
    rect(hands, (54,70,57,72), "skin_base")
    rect(hands, (54,70,56,70), "skin_light")
    rect(hands, (74,66,77,67), "cloth_base")
    rect(hands, (74,68,77,68), "band_green")
    poly(hands, [(74,69),(77,69),(78,71),(77,73),(75,73),(74,72)], "skin_shadow", O)
    rect(hands, (75,70,77,71), "skin_base")
    return [("hair_six_clusters",hair),("anatomy",anatomy),("pants",pants),
            ("cloth_and_strap",cloth),("boots",boots),("belt",belt),
            ("headband",band),("carried_axe",weapon),("cuffs_and_hands",hands)], clusters


def rgba_pixels(image):
    return list(image.get_flattened_data())


def colors(image):
    return {pixel for pixel in rgba_pixels(image) if pixel[3]}


def write_layered(name, layers):
    folder = HERE / "layers" / name
    folder.mkdir(parents=True, exist_ok=True)
    for label, layer in layers:
        layer.save(folder / f"{label}.png")
    save_ora(f"{name}.ora", layers)


def make_reviews(hero, vertical, horizontal):
    previews = HERE / "previews"
    previews.mkdir(exist_ok=True)
    font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 18)
    small = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 14)
    for label, bg in [("dark",(22,29,36,255)),("light",(234,228,209,255))]:
        panel = Image.new("RGBA", (1080,660), bg)
        d = ImageDraw.Draw(panel)
        ink = (235,238,231) if label == "dark" else (36,42,47)
        d.text((24,16), "RASTA QUEST | Native Python v01 | RASCUNHO PARA REVISAO", font=font, fill=ink)
        d.text((24,44), "Pixels autorais 128x128; corpo 52px; sem aceite artistico ou integracao.", font=small, fill=ink)
        for x, asset, title in [(20,hero,"Protagonista - 4x nearest"),
                                (540,vertical,"Machado isolado - 4x nearest")]:
            d.text((x,82), title, font=font, fill=ink)
            panel.alpha_composite(asset.resize((512,512),Image.Resampling.NEAREST),(x,108))
        d.text((24,633), "Modelo e paleta pendentes | Sem colar / brinco / contas | Medicoes em MANIFEST.json",font=small,fill=ink)
        panel.convert("RGB").save(previews / f"native_review_4x_{label}.png")
        for name, asset in [("protagonist",hero),("axe_vertical",vertical),("axe_90",horizontal)]:
            preview = Image.new("RGBA", (128,128), bg)
            preview.alpha_composite(asset)
            preview.convert("RGB").save(previews / f"{name}_1x_{label}.png")

    # Reference is resized only for this review, never read by authoring functions.
    panel = Image.new("RGBA", (1140,580), (22,29,36,255))
    d = ImageDraw.Draw(panel)
    d.text((20,14), "Direcao v03 aprovada versus candidato nativo v01 (pendente)",font=font,fill="white")
    d.text((20,48), "Referencia de estudo reduzida para exibicao",font=small,fill="white")
    reference = Image.open(REFERENCE).convert("RGBA")
    reference.thumbnail((450,480),Image.Resampling.LANCZOS)
    panel.alpha_composite(reference,(20,78))
    d.text((530,48), "Novo desenho nativo - 4x nearest",font=small,fill="white")
    panel.alpha_composite(hero.resize((512,512),Image.Resampling.NEAREST),(510,64))
    panel.convert("RGB").save(previews / "reference_comparison.png")

    # Static measurement board, not environment art or an engine/device capture.
    scale = Image.new("RGBA", (1280,720), (22,29,36,255))
    draw = ImageDraw.Draw(scale)
    draw.rectangle((0,0,639,719),fill=(234,228,209,255))
    for x, ink in [(0,(36,42,47)),(640,(235,238,231))]:
        draw.text((x+24,24),"Escala estatica | 1 pixel = 1 unidade",font=font,fill=ink)
        draw.text((x+24,54),"Corpo 52 px / tile 32 px / frame 128 px",font=small,fill=ink)
        draw.line((x+24,421,x+615,421),fill=ink)
        for xx in range(x+32,x+609,32):
            draw.rectangle((xx,422,xx+31,453),outline=ink)
        scale.alpha_composite(hero,(x+256,330))
        draw.text((x+24,486),"Desenho nativo exibido a 1x; sem redimensionar o personagem.",font=small,fill=ink)
        draw.text((x+24,666),"Composicao de revisao; nao e captura Godot/Android.",font=small,fill=ink)
    scale.convert("RGB").save(previews / "scale_board_1280x720.png")
    scale.resize((640,360),Image.Resampling.NEAREST).convert("RGB").save(previews / "scale_board_640x360.png")


def main():
    expected_ref = PALETTE["reference_sha256"]
    assert hashlib.sha256(REFERENCE.read_bytes()).hexdigest() == expected_ref
    axe_layers = make_axe()
    vertical = composite(axe_layers)
    rotated_layers = [(name,clockwise_at_head(layer)) for name,layer in axe_layers]
    horizontal = composite(rotated_layers)
    hero_layers, clusters = make_protagonist(horizontal)
    hero = composite(hero_layers)
    exports = [("protagonist_neutral_candidate_01.png",hero),
               ("weapon_double_axe_neutral_candidate_01.png",vertical),
               ("weapon_double_axe_rotation_90_candidate_01.png",horizontal)]
    for name, image in exports:
        image.save(HERE / name)
    write_layered("protagonist",hero_layers)
    write_layered("axe_neutral",axe_layers)
    write_layered("axe_rotation_90",rotated_layers)
    body = composite([(name,layer) for name,layer in hero_layers
                      if name not in {"hair_six_clusters","carried_axe"}])
    body.save(HERE / "layers/protagonist/body_measurement_mask.png")
    body_bbox = body.getchannel("A").getbbox()
    hair_bbox = hero_layers[0][1].getchannel("A").getbbox()
    head_bbox = axe_layers[1][1].getchannel("A").getbbox()
    handle_bbox = axe_layers[0][1].getchannel("A").getbbox()
    # Check geometric facts independently of color/frame inspection.
    assert body_bbox[3]-body_bbox[1] == 52 and body_bbox[2]-body_bbox[0] <= 32
    assert body_bbox[3]-1 == 90
    assert (hair_bbox[2]-hair_bbox[0],hair_bbox[3]-hair_bbox[1]) == (18,20)
    assert (head_bbox[2]-head_bbox[0],head_bbox[3]-head_bbox[1]) == (32,18)
    assert handle_bbox[3]-handle_bbox[1] == 48
    assert axe_layers[1][1].tobytes() == axe_layers[1][1].transpose(Image.Transpose.FLIP_LEFT_RIGHT).tobytes()
    # Exact quarter-turn correspondence, including transparency and pixel colors.
    assert horizontal.tobytes() == clockwise_at_head(vertical).tobytes()
    assert len(colors(vertical)) == len(colors(horizontal))
    assert sum(p[3] != 0 for p in rgba_pixels(vertical)) == sum(p[3] != 0 for p in rgba_pixels(horizontal))
    union = set().union(*(colors(asset) for _,asset in exports))
    assert len(union) <= 32 and union <= set(C.values())
    for _, asset in exports:
        assert {p[3] for p in rgba_pixels(asset)} == {0,255}
    gate = [inspect(HERE / name, (128,128),32) for name,_ in exports]
    assert all(item["technical_export_pass"] for item in gate)
    for item in gate:
        item["file"] = Path(item["file"]).name
    (HERE / "TECHNICAL_GATE.json").write_text(json.dumps(gate,indent=2)+"\n",encoding="utf-8",newline="\n")
    make_reviews(hero,vertical,horizontal)
    # Verify layered archives match the actual exports without claiming editor QA.
    for stem, image in [("protagonist",hero),("axe_neutral",vertical),("axe_rotation_90",horizontal)]:
        with zipfile.ZipFile(HERE / f"{stem}.ora") as archive:
            assert archive.read("mimetype") == b"image/openraster"
            assert Image.open(io.BytesIO(archive.read("mergedimage.png"))).convert("RGBA").tobytes() == image.tobytes()
            stack = ET.fromstring(archive.read("stack.xml")).find("stack")
            restored = [(item.attrib["name"],Image.open(io.BytesIO(archive.read(item.attrib["src"]))).convert("RGBA"))
                        for item in reversed(list(stack))]
            assert composite(restored).tobytes() == image.tobytes()
    manifest = {
        "date":"2026-10-14", "classification":"NATIVE_AUTHORING_CANDIDATE_NOT_APPROVED",
        "authorization":{"reviewer":"Rodrigo","quote":"Reconstrução com Python","scope":"native review draft, not final acceptance"},
        "method":"authored integer pixel coordinates in Python/Pillow; no source downsampling/quantization",
        "source_author":"Codex AI; automated reconstruction draft for Rodrigo's review",
        "tools":{"python":sys.version.split()[0],"pillow":PIL.__version__,"font_preview_only":"Windows Arial"},
        "reference":{"file":str(REFERENCE.relative_to(ROOT)).replace("\\","/"),"sha256":expected_ref},
        "coordinates":"zero-based pixel indices; bounding box max exclusive; sole pixel row inclusive",
        "protagonist":{"origin":[64,64],"body_bbox":body_bbox,"body_height":body_bbox[3]-body_bbox[1],
            "body_width":body_bbox[2]-body_bbox[0],"sole_row":90,"hair_bbox":hair_bbox,
            "hair_cluster_count_authored":len(clusters),"hair_cluster_polygons":clusters,
            "body_measurement_mask":"layers/protagonist/body_measurement_mask.png",
            "carry_translation":[33,25],"carried_head_center":[96.5,70.5],
            "left_grip":[55.5,70.5],"right_grip":[76.5,70.5]},
        "axe":{"neutral_head_bbox":head_bbox,"neutral_handle_bbox":handle_bbox,
            "handle_occupied_rows":48,"head_size":[32,18],"neutral_grip":[63.5,86.5],
            "neutral_secondary_grip":[63.5,65.5],
            "head_center":[63.5,45.5],"rotation_pivot":[63.5,45.5],
            "rotation_degrees_clockwise_y_down":90,"pixel_transform":"x_prime=109-y; y_prime=x-18",
            "rotated_grip":[22.5,45.5],"rotated_secondary_grip":[43.5,45.5],
            "pixel_exact_rotation":True,"head_x_symmetry":True},
        "shared_palette":{"visible_color_count":len(union),"limit":32,
            "used_hex":sorted("#"+bytes(p[:3]).hex().upper() for p in union),
            "proposal":str(PROPOSAL.relative_to(ROOT)).replace("\\","/"),"lock":"pending"},
        "gate":{"basic_export_checks":"pass","geometry_assertions":"pass","ora_recomposition":"pass",
            "visual_fidelity":"pending_owner_review","model_lock":"pending","palette_lock":"pending",
            "cultural_review":"pending_specific_version",
            "rights_clearance":"pending","godot_qa":"not_run","android_qa":"not_run",
            "clips":"not_authored","runtime_promotion":"not_performed"},
        "art_risks":["Face/hair volume simplified at 52px; compare with owner-approved v03.",
            "Hair cluster count is authored structure, not human-confirmed readability.",
            "Carried axe uses two grips and candidate horizontal pose; no animation/intersection QA.",
            "No final visual, cultural, palette or licensing acceptance inferred from technical pass."],
        "exports":gate,
        "files":[]
    }
    for path in sorted(HERE.rglob("*")):
        if path.is_file() and path.name != "MANIFEST.json" and "__pycache__" not in path.parts:
            manifest["files"].append({"file":path.relative_to(HERE).as_posix(),"bytes":path.stat().st_size,
                                     "sha256":hashlib.sha256(path.read_bytes()).hexdigest()})
    (HERE / "MANIFEST.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+"\n",encoding="utf-8",newline="\n")
    print(json.dumps({"exports":gate,"body_bbox":body_bbox,"hair_bbox":hair_bbox,
        "shared_colors":len(union),"quarter_turn":"pixel_exact_pass","ora":"recomposition_pass"},indent=2))


if __name__ == "__main__":
    main()
