"""Artifact integrity and rig/terrain boundaries, not human/device acceptance."""
import hashlib,json,math
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parent
REPO=ROOT.parents[3]

def main():
    m=json.loads((ROOT/'MANIFEST.json').read_text());errors=[]
    def check(ok,label):
        if not ok:errors.append(label)
    for f in m['files']+m['sources']+m['previews']:
        p=ROOT/f['file'];im=Image.open(p).convert('RGBA')
        check(hashlib.sha256(p.read_bytes()).hexdigest()==f['sha256'],f['file']+':hash')
        check(list(im.size)==f['size'],f['file']+':size')
        if 'palette_limit' in f:
            check(set(im.getchannel('A').tobytes())<={0,255},f['file']+':alpha')
            raw=im.tobytes();check(len({raw[i:i+3] for i in range(0,len(raw),4) if raw[i+3]})<=f['palette_limit'],f['file']+':palette')
        if f.get('role')=='body':
            b=im.getchannel('A').getbbox();check(b is not None and b[3]==186,f['file']+':feet')
    check(m['chaser']['counts']==dict(idle=2,move=6,tell=2,attack=2,hurt=2,death=2),'clip_budget')
    overflow=[]
    for frame in m['chaser']['frames']:
        for name,gear in m['chaser']['rigid_equipment'].items():
            im=Image.open(ROOT/gear['file']).convert('RGBA');a=im.getchannel('A');px,py=gear['pivot'];angle=math.radians(frame[name+'_degrees']);x,y=frame[name+'_position']
            for yy in range(im.height):
                for xx in range(im.width):
                    if a.getpixel((xx,yy))==0:continue
                    tx=128+x+(xx-px)*math.cos(angle)-(yy-py)*math.sin(angle)
                    ty=128+y+(xx-px)*math.sin(angle)+(yy-py)*math.cos(angle)
                    if not (0<=tx<256 and 0<=ty<256):overflow.append(frame['file']+':'+name);break
                else:continue
                break
    check(not overflow,'rig_canvas_overflow:'+str(overflow))
    tops=[Image.open(ROOT/f'terrain_top_{i}.png').convert('RGBA') for i in range(1,4)]
    soils=[Image.open(ROOT/f'terrain_soil_{i}.png').convert('RGBA') for i in range(1,4)]
    for family in [tops,soils]:
        for left in family:
            for right in family:
                check(all(left.getpixel((31,y))==right.getpixel((0,y)) for y in range(32)),'arbitrary_horizontal_adjacency')
    for top in tops:
        for soil in soils:check(all(top.getpixel((x,31))==soil.getpixel((x,0)) for x in range(32)),'top_soil_join')
    for first in soils:
        for second in soils:check(all(first.getpixel((x,31))==second.getpixel((x,0)) for x in range(32)),'soil_vertical_join')
    for name in ['top_left','top_right','isolated']:
        im=Image.open(ROOT/f'terrain_{name}.png').convert('RGBA');check(all(im.getpixel((x,0))[3]==255 for x in range(32)),name+':flat_contact')
    source=ROOT/m['referenced_terrain']['file'];check(hashlib.sha256(source.read_bytes()).hexdigest()==m['referenced_terrain']['sha256'],'terrain_source_hash')
    report_path=ROOT/'room-review/RENDER_REPORT.json'
    captures=0
    if report_path.exists():
        r=json.loads(report_path.read_text());captures=len(r['captures']);by_name={f['file']:f for f in r['captures']}
        for f in r['captures']:
            p=ROOT/'room-review'/f['file'];check(hashlib.sha256(p.read_bytes()).hexdigest()==f['sha256'],f['file']+':capture_hash');check(list(Image.open(p).size)==f['size'],f['file']+':capture_size')
        for path,expected in r['source_hashes'].items():
            text=(REPO/'game'/path.removeprefix('res://')).read_text(encoding='utf-8')
            check(hashlib.sha256(text.encode()).hexdigest()==expected,'capture_source:'+path)
        for name,phase,clip in [('actual_tell_1280x720.png','tell','tell'),('actual_active_1280x720.png','active','attack')]:
            f=by_name[name];check(f['enemy_phase']==phase and f['enemy_clip']==clip and not f['pose_inspection'],name+':phase')
        f=by_name['actual_death_1280x720.png'];check(f.get('enemy_dead') and f['enemy_clip']=='death' and f['enemy_frame']==1,'actual_death_frame')
        for x in [180,640,1280,1920,2380]:
            for size in ['1280x720','640x360']:check(f'traverse_{x:04d}_{size}.png' in by_name,'traversal_capture')
        check(r['human_acceptance']=='PENDING' and not r['runtime_asset_promotion'],'unearned_capture_acceptance')
    else:errors.append('missing_render_report')
    check(not m['runtime_promotion'] and m['visual_acceptance']=='PENDING','unearned_manifest_acceptance')
    report=dict(artifact_integrity_pass=not errors,errors=errors,body_keys=16,rigid_textures=2,terrain_tiles=16,desktop_captures=captures,automatic_visual_acceptance=False)
    (ROOT/'VERIFICATION.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2));raise SystemExit(bool(errors))

if __name__=='__main__':main()
