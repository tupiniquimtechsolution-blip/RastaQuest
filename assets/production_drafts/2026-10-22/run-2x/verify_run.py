"""Saved-file prototype checks; no visual/final approval is granted."""
import importlib.util
import json
from pathlib import Path
from PIL import Image,ImageChops

ROOT=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location("art_gate",ROOT.parents[3]/"tools/art_asset_gate.py")
gate=importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)
import hashlib


def main():
    m=json.loads((ROOT/"MANIFEST.json").read_text(encoding="utf-8"))
    errors,reports=[],[]
    for record in [m["source"],*m["files"]]:
        if hashlib.sha256((ROOT/record["file"]).read_bytes()).hexdigest()!=record["sha256"]:
            errors.append(record["file"]+":hash")
    source=ROOT.parent/"axe-idle-2x/weapon_double_axe_rotation_90_01.png"
    if hashlib.sha256(source.read_bytes()).hexdigest()!=m["weapon_sha256"]:
        errors.append("rigid_weapon_source")
    placed=Image.new("RGBA",(256,256))
    placed.paste(Image.open(source).convert("RGBA"),(111-128,132-128))
    weapon=Image.open(ROOT/"layers/weapon_in_hand.png").convert("RGBA")
    if placed.tobytes()!=weapon.tobytes():
        errors.append("weapon_placement_drift")
    blade=Image.open(ROOT/"layers/blades_in_hand.png").convert("RGBA").getchannel("A")
    fist=Image.open(ROOT.parent/"axe-idle-2x/layers/grip_occlusion.png").convert("RGBA")
    colors,poses=set(),set()
    for i,f in enumerate(m["frames"],1):
        path=ROOT/f["file"]
        report=gate.inspect(path,[256,256],32)
        reports.append(report)
        errors.extend(str(i)+":"+e for e in report["errors"])
        body=Image.open(ROOT/f["body_file"]).convert("RGBA")
        legs=Image.open(ROOT/f["leg_file"]).convert("RGBA")
        image=Image.open(path).convert("RGBA")
        colors.update(p for p in (image.get_flattened_data() if hasattr(image,"get_flattened_data") else image.getdata()) if p[3])
        poses.add(hashlib.sha256(legs.tobytes()).hexdigest())
        if body.getpixel((111,132))[3]!=255:
            errors.append(str(i)+":grip")
        if ImageChops.multiply(body.getchannel("A"),blade).getbbox() is not None:
            errors.append(str(i)+":blade_body_overlap")
        foot=legs.getchannel("A").getbbox()[3]
        if foot!=f["feet_edge_y"] or (f["ground_contact"] and foot!=180) or (not f["ground_contact"] and foot>=180):
            errors.append(str(i)+":contact")
        expected=Image.alpha_composite(Image.alpha_composite(body,weapon),fist)
        if expected.tobytes()!=image.tobytes():
            errors.append(str(i)+":layer_composition")
    if len(colors)>32 or len(poses)!=6 or len(m["frames"])!=6:
        errors.append("palette_or_pose_count")
    result={"prototype_integrity_pass":not errors,"errors":errors,"shared_visible_colors":len(colors),
            "distinct_leg_exports":len(poses),"duration_ms":sum(f["duration_ms"] for f in m["frames"]),
            "automatic_approval":False,"scope":"layer/hash/palette/contact integrity; anatomy, gait, near/far continuity, foot slip, engine/device/final review pending",
            "export_checks":reports}
    (ROOT/"VERIFICATION.json").write_text(json.dumps(result,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({k:v for k,v in result.items() if k!="export_checks"},indent=2))
    raise SystemExit(0 if not errors else 1)


if __name__=="__main__":
    main()
