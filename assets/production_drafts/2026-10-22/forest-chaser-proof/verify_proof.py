import hashlib,importlib.util,json
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('gate',ROOT.parents[3]/'tools/art_asset_gate.py')
gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate)

def main():
    m=json.loads((ROOT/'MANIFEST.json').read_text(encoding='utf-8'));errors=[];reports=[]
    for f in m['sources']+m['files']:
        if hashlib.sha256((ROOT/f['file']).read_bytes()).hexdigest()!=f['sha256']:errors.append(f['file']+':hash')
    for f in m['files']:
        im=Image.open(ROOT/f['file']).convert('RGBA')
        if list(im.size)!=f['size']:errors.append(f['file']+':size')
        pixels=list(im.get_flattened_data() if hasattr(im,'get_flattened_data') else im.getdata())
        if {p[3] for p in pixels}-{0,255}:errors.append(f['file']+':alpha')
        if len({p[:3] for p in pixels if p[3]})>f.get('palette_limit',64):errors.append(f['file']+':palette')
    for f in m['chaser']['frames']:
        r=gate.inspect(ROOT/f['file'],[256,256],24);r['file']=f['file'];reports.append(r)
        errors.extend(f['file']+':'+e for e in r['errors'])
        if r['alpha_bbox'][3]!=186 or list(r['alpha_bbox'])!=f['alpha_bbox']:errors.append(f['file']+':feet')
        if r['alpha_bbox'][0]<=0 or r['alpha_bbox'][1]<=0 or r['alpha_bbox'][2]>=256:errors.append(f['file']+':frame_clipping')
    top=Image.open(ROOT/'terrain_top_32.png');soil=Image.open(ROOT/'terrain_soil_32.png')
    for im in [top,soil]:
        if im.size!=(32,32) or im.crop((0,0,1,32)).tobytes()!=im.crop((31,0,32,32)).tobytes():errors.append('tile_horizontal_boundary')
    if top.crop((0,31,32,32)).tobytes()!=soil.crop((0,0,32,1)).tobytes() or soil.crop((0,31,32,32)).tobytes()!=soil.crop((0,0,32,1)).tobytes():errors.append('tile_vertical_boundary')
    if len({f['source_scale'] for f in m['chaser']['frames']})!=1:errors.append('per_pose_density')
    if m['runtime_promotion']:errors.append('unexpected_promotion')
    result={'prototype_integrity_pass':not errors,'errors':errors,'chaser_keys':7,'chaser_states':6,'tile_boundary_pixels_equal':True if not any('tile_' in e for e in errors) else False,
        'automatic_approval':False,'scope':'Hashes, sizes,palette/alpha,native tile boundary equality and Chaser floor186. Not natural repeat quality, full environment kit, anatomy/rigid enemy weapons, motion/hitbox coverage, visual/mobile/culture/rights acceptance.', 'chaser_export_checks':reports}
    (ROOT/'VERIFICATION.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k!='chaser_export_checks'},indent=2));raise SystemExit(0 if not errors else 1)
if __name__=='__main__':main()
