"""Saved screenshot integrity, not visual/device acceptance."""
import hashlib,json
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]

def main():
    errors=[];counts={}
    for folder in ['room-review','forest-room-review']:
        p=ROOT/'assets/production_drafts/2026-10-22'/folder
        m=json.loads((p/'RENDER_REPORT.json').read_text(encoding='utf-8'))
        counts[folder]=len(m['captures'])
        for f in m['captures']:
            path=p/f['file']
            if hashlib.sha256(path.read_bytes()).hexdigest()!=f['sha256']:errors.append(f['file']+':hash')
            if list(Image.open(path).size)!=f['size']:errors.append(f['file']+':size')
        for source,expected in m['source_hashes'].items():
            path=ROOT/'game'/source.removeprefix('res://')
            actual=hashlib.sha256(path.read_text(encoding='utf-8').encode('utf-8')).hexdigest()
            if actual!=expected:errors.append(folder+':source:'+source)
        if folder=='forest-room-review':
            by_name={f['file']:f for f in m['captures']}
            for name,phase,clip in [('chaser_tell_1280x720.png','tell','tell'),('chaser_active_1280x720.png','active','attack')]:
                if by_name[name]['enemy_phase']!=phase or by_name[name]['enemy_clip']!=clip:errors.append(name+':phase')
            if by_name['room_portal_mid_1280x720.png']['player_state']!='portal_enter':errors.append('portal_capture_state')
            if by_name['framing_proposal_1280x720.png']['camera_local_y']!=-154.0 or by_name['room_idle_1280x720.png']['camera_local_y']!=-40.0:errors.append('framing_label')
        if m['human_acceptance']!='PENDING' or m['runtime_asset_promotion']:errors.append(folder+':unearned_approval')
    report={'capture_integrity_pass':not errors,'errors':errors,'captures':counts,'automatic_visual_acceptance':False}
    print(json.dumps(report,indent=2));raise SystemExit(0 if not errors else 1)

if __name__=='__main__':main()
