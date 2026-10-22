"""Run-layer authoring prototype; sources/cleanup declared, never final approval."""
import importlib.util
import json
from pathlib import Path
from PIL import Image,ImageDraw,ImageChops

ROOT=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location("axe_rig",ROOT.parent/"axe-idle-2x/build_pack.py")
rig=importlib.util.module_from_spec(spec)
spec.loader.exec_module(rig)


def save(image,name):
    (ROOT/name).parent.mkdir(parents=True,exist_ok=True)
    image.save(ROOT/name)
    return {"file":name,"sha256":rig.sha(ROOT/name)}


def main():
    source_path=ROOT/"run-lower-source.png"
    if rig.sha(source_path)!="0c99609295ecd532baa7e10716c5f883e0fc7cb5c28bd8ca8bba2f8929a6fa0e":
        raise ValueError("Unexpected running-leg source")
    source=Image.open(source_path).convert("RGBA")
    neutral=Image.open(ROOT.parent/"axe-idle-2x/layers/body_neutral.png").convert("RGBA")
    torso=Image.new("RGBA",(256,256))
    torso.paste(neutral.crop((0,0,256,118)),(0,0))
    arm_mask=Image.new("L",(256,256))
    pen=ImageDraw.Draw(arm_mask)
    pen.polygon([(104,114),(115,115),(116,132),(114,143),(104,144),(100,137),(101,125)],fill=255)
    pen.polygon([(143,114),(150,115),(160,136),(157,144),(150,142),(144,130)],fill=255)
    arms=Image.new("RGBA",(256,256))
    arms.paste(neutral,(0,0),ImageChops.multiply(arm_mask,neutral.getchannel("A")))
    weapon_source=ROOT.parent/"axe-idle-2x/weapon_double_axe_rotation_90_01.png"
    weapon=Image.new("RGBA",(256,256))
    weapon.paste(Image.open(weapon_source).convert("RGBA"),(111-128,132-128))
    fist=Image.open(ROOT.parent/"axe-idle-2x/layers/grip_occlusion.png").convert("RGBA")
    blade_layer=Image.new("RGBA",(256,256))
    blade_layer.paste(Image.open(ROOT.parent/"axe-idle-2x/layers/axe_head.png").convert("RGBA").transpose(Image.Transpose.ROTATE_270),(111-128,132-128))
    blade=blade_layer.getchannel("A")
    source_hips=[(275,177),(278,177),(294,177),(277,148),(273,148),(293,148)]
    scale=60/(466-177)  # Same density for all six leg cells, derived from first contact.
    atlas=Image.new("RGBA",(1536,256))
    files=[save(torso,"layers/torso.png"),save(arms,"layers/arms.png"),
           save(weapon,"layers/weapon_in_hand.png"),save(blade_layer,"layers/blades_in_hand.png")]
    frames,reviews=[],[]
    for i,(hip,lift) in enumerate(zip(source_hips,[0,1,2,0,1,2]),1):
        x,y=(i-1)%3,(i-1)//3
        cell=source.crop((x*512,y*512,(x+1)*512,(y+1)*512))
        reduced=rig.palette_map(cell.resize((round(512*scale),round(512*scale)),Image.Resampling.BOX))
        lower=Image.new("RGBA",(256,256))
        base=(130-round(hip[0]*scale),120-round(hip[1]*scale))
        lower.paste(reduced,base)
        correction=0
        if i in (1,2,4,5):
            correction=180-lower.getchannel("A").getbbox()[3]
            moved=Image.new("RGBA",(256,256))
            moved.paste(lower,(0,correction))
            lower=moved
        upper=Image.new("RGBA",(256,256))
        upper.paste(torso,(0,-lift))
        body=Image.alpha_composite(Image.alpha_composite(lower,upper),arms)
        combined=Image.alpha_composite(Image.alpha_composite(body,weapon),fist)
        files.extend([save(lower,f"layers/legs_{i:02}.png"),save(body,f"body_run_{i:02}.png"),save(combined,f"player_run_{i:02}.png")])
        overlap=ImageChops.multiply(body.getchannel("A"),blade).getbbox()
        if overlap is not None or body.getpixel((111,132))[3]!=255:
            raise ValueError("Blade/grip intersection failed in frame"+str(i))
        atlas.paste(combined,((i-1)*256,0))
        bg=Image.new("RGBA",(256,256),"#142024")
        bg.alpha_composite(combined)
        reviews.append(bg.convert("RGB").resize((768,768),Image.Resampling.NEAREST))
        frames.append({"file":f"player_run_{i:02}.png","body_file":f"body_run_{i:02}.png","leg_file":f"layers/legs_{i:02}.png",
                       "duration_ms":60,"source_hip_estimated":hip,"origin":[128,128],
                       "torso_lift":lift,"contact_correction_source_pixels":correction,"feet_edge_y":lower.getchannel("A").getbbox()[3],
                       "ground_contact":i in (1,2,4,5),"rigid_grip":[111,132],"blade_body_overlap":False})
    files.append(save(atlas,"player_run_atlas.png"))
    reviews[0].save(ROOT/"RUN_REVIEW.gif",save_all=True,append_images=reviews[1:],duration=60,loop=0,optimize=False)
    board=Image.new("RGB",(1536,1060),"#142024")
    for i,image in enumerate(reviews):
        board.paste(image.resize((512,512),Image.Resampling.NEAREST),((i%3)*512,22+(i//3)*512))
    draw=ImageDraw.Draw(board)
    draw.text((24,4),"RUN LOWER-BODY PROTOTYPE |6 source poses, shared torso/arms/weapon | NOT FINAL",fill="#e9cc83")
    draw.text((24,1044),"Single source scale; contact rows corrected by translation only. Motion/anatomy review pending.",fill="#e9cc83")
    board.save(ROOT/"RUN_REVIEW.png")
    record={"classification":"RUN_LAYER_PROTOTYPE_NOT_FINAL","source":{"file":source_path.name,"sha256":rig.sha(source_path),"size":list(source.size)},
            "source_density_scale":scale,"frame":[256,256],"render_scale":0.5,
            "method":"New ImageGen running-leg poses; single BOX scale; fixed32-color/binary alpha; estimated hip translations and declared contact corrections; shared torso/arm rig and identical weapon/fist",
            "leg_pose_count":6,"duration_ms":360,"frames":frames,"files":files,
            "reference_run_speed_world_units":260,"timing_note":"Estimated contact stride46 world units per180ms; actual foot-slip and speed adaptation pending",
            "weapon_source":"../axe-idle-2x/weapon_double_axe_rotation_90_01.png",
            "weapon_angle_clockwise":90,"weapon_sha256":rig.sha(weapon_source),
            "appearance_target":"Owner-approved base only; no final run/anatomy acceptance",
            "animation_quality":"PENDING","native_cleanup":"PENDING","rights_clearance":"PENDING","runtime_promotion":False}
    (ROOT/"MANIFEST.json").write_text(json.dumps(record,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({"frame_contact_corrections":[f["contact_correction_source_pixels"] for f in frames],
                      "feet":[f["feet_edge_y"] for f in frames]},indent=2))


if __name__=="__main__":
    main()
