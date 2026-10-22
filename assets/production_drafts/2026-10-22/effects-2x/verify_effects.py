"""Inspect actual FX exports; never grants final visual or accessibility approval."""
import hashlib,importlib.util,json
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('gate',ROOT.parents[3]/'tools/art_asset_gate.py')
gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate)

def main():
    m=json.loads((ROOT/'MANIFEST.json').read_text(encoding='utf-8'));errors=[];reports=[];colors=set()
    for r in m['sources']+m['files']:
        if hashlib.sha256((ROOT/r['file']).read_bytes()).hexdigest()!=r['sha256']:errors.append(r['file']+':hash')
    for clip,count,duration in [('lightning_proc',3,180),('portal_interaction',4,360)]:
        frames=[f for f in m['frames'] if f['clip']==clip]
        if len(frames)!=count or sum(f['duration_ms'] for f in frames)!=duration or len({f['source_scale'] for f in frames})!=1:errors.append(clip+':timeline_or_density')
        poses=set()
        for f in frames:
            report=gate.inspect(ROOT/f['file'],[256,256],8);report['file']=f['file'];reports.append(report)
            errors.extend(f['file']+':'+e for e in report['errors'])
            im=Image.open(ROOT/f['file']).convert('RGBA');alpha=im.getchannel('A');b=alpha.getbbox()
            colors.update(p[:3] for p in (im.get_flattened_data() if hasattr(im,'get_flattened_data') else im.getdata()) if p[3])
            poses.add(hashlib.sha256(im.tobytes()).hexdigest())
            if list(b)!=f['alpha_bbox'] or b[0]<=0 or b[1]<=0 or b[2]>=256 or b[3]>=256:errors.append(f['file']+':bounds')
            if clip=='portal_interaction' and alpha.crop((118,108,138,148)).getbbox():errors.append(f['file']+':portal_center_not_hollow')
        if len(poses)!=count:errors.append(clip+':duplicate_keys')
    if len(colors)>8 or m['runtime_promotion']:errors.append('palette_or_promotion')
    result={'prototype_integrity_pass':not errors,'errors':errors,'frames_checked':7,'shared_fx_colors':len(colors),
        'automatic_approval':False,'scope':'Saved hashes,256px/binary alpha/shared8FXcolors,timing,distinct keys,frame bounds and empty central portal opening. Does not prove exact ellipse continuity, reduced-flash safety, gameplay integration, art acceptance or rights.',
        'export_checks':reports}
    (ROOT/'VERIFICATION.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k!='export_checks'},indent=2));raise SystemExit(0 if not errors else 1)

if __name__=='__main__':main()
