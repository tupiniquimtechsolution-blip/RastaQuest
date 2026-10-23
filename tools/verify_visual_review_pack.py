"""Hash/contract checks without extra dependencies; does not grant approval."""
from pathlib import Path
import hashlib,json

ROOT=Path(__file__).resolve().parents[1]
def verify():
    folder=ROOT/'game/visual_review';catalog=json.loads((folder/'catalog.json').read_text());errors=[]
    def check(ok,label):
        if not ok:errors.append(label)
    check(catalog['schema']==1 and catalog['commercial_approved'] is False,'classification')
    seen=set()
    for record in catalog['files']:
        file=record['file'];p=(folder/file).resolve();source=(ROOT/record['source']).resolve()
        check(p.is_relative_to(folder.resolve()) and source.is_relative_to((ROOT/'assets/production_drafts').resolve()),file+':path')
        check(p.exists() and hashlib.sha256(p.read_bytes()).hexdigest()==record['sha256'],file+':pack_hash')
        check(source.exists() and hashlib.sha256(source.read_bytes()).hexdigest()==record['sha256'],file+':source_hash')
        check(file not in seen,file+':duplicate');seen.add(file)
    check(set(catalog['actors'])=={'chaser','ranged','charger','controller','exploder','storm_warden','rift_sovereign'},'roles')
    for role in ['ranged','charger','controller','exploder']:
        counts={k:len(v) for k,v in catalog['actors'][role]['clips'].items()}
        check(counts==dict(idle=2,move=6,tell=2,attack=2,hurt=2,death=2),role+':clips')
    for role in ['ranged','controller']:
        actor=catalog['actors'][role];rig=actor['equipment']
        for clip,frames in actor['clips'].items():check(len(rig['keys'][clip])==len(frames),role+clip+':rig_keys')
        check(rig['file'] in seen,role+':master')
    check(len(catalog['player']['clips']['portal_enter'])==4,'portal_body')
    check(len(catalog['effects'])==7,'fx_families')
    check(set(catalog['environments'])=={'forest','castle','caves','hub'},'biomes')
    check({p.relative_to(folder).as_posix() for p in folder.rglob('*.png')}==seen,'unlisted_native_payload')
    terrain={'top_1','top_2','top_3','soil_1','soil_2','soil_3','top_left','top_right','side_left','side_right','bottom','bottom_left','bottom_right','isolated','inner_left','inner_right'}
    for biome,spec in catalog['environments'].items():check(set(spec['tiles'])==terrain,biome+':native_tiles_only')
    report=dict(pack_integrity_pass=not errors,errors=errors,native_exports=len(seen),polished_hostile_keys=64,rigid_masters=2,commercial_approved=False,automatic_visual_acceptance=False)
    print(json.dumps(report,indent=2));return report
if __name__=='__main__':raise SystemExit(not verify()['pack_integrity_pass'])
