"""Reopen saved artifacts, validate native contracts and actual capture states."""
import csv,hashlib,json
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parent
REPO=ROOT.parents[3]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    m=json.loads((ROOT/'MANIFEST.json').read_text(encoding='utf-8'));errors=[]
    def check(ok,label):
        if not ok:errors.append(label)
    for record in m['files']+m['sources']:
        p=ROOT/record['file'];im=Image.open(p).convert('RGBA')
        check(sha(p)==record['sha256'],record['file']+':hash');check(list(im.size)==record['size'],record['file']+':size')
        if 'palette_limit' in record:
            data=im.tobytes();check(len({data[i:i+3] for i in range(0,len(data),4) if data[i+3]})<=record['palette_limit'],record['file']+':colors')
            check(set(im.getchannel('A').tobytes())<={0,255},record['file']+':alpha')
    body_count=0
    for role,actor in m['actors'].items():
        body_count+=len(actor['frames']);check(actor['render_scale']==.5,role+':scale')
        check(set(actor['clips'])>={'idle','move','hurt','death'},role+':base_clips')
        for pair in actor['patterns'].values():check(all(c in actor['clips'] for c in pair),role+':pattern_clips')
        for f in actor['frames']:
            im=Image.open(ROOT/f['file']).convert('RGBA');b=im.getchannel('A').getbbox()
            check(im.size==(actor['canvas'],actor['canvas']) and b is not None and b[3]==actor['feet_edge_y'],f['file']+':canvas_feet')
            check(0<b[0]<b[2]<actor['canvas'] and 0<b[1],f['file']+':border_contact')
    check(body_count==56,'body_key_count')
    for biome,env in m['environments'].items():
        folder=ROOT/'environments'/biome
        check(len(env['terrain'])==16 and len(env['props'])==5,biome+':kit_count')
        tops=[Image.open(folder/f'terrain_top_{i}.png').convert('RGBA') for i in range(1,4)];soils=[Image.open(folder/f'terrain_soil_{i}.png').convert('RGBA') for i in range(1,4)]
        for family in [tops,soils]:
            for left in family:
                for right in family:check(all(left.getpixel((31,y))==right.getpixel((0,y)) for y in range(32)),biome+':horizontal_join')
        for soil in soils:
            for top in tops:check(all(top.getpixel((x,31))==soil.getpixel((x,0))==soil.getpixel((x,31)) for x in range(32)),biome+':vertical_join')
        for side in ['left','right']:
            a=Image.open(folder/f'terrain_top_{side}.png').convert('RGBA');b=Image.open(folder/f'terrain_side_{side}.png').convert('RGBA');c=Image.open(folder/f'terrain_bottom_{side}.png').convert('RGBA')
            check(all(a.getpixel((x,31))[3]==b.getpixel((x,0))[3]==b.getpixel((x,31))[3]==c.getpixel((x,0))[3] for x in range(32)),biome+':corner_alpha_join')
        check(len({(folder/f'terrain_bottom{s}.png').read_bytes() for s in ['','_left','_right']})==3,biome+':distinct_bottom_corners')
    portal=m['portal_body'];check(len(portal['frames'])==4 and not portal['runtime_binding'],'portal_candidate_status')
    master_path=ROOT/portal['axe_master']['file'];check(sha(master_path)==portal['axe_master']['sha256'],'axe_master_hash')
    master=Image.open(master_path).convert('RGBA').rotate(8,resample=Image.Resampling.NEAREST,center=(128,128));master_pixels=sum(a==255 for a in master.getchannel('A').tobytes())
    for f in portal['frames']:
        body=Image.open(ROOT/f['body_file']).convert('RGBA');weapon=Image.open(ROOT/f['weapon_file']).convert('RGBA')
        check(body.getchannel('A').getbbox()[3]==180,f['body_file']+':feet')
        check(sum(a==255 for a in weapon.getchannel('A').tobytes())==master_pixels,f['weapon_file']+':rigid_clipping')
    check(sum(len(x['frames']) for x in m['effects'].values())==21,'fx_key_count')
    reward=[Image.open(ROOT/x['file']).convert('RGBA').crop((51,42,78,89)).tobytes() for x in m['effects']['reward']['frames']];check(len(set(reward))==1,'reward_shard_fixed')
    trace=json.loads((ROOT/'INTEGRATION_TRACE.json').read_text(encoding='utf-8'));check(len(trace['cases'])==9 and all(x['damage_observed']>0 and x['defeats']==1 for x in trace['cases']),'integration_trace_cases')
    report=json.loads((ROOT/'room-review/RENDER_REPORT.json').read_text(encoding='utf-8'))
    captures=report['captures'];by_name={x['file']:x for x in captures}
    for f in captures:
        p=ROOT/'room-review'/f['file'];check(sha(p)==f['sha256'] and list(Image.open(p).size)==f['size'],f['file']+':capture_integrity')
    for p,expected in report['source_hashes'].items():
        text=(REPO/'game'/p.removeprefix('res://')).read_text(encoding='utf-8');check(hashlib.sha256(text.encode()).hexdigest()==expected,'capture_source:'+p)
    for role,actor in m['actors'].items():
        for pattern,pair in actor['patterns'].items():
            for phase,clip in [('tell',pair[0]),('active',pair[1])]:
                name=f'{role}_{pattern}_{phase}.png';f=by_name.get(name,{});check(f.get('phase')==phase and f.get('clip')==clip,name+':phase_clip')
        f=by_name.get(role+'_death.png',{});check(f.get('dead') and f.get('clip')=='death' and f.get('frame')==1,role+':fallen_capture')
    for biome in m['environments']:
        for size in ['1280x720','640x360']:check(f'{biome}_room_{size}.png' in by_name,biome+':room_capture')
    check(not m['runtime_promotion'] and m['visual_acceptance']=='PENDING' and not report['runtime_asset_promotion'] and report['human_acceptance']=='PENDING','unearned_acceptance')
    # Provenance inventory is an authoring register, never license evidence.
    with (ROOT/'AUTHORING_PROVENANCE.csv').open('w',encoding='utf-8',newline='') as stream:
        w=csv.writer(stream);w.writerow(['asset_path','sha256','kind','method','rights_status','cultural_review_status','release_approved'])
        for f in m['sources']+m['files']:w.writerow([f['file'],f['sha256'],f.get('kind','source'),'built-in ImageGen source' if f in m['sources'] else 'explicit native reconstruction','PENDING','PENDING','false'])
    result=dict(artifact_integrity_pass=not errors,errors=errors,new_hostile_body_keys=56,new_portal_body_keys=4,biomes=3,terrain_tiles=48,props=15,effect_keys=21,actual_pattern_tests=9,desktop_captures=len(captures),rgba_export_bytes_estimate=m['estimated_all_export_rgba_bytes'],automatic_visual_or_device_acceptance=False)
    (ROOT/'VERIFICATION.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print(json.dumps(result,indent=2));raise SystemExit(bool(errors))

if __name__=='__main__':main()
