"""Inspect saved exports independently of the authoring script."""
import hashlib
import importlib.util
import json
from pathlib import Path
from PIL import Image, ImageChops

ROOT=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('gate',ROOT.parents[3]/'tools/art_asset_gate.py')
gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate)

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def pixels(im):
    return im.get_flattened_data() if hasattr(im,'get_flattened_data') else im.getdata()

def verify():
    m=json.loads((ROOT/'MANIFEST.json').read_text(encoding='utf-8'))
    errors,reports,colors=[],[],set()
    rigid_path=ROOT/m['weapon_source']
    if digest(rigid_path)!=m['weapon_sha256']:errors.append('weapon_source_hash')
    rigid=Image.open(rigid_path).convert('RGBA')
    blade=Image.open(ROOT.parent/'axe-idle-2x/layers/axe_head.png').convert('RGBA')
    for record in [*m['sources'],*m['files']]:
        if digest(ROOT/record['file'])!=record['sha256']:errors.append(record['file']+':hash')
    expected={'attack_axe':(4,160),'attack_axe_air':(3,160),'hurt':(2,180),'death':(4,600)}
    palette={tuple(bytes.fromhex(v)) for v in m['palette_hex']}
    for clip,(count,duration) in expected.items():
        frames=[f for f in m['frames'] if f['clip']==clip]
        if len(frames)!=count or sum(f['duration_ms'] for f in frames)!=duration:
            errors.append(clip+':count_or_timing')
        if len({f['source_scale'] for f in frames})!=1:errors.append(clip+':per_frame_scaling')
        poses=set()
        for f in frames:
            names=f['files'];label=f'{clip}{f["index"]}'
            ims={key:Image.open(ROOT/name).convert('RGBA') for key,name in names.items()}
            body=ims['body'];poses.add(hashlib.sha256(body.tobytes()).hexdigest())
            for key,im in ims.items():
                if im.size!=(256,256):errors.append(label+':'+key+':size')
                alphas=set(pixels(im.getchannel('A')))
                if alphas-{0,255}:errors.append(label+':'+key+':alpha')
                visible={p[:3] for p in pixels(im) if p[3]}
                if visible-palette:errors.append(label+':'+key+':palette')
                colors.update(visible)
            report=gate.inspect(ROOT/names['combined'],[256,256],32)
            # Make the report reproducible across checkout locations.
            report['file']=names['combined'];reports.append(report)
            errors.extend(label+':'+e for e in report['errors'])
            bbox=body.getchannel('A').getbbox()
            if list(bbox)!=f['body_alpha_bbox'] or bbox[3]!=f['body_bottom_y']:
                errors.append(label+':body_bounds')
            if f['ground_contact'] and bbox[3]!=180:errors.append(label+':ground_contact')
            if bbox[0]<=0 or bbox[1]<=0 or bbox[2]>=256 or bbox[3]>=256:
                errors.append(label+':body_frame_edge')
            grip=f['weapon_grip']
            if grip is not None:
                if body.getpixel(tuple(grip))[3]!=255:errors.append(label+':grip')
                for key,source in [('weapon',rigid),('blades',blade)]:
                    rot=source.rotate(-f['weapon_clockwise_degrees'],resample=Image.Resampling.NEAREST,center=(128,128))
                    expanded=Image.new('RGBA',(768,768));expanded.paste(rot,(256+grip[0]-128,256+grip[1]-128))
                    b=expanded.getchannel('A').getbbox()
                    if b and (b[0]<256 or b[1]<256 or b[2]>512 or b[3]>512):errors.append(label+':weapon_clipped')
                    if expanded.crop((256,256,512,512)).tobytes()!=ims[key].tobytes():errors.append(label+':rigid_'+key)
                head=ims['blades'].getchannel('A')
                if ImageChops.multiply(body.getchannel('A'),head).getbbox():errors.append(label+':blade_body_overlap')
                if f['ground_contact'] and head.getbbox()[3]>180:errors.append(label+':blade_below_floor')
                # Actual combat box56x42 at x38 => source148..260,y86..170.
                if clip.startswith('attack_axe') and not head.crop((148,86,256,170)).getbbox():
                    errors.append(label+':no_visible_blade_in_active_hitbox')
            elif any(ims[k].getchannel('A').getbbox() for k in ['weapon','blades','grip']):
                errors.append(label+':unexpected_weapon_after_drop')
            if Image.alpha_composite(Image.alpha_composite(body,ims['weapon']),ims['grip']).tobytes()!=ims['combined'].tobytes():
                errors.append(label+':composition')
        if len(poses)!=count:errors.append(clip+':duplicate_body_pose')
    if len(colors)>32:errors.append('shared_palette_exceeds32')
    if m['runtime_promotion'] or m['gameplay_contract']['animation_controls_damage']:errors.append('authority_or_promotion')
    result={'prototype_integrity_pass':not errors,'errors':errors,'frames_checked':len(m['frames']),
        'shared_visible_colors':len(colors),'clip_timing_ms':{k:v[1] for k,v in expected.items()},
        'automatic_approval':False,'scope':'Saved hashes, export format, shared palette, timing, rigid composition, grip, blade/body clearance and some active-hitbox overlap. Does not prove full swept coverage, anatomy, manual pixel cleanup, continuous motion, actual game/device quality or licensing.',
        'export_checks':reports}
    (ROOT/'VERIFICATION.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k!='export_checks'},indent=2))
    return not errors

if __name__=='__main__':raise SystemExit(0 if verify() else 1)
