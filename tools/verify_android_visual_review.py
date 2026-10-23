"""Confirm review catalog and imported textures are present in the ACTUAL APK."""
import argparse,hashlib,json,re,subprocess,zipfile
from pathlib import Path

def verify(apk:Path,output:Path):
    with zipfile.ZipFile(apk) as archive:
        names=set(archive.namelist());path='assets/visual_review/catalog.json'
        if path not in names:raise ValueError('Review catalog absent from APK')
        raw=archive.read(path);catalog=json.loads(raw)
        expected=json.loads((Path(__file__).resolve().parents[1]/'game/visual_review/catalog.json').read_text(encoding='utf-8'))
        if catalog!=expected:raise ValueError('APK catalog differs from tested source catalog')
        if catalog.get('commercial_approved') is not False or catalog.get('classification')!='visual-review-only':raise ValueError('Invalid review classification')
        for name in names:
            if set(name.split('/')) & {'tests','production_drafts','concepts'}:raise ValueError('Forbidden preview payload '+name)
        for record in catalog['files']:
            # Exported PNG is remapped to an imported engine texture. Verify both
            # the exact resource remap and its actual destination archive member.
            import_path='assets/visual_review/'+record['file']+'.import'
            if import_path not in names:raise ValueError('Texture remap absent '+import_path)
            text=archive.read(import_path).decode('utf-8')
            destinations=re.findall(r'path(?:\.\w+)?="res://([^\"]+)"',text)
            if not destinations or not any('assets/'+p in names for p in destinations):raise ValueError('Imported texture absent '+import_path)
    result=dict(apk_sha256=hashlib.sha256(apk.read_bytes()).hexdigest(),source_commit=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),catalog_sha256=hashlib.sha256(raw).hexdigest(),packaged_native_resources=len(catalog['files']),review_payload_present=True,commercial_approved=False,physical_device_acceptance=False)
    output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print('RQ_ANDROID_VISUAL_PAYLOAD_OK resources='+str(result['packaged_native_resources']))
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('apk',type=Path);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();verify(args.apk,args.output)
