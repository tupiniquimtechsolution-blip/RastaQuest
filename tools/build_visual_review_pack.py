"""Stage identified native exports for the isolated visual-review flavor."""
from pathlib import Path
import hashlib,json,shutil

REPO=Path(__file__).resolve().parents[1]
DRAFT=REPO/'assets/production_drafts/2026-10-22'
POLISH=REPO/'assets/production_drafts/2026-10-23/playable-visual-v01'
OUT=REPO/'game/visual_review'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    OUT.mkdir(parents=True,exist_ok=True);records={}
    def copy(source,dest):
        source=source.resolve();target=(OUT/dest).resolve()
        if not target.is_relative_to(OUT.resolve()):raise ValueError('outside review pack')
        target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
        records[dest]=dict(file=dest,sha256=sha(source),source=source.relative_to(REPO).as_posix())
        return dest
    def clips(keys,folder,prefix):
        result={}
        for key in keys:result.setdefault(key['clip'],[]).append(dict(file=copy(folder/key['file'],prefix+'/'+key['file']),duration_ms=key['duration_ms']))
        return result
    player={};body={
      'idle':('axe-idle-2x/player_idle_%02d.png',[200]*4),
      'run':('run-2x/player_run_%02d.png',[60]*6),
      'jump':('airborne-2x/jump_combined_%02d.png',[100]),
      'fall':('airborne-2x/fall_combined_%02d.png',[100]),
      'attack_axe':('combat-reaction-2x/attack_axe_%02d_combined.png',[50,70,90,90]),
      'attack_axe_air':('combat-reaction-2x/attack_axe_air_%02d_combined.png',[50,140,110]),
      'hurt':('combat-reaction-2x/hurt_%02d_combined.png',[90,90]),
      'death':('combat-reaction-2x/death_%02d_combined.png',[120,140,160,180])}
    for clip,(pattern,durations) in body.items():
        player[clip]=[dict(file=copy(DRAFT/(pattern%(i+1)),f'player/{clip}_{i+1:02}.png'),duration_ms=ms) for i,ms in enumerate(durations)]
    remaining=json.loads((DRAFT/'remaining-art-v01/MANIFEST.json').read_text())
    player['portal_enter']=[dict(file=copy(DRAFT/'remaining-art-v01'/key['combined_file'],f'player/portal_enter_{i+1:02}.png'),duration_ms=90) for i,key in enumerate(remaining['portal_body']['frames'])]
    hero=dict(clips=player,dropped_weapon=copy(DRAFT/'combat-reaction-2x/death_01_weapon.png','player/dropped_weapon.png'))
    portal=dict(clips={'idle':[dict(file=copy(DRAFT/'effects-2x/fx_portal_interaction_02.png','portal/idle.png'),duration_ms=200)],'enter':[dict(file=copy(DRAFT/f'effects-2x/fx_portal_interaction_{i:02}.png',f'portal/enter_{i:02}.png'),duration_ms=90) for i in range(1,5)]})
    chaser=json.loads((DRAFT/'forest-chaser-polish/MANIFEST.json').read_text());keys={}
    for key in chaser['chaser']['frames']:keys.setdefault(key['clip'],[]).append(key)
    actors={'chaser':dict(canvas=256,clips=clips(chaser['chaser']['frames'],DRAFT/'forest-chaser-polish','chaser'),equipment=dict(sword=copy(DRAFT/'forest-chaser-polish/chaser_sword.png','chaser/sword.png'),shield=copy(DRAFT/'forest-chaser-polish/chaser_shield.png','chaser/shield.png'),keys=keys))}
    polished=json.loads((POLISH/'MANIFEST.json').read_text())
    for role,spec in polished['actors'].items():
        actor=dict(canvas=256,patterns=spec['patterns'],clips=clips(spec['frames'],POLISH,'polished'))
        if 'equipment' in spec:
            rig=spec['equipment'].copy();rig['file']=copy(POLISH/rig['file'],'polished/'+rig['file']);actor['equipment']=rig
        actors[role]=actor
    for role in ['storm_warden','rift_sovereign']:
        actor=remaining['actors'][role];actors[role]=dict(canvas=512,patterns=actor['patterns'],clips=clips(actor['frames'],DRAFT/'remaining-art-v01','remaining'))
    environments={}
    for biome in ['forest','castle','caves','hub']:
        folder=DRAFT/('forest-chaser-polish' if biome=='forest' else 'remaining-art-v01/environments/'+biome)
        bg=DRAFT/'forest-chaser-proof/forest_background.png' if biome=='forest' else folder/'background.png'
        # Windows globs are case-insensitive: do not accidentally package the
        # uppercase TERRAIN_KIT_REVIEW contact sheet as a native gameplay tile.
        tiles={p.stem.removeprefix('terrain_'):copy(p,f'environments/{biome}/'+p.name) for p in sorted(folder.glob('terrain_*.png')) if p.name.startswith('terrain_')}
        props=list((DRAFT/'forest-chaser-proof').glob('forest_rubble.png')) if biome=='forest' else sorted(folder.glob('prop_*.png'))[2:]
        environments[biome]=dict(background=copy(bg,f'environments/{biome}/background.png'),tiles=tiles,props=[copy(p,f'environments/{biome}/'+p.name) for p in props])
    effects={kind:[copy(DRAFT/'remaining-art-v01'/key['file'],'effects/'+Path(key['file']).name) for key in spec['frames']] for kind,spec in remaining['effects'].items()}
    data=dict(schema=1,commercial_approved=False,classification='visual-review-only',pending_gates=['exact-version visual review','rights/terms evidence','cultural review','physical GalaxyA13 QA'],source_base='e83da3c58445acf1e847b7e75457400051b26058',player=hero,portal=portal,actors=actors,environments=environments,effects=effects,files=list(records.values()))
    (OUT/'catalog.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
    print(f'RQ_VISUAL_PACK_BUILT native_exports={len(records)} actors={len(actors)} commercial_approved=false')
if __name__=='__main__':main()
