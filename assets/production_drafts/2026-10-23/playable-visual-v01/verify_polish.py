"""Native art and actual capture integrity, never final human approval."""
from pathlib import Path
from PIL import Image
import csv,hashlib,json

ROOT=Path(__file__).resolve().parent
REPO=ROOT.parents[3]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    m=json.loads((ROOT/'MANIFEST.json').read_text());errors=[]
    def check(ok,label):
        if not ok:errors.append(label)
    for record in m['files']+m['sources']:
        p=ROOT/record['file'];check(sha(p)==record['sha256'],record['file']+':hash')
        check(list(Image.open(p).size)==record['size'],record['file']+':size')
        if record.get('kind') in ['body','rigid_equipment']:
            im=Image.open(p).convert('RGBA');check(set(im.getchannel('A').tobytes())<={0,255},record['file']+':binary_alpha')
            check(len({rgb[:3] for rgb in im.getdata() if rgb[3]})<=32,record['file']+':palette')
            if record['kind']=='body':check(im.getchannel('A').getbbox()[3]==186,record['file']+':floor')
    for role,spec in m['actors'].items():
        move=[x for x in spec['frames'] if x['clip']=='move'];check(len(move)==6 and len({sha(ROOT/x['file']) for x in move})==6,role+':six_distinct_walk_keys')
        check(spec['clips']==dict(idle=2,move=6,tell=2,attack=2,hurt=2,death=2),role+':clips')
    check(not m['commercial_approved'] and m['visual_acceptance']=='PENDING','unearned_approval')
    report=json.loads((ROOT/'room-review/RENDER_REPORT.json').read_text());check(len(report['captures'])==52,'capture_count')
    for capture in report['captures']:
        p=ROOT/'room-review'/capture['file'];check(sha(p)==capture['sha256'],capture['file']+':hash');check(list(Image.open(p).size)==capture['size'],capture['file']+':size')
    for source,expected in report['source_hashes'].items():
        text=(REPO/'game'/source.removeprefix('res://')).read_text(encoding='utf-8');check(hashlib.sha256(text.encode()).hexdigest()==expected,'capture_source:'+source)
    check(report['human_acceptance']=='PENDING' and not report['commercial_approved'],'unearned_capture_approval')
    with (ROOT/'AUTHORING_PROVENANCE.csv').open('w',encoding='utf-8',newline='') as stream:
        writer=csv.writer(stream);writer.writerow(['file','sha256','method','rights_status','cultural_review','commercial_approved'])
        for f in m['sources']+m['files']:writer.writerow([f['file'],f['sha256'],'ImageGen source' if f in m['sources'] else 'explicit native reconstruction','PENDING','PENDING','false'])
    result=dict(native_integrity_pass=not errors,errors=errors,body_keys=64,rigid_masters=2,walk_keys_per_role=6,actual_desktop_captures=len(report['captures']),human_visual_acceptance='PENDING',commercial_approved=False)
    (ROOT/'VERIFICATION.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print(json.dumps(result,indent=2));raise SystemExit(bool(errors))
if __name__=='__main__':main()
