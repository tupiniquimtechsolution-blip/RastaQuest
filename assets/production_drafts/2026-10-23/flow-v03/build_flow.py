"""Reconstruct declared motion studies; native review exports, no final acceptance."""
from pathlib import Path
import importlib.util,json,hashlib,math
from PIL import Image,ImageChops,ImageDraw
D=Path(__file__).resolve().parent
R=D.parents[3]; OLD=R/'assets/production_drafts/2026-10-22'
spec=importlib.util.spec_from_file_location('rig',OLD/'axe-idle-2x/build_pack.py')
rig=importlib.util.module_from_spec(spec);spec.loader.exec_module(rig)
def save(im,name):
 p=D/name;p.parent.mkdir(parents=True,exist_ok=True);im.save(p)
 return dict(file=name,sha256=rig.sha(p))
def slide(im,offset):
 out=Image.new('RGBA',(256,256));out.paste(im,offset);return out
def review(images,name,durations):
 screens=[]
 for im in images:
  bg=Image.new('RGBA',(256,256),'#192126');bg.alpha_composite(im);screens.append(bg.convert('RGB').resize((768,768),Image.Resampling.NEAREST))
 screens[0].save(D/(name+'.gif'),save_all=True,append_images=screens[1:],duration=durations,loop=0,optimize=False)
 board=Image.new('RGB',(2048,512*math.ceil(len(images)/4)),'#192126')
 for i,im in enumerate(screens):board.paste(im.resize((512,512),Image.Resampling.NEAREST),(i%4*512,i//4*512))
 board.save(D/(name+'.png'))
def main():
 files=[]; clips={}
 src=Image.open(D/'run-source.png').convert('RGBA')
 torso=Image.open(OLD/'run-2x/layers/torso.png').convert('RGBA')
 arms=Image.open(OLD/'run-2x/layers/arms.png').convert('RGBA')
 weapon=Image.open(OLD/'run-2x/layers/weapon_in_hand.png').convert('RGBA')
 fist=Image.open(OLD/'axe-idle-2x/layers/grip_occlusion.png').convert('RGBA')
 bounds=[0,520,910,1330,1774];hips=[280,718,1154,1594,293,727,1155,1590]
 scale=60/302;run=[];runkeys=[]
 for i in range(8):
  row=i//4;x=bounds[i%4];y=row*444
  cell=src.crop((x,y,bounds[i%4+1],min(887,y+444)))
  small=rig.palette_map(cell.resize((round(cell.width*scale),round(cell.height*scale)),Image.Resampling.BOX))
  lower=Image.new('RGBA',(256,256));lower.paste(small,(130-round((hips[i]-x)*scale),120-round((107 if row==0 else 71)*scale)))
  contact=i%4!=3;fix=180-lower.getchannel('A').getbbox()[3] if contact else 0
  lower=slide(lower,(0,fix));lift=[0,2,3,2][i%4]
  # Shared upper rig preserves identity; only eight new lower poses are authored.
  body=Image.alpha_composite(lower,slide(torso,(0,-lift)))
  body=Image.alpha_composite(body,slide(arms,(0,-lift)))
  combined=Image.alpha_composite(body,slide(weapon,(0,-lift)))
  combined=Image.alpha_composite(combined,slide(fist,(0,-lift)))
  name=f'run_{i+1:02}.png';files.append(save(combined,name));files.append(save(body,f'layers/run_body_{i+1:02}.png'))
  run.append(combined);runkeys.append(dict(file=name,duration_ms=60,body_key=i+1,ground_contact=contact,feet_edge_y=lower.getchannel('A').getbbox()[3],contact_translation=fix,hip_estimated=[hips[i]-x,107 if row==0 else 71]))
 clips['run']=runkeys;review(run,'RUN_REVIEW',[60]*8)
 src=Image.open(D/'combat-source.png').convert('RGBA'); w,h=src.size;scale=104/363
 master=Image.open(OLD/'axe-idle-2x/weapon_double_axe_vertical_01.png').convert('RGBA')
 hips=[237,236,242,247,234,231,234,239]
 grips=[(136,127),(384,211),(377,211),(334,244),(205,23),(372,233),(375,290),(330,280)]
 bodies=[];nativegrips=[]
 for i in range(8):
  x=i%4*w//4;y=i//4*h//2;cell=src.crop((x,y,(i%4+1)*w//4,(i//4+1)*h//2))
  small=rig.palette_map(cell.resize((round(cell.width*scale),round(cell.height*scale)),Image.Resampling.BOX))
  floor=[415,415,415,415,413,412,412,411][i]
  base=(128-round(hips[i]*scale),180-round(floor*scale))
  body=Image.new('RGBA',(256,256));body.paste(small,base)
  correction=180-body.getchannel('A').getbbox()[3];body=slide(body,(0,correction))
  grip=(base[0]+round(grips[i][0]*scale),base[1]+round(grips[i][1]*scale)+correction)
  files.append(save(body,f'layers/combat_body_{i+1:02}.png'));bodies.append(body);nativegrips.append(grip)
 for clip,indices,angles in [('attack_axe',[0,1,2,3],[-70,60,110,155]),('attack_axe_2',[4,5,6,7],[-15,60,145,170]),('attack_axe_3',[7,6,5,4],[125,85,40,-15])]:
  keys=[];images=[]
  for k,index in enumerate(indices):
   body=bodies[index];grip=nativegrips[index]
   for half in range(2):
    angle=angles[k] if half==0 or k==3 else (angles[k]+angles[k+1])*.5
    pivot=((128,128) if index==7 else (128,110)) if clip=='attack_axe_3' else ((128,145) if index in [3,6,7] else (128,110))
    rotated=master.rotate(-angle,resample=Image.Resampling.NEAREST,center=pivot)
    layer=slide(rotated,(grip[0]-pivot[0],grip[1]-pivot[1]))
    # Explicit fist occlusion; rigid axe master never redrawn between poses.
    combined=Image.alpha_composite(body,layer)
    combined.alpha_composite(body.crop((grip[0]-4,grip[1]-4,grip[0]+5,grip[1]+5)),(grip[0]-4,grip[1]-4))
    n=len(keys)+1;name=f'{clip}_{n:02}.png';files.append(save(combined,name));images.append(combined)
    keys.append(dict(file=name,duration_ms=[25,35,45,45][k],body_key=index+1,grip=list(grip),angle_clockwise=angle,weapon_grip=list(pivot),origin=[128,128],feet_edge_y=body.getchannel('A').getbbox()[3]))
  clips[clip]=keys;review(images,clip.upper()+'_REVIEW',[k['duration_ms'] for k in keys])
 for f in files:
  im=Image.open(D/f['file']).convert('RGBA')
  colors={p[:3] for p in im.getdata() if p[3]}
  assert im.size==(256,256) and len(colors)<=32 and {p[3] for p in im.getdata()}<={0,255},f
 data=dict(classification='VISUAL_REVIEW_ONLY',commercial_approved=False,source_hashes={p.name:rig.sha(p) for p in [D/'run-source.png',D/'combat-source.png',OLD/'axe-idle-2x/weapon_double_axe_vertical_01.png']},native_body_keys=16,run_lower_poses=8,combat_body_poses=8,combat_rig_keys=24,method='ImageGen source studies; single density scales, estimated hips/grips, BOX palette32 binary alpha, declared contact translations; 8 new lower poses share upper rig; 8 combat body poses with rigid master; third rising combo reverses the four overhead bodies with a rising arc. Interpolated weapon-only keys do not claim additional authored body poses.',clips=clips,files=files,remaining_gates=['exact-version native visual approval','physical Galaxy A13 movement/attack/defense review','rights and cultural evidence'],automatic_visual_acceptance=False)
 (D/'MANIFEST.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8',newline='\n')
 print('FLOW_ART_BUILT',len(files))
if __name__=='__main__':main()
