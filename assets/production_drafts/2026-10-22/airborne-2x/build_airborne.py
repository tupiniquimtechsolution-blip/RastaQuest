"""Two new single-pose prototypes; shared source density and rigid weapon."""
import hashlib
import importlib.util
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops

ROOT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("rig_source", ROOT.parent / "axe-idle-2x/build_pack.py")
rig = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rig)


def save(image, name):
    image.save(ROOT / name)
    return {"file": name, "sha256": rig.sha(ROOT / name)}


def main():
    source_scale = 24 / 140  # One shared scale for both new1254px source canvases.
    rigid_weapon_path = ROOT.parent / "axe-idle-2x/weapon_double_axe_carried_01.png"
    weapon = Image.open(rigid_weapon_path).convert("RGBA")
    head = Image.open(ROOT.parent / "axe-idle-2x/layers/axe_head.png").convert("RGBA")
    head = head.transpose(Image.Transpose.ROTATE_270).rotate(-12, resample=Image.Resampling.NEAREST, center=(128, 128))
    entries = [
        ("jump", "3256094caec1988d01806d3b19d0ba423812f203c21aa8321839e4b79d350d36", (640,580), (844,550)),
        ("fall", "d8a7990418dca13cd8af4668462cc05bd792772d4408c2a4b94b56d6cd81b835", (635,620), (792,592)),
    ]
    frames, files, reviews = [], [], []
    for clip, expected_sha, pelvis, grip_source in entries:
        source_path = ROOT / (clip + "-body-source.png")
        if rig.sha(source_path) != expected_sha:
            raise ValueError("Unexpected source for " + clip)
        source = Image.open(source_path).convert("RGBA")
        offset = (130-round(pelvis[0]*source_scale), 120-round(pelvis[1]*source_scale))
        reduced = rig.palette_map(source.resize((round(source.width*source_scale), round(source.height*source_scale)), Image.Resampling.BOX))
        body = Image.new("RGBA", (256,256))
        body.paste(reduced, offset)
        grip = (round(grip_source[0]*source_scale)+offset[0], round(grip_source[1]*source_scale)+offset[1])
        positioned, blades, fist = [Image.new("RGBA",(256,256)) for _ in range(3)]
        positioned.paste(weapon,(grip[0]-128,grip[1]-128))
        blades.paste(head,(grip[0]-128,grip[1]-128))
        rect=(grip[0]-7,grip[1]-7,grip[0]+8,grip[1]+8)
        fist.paste(body.crop(rect),(rect[0],rect[1]))
        combined = Image.alpha_composite(Image.alpha_composite(body, positioned), fist)
        for image, suffix in [(body,"body"),(positioned,"weapon"),(fist,"grip"),(combined,"combined")]:
            files.append(save(image,f"{clip}_{suffix}_01.png"))
        bounds = body.getchannel("A").getbbox()
        overlap = ImageChops.multiply(body.getchannel("A"),blades.getchannel("A")).getbbox()
        if body.getpixel(grip)[3] != 255 or overlap is not None:
            raise ValueError("Grip or blade contact failed for " + clip)
        frames.append({"clip":clip,"file":f"{clip}_combined_01.png","pose_count":1,
                       "origin":[128,128],"pelvis_anchor":[130,120],
                       "source_pelvis_estimated":list(pelvis),"source_grip_estimated":list(grip_source),
                       "grip":list(grip),"body_alpha_bbox":bounds,"feet_edge_y":bounds[3],
                       "feet_displacement_from_neutral":bounds[3]-180,
                       "blade_body_overlap":False,"fist_on_opaque_body":True})
        background = Image.new("RGBA",(256,256),"#142024")
        background.alpha_composite(combined)
        reviews.append(background.convert("RGB").resize((768,768),Image.Resampling.NEAREST))
    board=Image.new("RGB",(1536,830),"#142024")
    for i,review in enumerate(reviews):
        board.paste(review,(i*768,20))
    draw=ImageDraw.Draw(board)
    draw.text((35,20),"JUMP | new pose | prototype only",fill="#efcf81")
    draw.text((803,20),"FALL | new pose | prototype only",fill="#efcf81")
    draw.text((35,800),"Same source scale / palette / rigid weapon. Landmarks/anatomy/final animation/device QA pending.",fill="#e8e3d2")
    board.save(ROOT/"AIRBORNE_REVIEW.png")
    record={"classification":"AIRBORNE_POSE_PROTOTYPES_NOT_FINAL","frame":[256,256],"render_scale":0.5,
            "appearance_approval":"Base target only; new poses not final accepted",
            "shared_source_scale":source_scale,"method":"New ImageGen poses; one uniform shared BOX reduction; fixed32-color mapping/binary alpha; estimated pelvis anchors; same rigid carried weapon/fist occlusion",
            "weapon_source":"../axe-idle-2x/weapon_double_axe_carried_01.png","weapon_sha256":rig.sha(rigid_weapon_path),
            "frames":frames,"files":files,"model_geometry":"PENDING","motion_transitions":"PENDING",
            "rights_clearance":"PENDING","final_cultural_review":"PENDING","runtime_promotion":False,
            "missing_body_clips":["run","attack_axe","attack_axe_air","hurt","death"],
            "sources":{clip:{"file":clip+"-body-source.png","sha256":digest} for clip,digest,_,_ in entries}}
    (ROOT/"MANIFEST.json").write_text(json.dumps(record,indent=2)+"\n",encoding="utf-8")
    print(json.dumps(frames,indent=2))


if __name__=="__main__":
    main()
