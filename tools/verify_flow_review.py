"""Verify native review art and current desktop capture provenance; never grants acceptance."""
from pathlib import Path
import hashlib,json,struct
R=Path(__file__).resolve().parents[1];D=R/'assets/production_drafts/2026-10-23/flow-v03'
def verify():
 errors=[];count=0
 def check(ok,label):
  if not ok:errors.append(label)
 manifest=json.loads((D/'MANIFEST.json').read_text(encoding='utf-8'))
 catalog=json.loads((R/'game/visual_review/catalog.json').read_text(encoding='utf-8'))
 check(not manifest['commercial_approved'] and not manifest['automatic_visual_acceptance'],'classification')
 check(len(manifest['clips']['run'])==8,'run_poses')
 for name in ['attack_axe','attack_axe_2','attack_axe_3']:
  keys=manifest['clips'][name];check(len(keys)==8 and sum(k['duration_ms'] for k in keys)==300,name+':timing')
  for key in keys:check(key['feet_edge_y']==180,name+':floor')
 for record in manifest['files']:
  p=(D/record['file']).resolve()
  check(p.is_relative_to(D.resolve()) and hashlib.sha256(p.read_bytes()).hexdigest()==record['sha256'],record['file']+':sha')
 for name in manifest['clips']:
  check([x['duration_ms'] for x in catalog['player']['clips'][name]]==[x['duration_ms'] for x in manifest['clips'][name]],name+':catalog')
 for folder,expected in [('game-review',16),('legacy-route-review',14),('room-review',52)]:
  report=json.loads((D/folder/'RENDER_REPORT.json').read_text(encoding='utf-8'))
  check(len(report['captures'])==expected,folder+':count')
  check(not report['commercial_approved'],folder+':classification')
  seen=set()
  for capture in report['captures']:
   path=(D/folder/capture['file']).resolve()
   check(path.is_relative_to((D/folder).resolve()) and capture['file'] not in seen,folder+':path')
   seen.add(capture['file']);raw=path.read_bytes()
   check(raw[:8]==b'\x89PNG\r\n\x1a\n' and list(struct.unpack('>II',raw[16:24]))==capture['size'],path.name+':dimensions')
   check(hashlib.sha256(raw).hexdigest()==capture['sha256'],path.name+':sha');count+=1
  for source,expected_sha in report['source_hashes'].items():
   raw=(R/'game'/source.removeprefix('res://')).read_text(encoding='utf-8').replace('\r\n','\n').encode('utf-8')
   check(hashlib.sha256(raw).hexdigest()==expected_sha,folder+':source:'+source)
  if folder=='game-review':check(report['new_build_physical_acceptance']=='PENDING' and not report['failures'],'new_build_acceptance')
 result=dict(integrity_pass=not errors,errors=errors,native_exports=len(catalog['files']),current_desktop_captures=count,new_build_physical_acceptance='PENDING',commercial_approved=False)
 print(json.dumps(result,ensure_ascii=False,indent=2));return not errors
if __name__=='__main__':raise SystemExit(not verify())
