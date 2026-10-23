"""Verify current rendered evidence, never promote it to physical/human acceptance."""
from pathlib import Path
import hashlib,json,struct,subprocess

REPO=Path(__file__).resolve().parents[1]
ROOT=REPO/'assets/production_drafts/2026-10-23/a13-feedback-v02'

def verify():
    errors=[];count=0
    def check(ok,label):
        if not ok:errors.append(label)
    for folder,expected_count in [('game-review',14),('room-review',52)]:
        report=json.loads((ROOT/folder/'RENDER_REPORT.json').read_text(encoding='utf-8'))
        check(len(report['captures'])==expected_count,folder+':count')
        check(report['commercial_approved'] is False,folder+':classification')
        for capture in report['captures']:
            path=(ROOT/folder/capture['file']).resolve()
            check(path.is_relative_to((ROOT/folder).resolve()),folder+':path')
            raw=path.read_bytes();check(raw[:8]==b'\x89PNG\r\n\x1a\n',path.name+':png')
            check(list(struct.unpack('>II',raw[16:24]))==capture['size'],path.name+':dimensions')
            check(hashlib.sha256(raw).hexdigest()==capture['sha256'],path.name+':hash');count+=1
        for source,expected in report['source_hashes'].items():
            path=REPO/'game'/source.removeprefix('res://')
            raw=subprocess.check_output(['git','show','ee4c840b02726fecffb56cf906738999e6ca3ad1:game/'+source.removeprefix('res://')],cwd=REPO).decode('utf-8').replace('\r\n','\n').encode()
            check(hashlib.sha256(raw).hexdigest()==expected,folder+':input:'+source)
        if folder=='game-review':
            check(report['new_build_physical_acceptance']=='PENDING','new_build_acceptance')
            check({r['biome'] for r in report['routes']}=={'forest','castle','caves'},'routes:biomes')
            for route in report['routes']:
                check(route['traversed_x']>=route['width']-300 and route['camera_delta']>1800,route['biome']+':scroll')
        else:
            check(report['human_acceptance']=='PENDING','roster_acceptance')
    result=dict(integrity_pass=not errors,errors=errors,actual_desktop_captures=count,physical_feedback_previous_version='reported_by_Rodrigo_partial_acceptance',new_build_physical_acceptance='PENDING',commercial_approved=False)
    (ROOT/'VERIFICATION.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result,ensure_ascii=False,indent=2));return not errors

if __name__=='__main__':raise SystemExit(not verify())
