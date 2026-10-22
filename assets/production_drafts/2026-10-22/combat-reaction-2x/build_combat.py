"""Reproducible pose studies + independent rigid axe; not shipping/final art."""
import importlib.util
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops

ROOT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('rig', ROOT.parent/'axe-idle-2x/build_pack.py')
rig = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rig)

# Coordinates are estimated by inspecting the generated sheets, not accepted
# anatomy markers. A single density per sheet; never scale individual poses.
CONFIG = {
    'attack_axe': {'source':'ground-compact-source.png', 'scale':104/450,
        'crops':[(0,0,627,627),(627,0,1254,627),(0,627,627,1254),(627,627,1254,1254)],
        'hips':[(350,340),(323,350),(355,298),(335,328)],
        'grips':[(494,247),(414,360),(490,333),(421,403)],
        'angles':[55,80,100,90], 'durations':[40,40,40,40], 'ground':True},
    'attack_axe_air': {'source':'air-compact-source.png', 'scale':0.19,
        'crops':[(0,0,724,724),(724,0,1448,724),(1448,0,2172,724)],
        'hips':[(420,330),(405,380),(430,400)],
        'grips':[(612,247),(620,370),(455,420)],
        'angles':[55,85,100], 'durations':[50,55,55], 'ground':False},
    'hurt': {'source':'hurt-body-source.png', 'scale':104/650,
        'crops':[(0,0,887,887),(887,0,1774,887)],
        'hips':[(550,420),(490,480)], 'grips':[(698,350),(643,550)],
        'angles':[90,90], 'durations':[90,90], 'ground':True},
    'death': {'source':'death-body-source.png', 'scale':104/450,
        'crops':[(0,0,887,580),(887,0,1774,580),(0,580,887,887),(887,580,1774,887)],
        'hips':[(500,300),(340,397),(440,180),(500,200)],
        'grips':[(600,390),None,None,None],
        'angles':[90,None,None,None], 'durations':[120,140,160,180], 'ground':True},
}

def save(im, name, files):
    path=ROOT/name
    path.parent.mkdir(parents=True,exist_ok=True)
    im.save(path)
    files.append({'file':name,'sha256':rig.sha(path)})

def place_rigid(source, angle, grip):
    # Canvas larger than a frame proves no visible pixels were cropped.
    rotated=source.rotate(-angle, resample=Image.Resampling.NEAREST,center=(128,128))
    wide=Image.new('RGBA',(768,768))
    wide.paste(rotated,(256+grip[0]-128,256+grip[1]-128))
    bounds=wide.getchannel('A').getbbox()
    if bounds and (bounds[0]<256 or bounds[1]<256 or bounds[2]>512 or bounds[3]>512):
        raise ValueError(f'Weapon outside frame: angle={angle},grip={grip},bbox={bounds}')
    return wide.crop((256,256,512,512))

def main():
    rigid_path=ROOT.parent/'axe-idle-2x/weapon_double_axe_vertical_01.png'
    rigid=Image.open(rigid_path).convert('RGBA')
    blade=Image.open(ROOT.parent/'axe-idle-2x/layers/axe_head.png').convert('RGBA')
    files, frames, sources = [], [], []
    board=Image.new('RGB',(1536,4*420),'#142024')
    draw=ImageDraw.Draw(board)
    for row,(clip,cfg) in enumerate(CONFIG.items()):
        source=Image.open(ROOT/cfg['source']).convert('RGBA')
        sources.append({'file':cfg['source'],'sha256':rig.sha(ROOT/cfg['source']),
                        'size':list(source.size),'shared_scale':cfg['scale']})
        reviews=[]
        atlas=Image.new('RGBA',(256*len(cfg['crops']),256))
        for i,rect in enumerate(cfg['crops']):
            scale=cfg['scale']
            crop=source.crop(rect)
            reduced=rig.palette_map(crop.resize((round(crop.width*scale),round(crop.height*scale)),Image.Resampling.BOX))
            hip=cfg['hips'][i]
            ox=130-round(hip[0]*scale)
            oy=180-reduced.getchannel('A').getbbox()[3] if cfg['ground'] else 120-round(hip[1]*scale)
            body=Image.new('RGBA',(256,256))
            body.paste(reduced,(ox,oy))
            bounds=body.getchannel('A').getbbox()
            if bounds is None or bounds[0]<=0 or bounds[1]<=0 or bounds[2]>=256 or bounds[3]>=256:
                raise ValueError(f'Body clipped: {clip}{i+1}')
            weapon,head,fist=[Image.new('RGBA',(256,256)) for _ in range(3)]
            grip=None
            angle=cfg['angles'][i]
            if cfg['grips'][i] is not None:
                sg=cfg['grips'][i]
                grip=(round(sg[0]*scale)+ox,round(sg[1]*scale)+oy)
                weapon=place_rigid(rigid,angle,grip)
                head=place_rigid(blade,angle,grip)
                r=(grip[0]-6,grip[1]-6,grip[0]+7,grip[1]+7)
                fist.paste(body.crop(r),(r[0],r[1]))
                if body.getpixel(grip)[3]!=255:
                    raise ValueError(f'Grip not opaque: {clip}{i+1}: {grip}')
                overlap=ImageChops.multiply(body.getchannel('A'),head.getchannel('A')).getbbox()
                if overlap:
                    raise ValueError(f'Blade intersects body: {clip}{i+1}: {overlap}')
                if cfg['ground'] and head.getchannel('A').getbbox()[3]>180:
                    raise ValueError(f'Blade below floor: {clip}{i+1}')
            combined=Image.alpha_composite(Image.alpha_composite(body,weapon),fist)
            stem=f'{clip}_{i+1:02}'
            names={}
            for layer,im in [('body',body),('weapon',weapon),('blades',head),('grip',fist),('combined',combined)]:
                name=f'{stem}_{layer}.png'
                save(im,name,files)
                names[layer]=name
            atlas.paste(combined,(i*256,0))
            frame={'clip':clip,'index':i+1,'files':names,'duration_ms':cfg['durations'][i],
                'origin':[128,128],'source_crop':rect,'source_hip_estimated':hip,
                'source_grip_estimated':cfg['grips'][i],'source_scale':scale,'offset':[ox,oy],
                'weapon_grip':grip,'weapon_clockwise_degrees':angle,'body_alpha_bbox':bounds,
                'ground_contact':cfg['ground'],'ground_edge_y':180 if cfg['ground'] else None,
                'body_bottom_y':bounds[3], 'foot_displacement_vs_rest':bounds[3]-180 if not cfg['ground'] else None,
                'weapon_dropped_world_prop_pending':clip=='death' and i>0}
            frames.append(frame)
            bg=Image.new('RGBA',(256,256),'#142024');bg.alpha_composite(combined)
            if cfg['ground']:
                ImageDraw.Draw(bg).line((0,180,255,180),fill='#7a8376')
            reviews.append(bg.convert('RGB').resize((768,768),Image.Resampling.NEAREST))
            cell=bg.convert('RGB').resize((384,384),Image.Resampling.NEAREST)
            board.paste(cell,(i*384,row*420+24))
            draw.text((i*384+12,row*420+9),f'{clip} {i+1} / {cfg["durations"][i]}ms',fill='#efcf81')
        save(atlas,f'{clip}_atlas.png',files)
        # Longer pause is a REVIEW ONLY interval, not a gameplay animation key.
        review_frames=reviews+[reviews[-1]]
        reviews[0].save(ROOT/f'{clip.upper()}_REVIEW.gif',save_all=True,append_images=review_frames[1:],
            duration=cfg['durations']+[700],loop=0,optimize=False)
    board.save(ROOT/'COMBAT_REACTION_REVIEW.png')
    manifest={'classification':'COMBAT_REACTION_AUTHORING_PROTOTYPES_NOT_FINAL',
        'frame':[256,256],'render_scale':0.5,'palette_hex':rig.PALETTE,
        'method':'New generated body-only sheets; uniform density per sheet, explicit BOX reduction, fixed32-color/binary-alpha mapping; estimated landmarks; floor/pelvis translation; existing rigid weapon rotated with nearest and fist occlusion. Not native hand cleanup.',
        'sources':sources,'weapon_source':'../axe-idle-2x/weapon_double_axe_vertical_01.png',
        'weapon_sha256':rig.sha(rigid_path),'frames':frames,'files':files,
        'gameplay_contract':{'attack_axe_ms':160,'attack_axe_air_ms':160,'hurt_ms':180,
            'damage_starts_immediately':True,'animation_controls_damage':False,
            'death_proposed_ms':600,'death_scene_transition_lifetime':'PENDING_RUNTIME_CHANGE',
            'death_dropped_weapon':'separate world prop still pending; no weapon silently shrunk/redrawn in collapse'},
        'rejected_fit_sources':['ground-body-source.png','air-body-source.png'],
        'new_pose_visual_acceptance':'PENDING','model_geometry':'PENDING','palette_in_room':'PENDING',
        'rights_clearance':'PENDING','final_cultural_review':'PENDING','runtime_promotion':False,
        'review_gif_extra_hold_ms':700,'review_extra_hold_is_gameplay_timing':False,
        'remaining':['lightning_proc','portal_enter','manual pixel/anatomy/motion cleanup','in-game model/palette QA','death lifetime/drop hook','Forest/Chaser and remaining art']}
    (ROOT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'frames':len(frames),'clips':list(CONFIG),'sources':sources},indent=2))

if __name__=='__main__':main()
