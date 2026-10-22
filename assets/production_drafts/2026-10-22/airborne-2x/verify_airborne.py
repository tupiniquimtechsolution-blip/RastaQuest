"""Inspect saved prototypes and their layer/hash consistency; never approve art."""
import hashlib
import importlib.util
import json
from pathlib import Path
from PIL import Image, ImageChops

ROOT=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location("art_gate",ROOT.parents[3]/"tools/art_asset_gate.py")
gate=importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)


def main():
    manifest=json.loads((ROOT/"MANIFEST.json").read_text(encoding="utf-8"))
    errors=[]
    for record in manifest["files"]:
        if hashlib.sha256((ROOT/record["file"]).read_bytes()).hexdigest()!=record["sha256"]:
            errors.append(record["file"]+":hash")
    weapon_path=ROOT.parent/"axe-idle-2x/weapon_double_axe_carried_01.png"
    if hashlib.sha256(weapon_path.read_bytes()).hexdigest()!=manifest["weapon_sha256"]:
        errors.append("rigid_weapon_source_changed")
    weapon=Image.open(weapon_path).convert("RGBA")
    head=Image.open(ROOT.parent/"axe-idle-2x/layers/axe_head.png").convert("RGBA")
    head=head.transpose(Image.Transpose.ROTATE_270).rotate(-12,resample=Image.Resampling.NEAREST,center=(128,128))
    reports=[]
    colors=set()
    for frame in manifest["frames"]:
        clip=frame["clip"]
        path=ROOT/frame["file"]
        report=gate.inspect(path,[256,256],32)
        reports.append(report)
        errors.extend(clip+":"+error for error in report["errors"])
        body=Image.open(ROOT/f"{clip}_body_01.png").convert("RGBA")
        saved_weapon=Image.open(ROOT/f"{clip}_weapon_01.png").convert("RGBA")
        fist=Image.open(ROOT/f"{clip}_grip_01.png").convert("RGBA")
        combined=Image.open(path).convert("RGBA")
        colors.update(p for p in (combined.get_flattened_data() if hasattr(combined,"get_flattened_data") else combined.getdata()) if p[3])
        positioned,blades=[Image.new("RGBA",(256,256)) for _ in range(2)]
        grip=tuple(frame["grip"])
        for target,source in [(positioned,weapon),(blades,head)]:
            target.paste(source,(grip[0]-128,grip[1]-128))
        if positioned.tobytes()!=saved_weapon.tobytes():
            errors.append(clip+":weapon_drift")
        if body.getpixel(grip)[3]!=255:
            errors.append(clip+":grip")
        if ImageChops.multiply(body.getchannel("A"),blades.getchannel("A")).getbbox() is not None:
            errors.append(clip+":blade_body_overlap")
        expected=Image.alpha_composite(Image.alpha_composite(body,positioned),fist)
        if expected.tobytes()!=combined.tobytes():
            errors.append(clip+":composition")
        if body.getchannel("A").getbbox()[3]!=frame["feet_edge_y"]:
            errors.append(clip+":feet_record")
    if len(colors)>32:
        errors.append("shared_palette_exceeds32")
    result={"prototype_integrity_pass":not errors,"errors":errors,"shared_visible_colors":len(colors),
            "new_drawn_pose_count":2,"export_checks":reports,"automatic_approval":False,
            "scope":"source/export/layer integrity only; anatomy, state transitions, final visual/cultural/rights/device review pending"}
    (ROOT/"VERIFICATION.json").write_text(json.dumps(result,indent=2)+"\n",encoding="utf-8")
    print(json.dumps({k:v for k,v in result.items() if k!="export_checks"},indent=2))
    raise SystemExit(0 if not errors else 1)


if __name__=="__main__":
    main()
