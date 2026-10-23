"""Current polish capture provenance; earlier packets stay pinned to their own commits."""
from pathlib import Path
import hashlib,json,struct
R=Path(__file__).resolve().parents[1];D=R/'assets/production_drafts/2026-10-23/polish-v04/game-review'
def verify():
 errors=[];report=json.loads((D/'RENDER_REPORT.json').read_text(encoding='utf-8'))
 def check(ok,label):
  if not ok:errors.append(label)
 check(not report['commercial_approved'] and report['physical_acceptance']=='PENDING' and not report['failures'],'classification/results')
 check(len(report['captures'])==16,'capture_count')
 seen=set()
 for item in report['captures']:
  p=(D/item['file']).resolve()
  check(p.is_relative_to(D.resolve()) and item['file'] not in seen,'capture_path')
  seen.add(item['file']);raw=p.read_bytes()
  check(raw[:8]==b'\x89PNG\r\n\x1a\n' and list(struct.unpack('>II',raw[16:24]))==item['size'],item['file']+':png')
  check(hashlib.sha256(raw).hexdigest()==item['sha256'],item['file']+':sha')
 for source,expected in report['source_hashes'].items():
  p=R/'game'/source.removeprefix('res://')
  check(hashlib.sha256(p.read_text(encoding='utf-8').replace('\r\n','\n').encode('utf-8')).hexdigest()==expected,'current_source:'+source)
 result=dict(integrity_pass=not errors,errors=errors,current_polish_captures=len(seen),physical_acceptance='PENDING',commercial_approved=False)
 print(json.dumps(result,indent=2));return not errors
if __name__=='__main__':raise SystemExit(not verify())
