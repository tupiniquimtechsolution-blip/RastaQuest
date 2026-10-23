"""Explicit authoring reconstruction from new independent sources, not final art."""
import hashlib,importlib.util,json
from pathlib import Path
from PIL import Image,ImageDraw,ImageChops

ROOT=Path(__file__).resolve().parent
SRC=ROOT/'sources'
spec=importlib.util.spec_from_file_location('base',ROOT.parent/'forest-chaser-proof/build_proof.py');base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
spec=importlib.util.spec_from_file_location('polish',ROOT.parent/'forest-chaser-polish/build_polish.py');polish=importlib.util.module_from_spec(spec);spec.loader.exec_module(polish)
digest=base.digest

def palette(im,count):
    # One common palette per actor/biome from visible source pixels only.
    rgba=im.convert('RGBA');raw=rgba.tobytes();visible=bytearray()
    for i in range(0,len(raw),4):
        if raw[i+3]>=200:visible.extend(raw[i:i+3])
    sample=Image.frombytes('RGB',(len(visible)//3,1),bytes(visible)).quantize(colors=count,dither=Image.Dither.NONE)
    return ['%02x%02x%02x'%tuple(sample.getpalette()[i:i+3]) for i in range(0,count*3,3)]

def opaque_bounds(im):return im.getchannel('A').point(lambda x:255 if x>=200 else 0).getbbox()

def main():
    files=[];actors={};environments={};fx={}
    def save(im,path,**extra):
        p=ROOT/path;p.parent.mkdir(parents=True,exist_ok=True);im.save(p);files.append(dict(file=path,sha256=digest(p),size=list(im.size),**extra))
    configs={
      'ranged':(4,[0,512,1024],128,256,186,['idle','move','move','tell','attack','hurt','death','death']),
      'charger':(4,[0,446,887],80,256,186,['idle','move','move','tell','attack','hurt','death','death']),
      'controller':(4,[0,515,1024],136,256,186,['idle','move','move','tell','attack','hurt','death','death']),
      'exploder':(4,[0,448,887],128,256,186,['idle','move','move','tell','attack','hurt','death','death']),
      'storm_warden':(3,[0,265,525,768,1024],224,512,368,['idle','idle','move','move','tell_storm_slam','attack_storm_slam','tell_chain_burst','attack_chain_burst','hurt','hurt','death','death']),
      'rift_sovereign':(3,[0,274,528,774,1024],224,512,368,['idle','move','tell_rift_slam','attack_rift_slam','tell_portal_burst','attack_portal_burst','tell_fracture_storm','attack_fracture_storm','hurt','hurt','death','death'])}
    for role,(cols,ys,height,canvas,feet,clips) in configs.items():
        sheet=Image.open(SRC/(role+'_body.png')).convert('RGBA');colors=palette(sheet,32)
        xs=[round(sheet.width*i/cols) for i in range(cols+1)]
        rects=[(xs[n%cols],ys[n//cols],xs[n%cols+1],ys[n//cols+1]) for n in range(len(clips))]
        # Measured overshoots, recorded explicitly instead of clipping a dash.
        if role=='charger':rects[4]=(0,446,530,887);rects[5]=(530,446,920,887);rects[6]=(920,446,1330,887)
        if role=='controller':rects[4]=(0,515,442,1024);rects[5]=(442,515,768,1024)
        if role=='ranged':rects[2]=(768,0,1130,512);rects[5]=(440,512,768,1024);rects[6]=(768,512,1130,1024)
        if role=='controller':rects[4]=(0,515,430,1024);rects[5]=(442,515,730,1024);rects[6]=(768,515,1100,1024)
        crops=[sheet.crop(r) for r in rects]
        first=opaque_bounds(crops[0]);factor=height/(first[3]-first[1]);records=[];counts={}
        review=Image.new('RGB',(1024,((len(clips)+3)//4)*256),'#151a20');draw=ImageDraw.Draw(review);animation=[];timings=[]
        for n,(clip,crop,rect) in enumerate(zip(clips,crops,rects)):
            scaled=base.mapped(crop.resize((round(crop.width*factor),round(crop.height*factor)),Image.Resampling.BOX),colors)
            removed=polish.clean_fragments(scaled);bounds=scaled.getchannel('A').getbbox()
            if bounds is None:raise ValueError(role+' empty source pose')
            # Same source scale across keys; center-of-mass estimates are explicit.
            center=(bounds[0]+bounds[2])//2
            if clip.startswith('attack') and role=='charger':center=round(300*factor)
            if clip=='attack' and role in ['ranged','controller']:center=round(crop.width*.58*factor)
            offset=(canvas//2-center,feet-bounds[3]);out=Image.new('RGBA',(canvas,canvas));out.paste(scaled,offset)
            counts[clip]=counts.get(clip,0)+1;index=counts[clip]
            ms=240 if clip=='idle' else (120 if clip=='move' else (100 if clip=='hurt' else (120 if index==1 else 200) if clip=='death' else 160))
            path=f'actors/{role}/{clip}_{index:02}.png';save(out,path,palette_limit=32,kind='body')
            records.append(dict(clip=clip,index=index,file=path,duration_ms=ms,source_crop=rect,source_scale=factor,offset=offset,removed_fragment_pixels=removed,alpha_bbox=list(out.getchannel('A').getbbox())))
            cell=Image.new('RGBA',(canvas,canvas),'#151a20');cell.alpha_composite(out);cell=cell.convert('RGB').resize((256,256),Image.Resampling.NEAREST)
            x,y=(n%4)*256,(n//4)*256;review.paste(cell,(x,y));draw.text((x+8,y+8),clip+' '+str(index),fill='#ecd09a');animation.append(cell.resize((512,512),Image.Resampling.NEAREST));timings.append(ms)
        save(review,f'reviews/{role}_keys.png',kind='source_preview')
        animation[0].save(ROOT/f'reviews/{role}_source_motion.gif',save_all=True,append_images=animation[1:],duration=timings,loop=0,disposal=2)
        patterns={role:['tell','attack']} if canvas==256 else ({'storm_slam':['tell_storm_slam','attack_storm_slam'],'chain_burst':['tell_chain_burst','attack_chain_burst']} if role=='storm_warden' else {p:['tell_'+p,'attack_'+p] for p in ['rift_slam','portal_burst','fracture_storm']})
        actors[role]=dict(canvas=canvas,origin=[canvas//2]*2,feet_edge_y=feet,render_scale=.5,palette_hex=colors,source_scale=factor,frames=records,clips=counts,patterns=patterns,final_motion_acceptance='PENDING')
    for biome in ['castle','caves','hub']:
        background=Image.open(SRC/(biome+'_background'+('_corrected' if biome=='hub' else '')+'.png')).convert('RGB');factor=max(1280/background.width,720/background.height)
        background=background.resize((round(background.width*factor),round(background.height*factor)),Image.Resampling.BOX);x=(background.width-1280)//2;y=(background.height-720)//2
        save(background.crop((x,y,x+1280,y+720)).quantize(colors=64,dither=Image.Dither.NONE).convert('RGB'),f'environments/{biome}/background.png',kind='background',palette_limit=64)
        source=Image.open(SRC/(biome+'_modules.png')).convert('RGBA')
        raw_material=Image.open(SRC/(biome+'_terrain.png')).convert('RGBA');w,h=raw_material.size
        material_rect=(round(w*.04),round(h*.09),round(w*.96),round(h*.95))
        material=raw_material.crop(material_rect) # excludes generated outer checker/white margin
        combined=Image.new('RGBA',(max(source.width,material.width),source.height+material.height));combined.paste(source,(0,0));combined.paste(material,(0,source.height));colors=palette(combined,24)
        # Measured source regions: generated atlases did not honor equal cells.
        rectangles={'castle':[(0,60,555,635),(570,0,1100,645),(1120,60,1536,645),(0,650,560,1024),(565,650,1100,1024),(1100,650,1536,1024)],
                    'caves':[(0,40,640,645),(640,0,1100,650),(1110,80,1536,650),(0,650,530,1024),(535,650,1060,1024),(1060,650,1536,1024)],
                    'hub':[(0,90,585,670),(590,0,1000,670),(1000,70,1536,670),(0,700,540,1024),(540,700,1000,1024),(1000,700,1536,1024)]}[biome]
        props=[]
        for index,(rect,size) in enumerate(zip(rectangles[1:],[(64,128),(64,64),(64,48),(32,32),(96,64)])):
            crop=source.crop(rect);b=opaque_bounds(crop);crop=crop.crop(b);s=min(size[0]/crop.width,size[1]/crop.height)
            im=base.mapped(crop.resize((max(1,round(crop.width*s)),max(1,round(crop.height*s))),Image.Resampling.BOX),colors);polish.clean_fragments(im)
            out=Image.new('RGBA',size);out.paste(im,((size[0]-im.width)//2,size[1]-im.height));path=f'environments/{biome}/prop_{index+1:02}.png';save(out,path,palette_limit=24,kind='prop');props.append(dict(file=path,canvas=size,source_crop=rect,collision=False))
        tops=[];soils=[]
        for i in range(3):
            w=material.width;h=material.height;start=round(i*(w*.20));crop=material.crop((start,round(h*(.48 if biome=='hub' else .20)),min(w,start+round(w*.58)),round(h*.95)))
            soil=base.mapped(crop.resize((32,32),Image.Resampling.BOX),colors,False)
            top=soil.copy();edge=material.crop((start,0,min(w,start+round(w*.58)),round(h*.14))).resize((32,5),Image.Resampling.BOX);top.paste(base.mapped(edge,colors,False),(0,0));tops.append(top);soils.append(soil)
        rgb=[tuple(bytes.fromhex(v)) for v in colors]
        def snap(values):return min(rgb,key=lambda c:sum((c[k]-values[k])**2 for k in range(3)))+(255,)
        for family in [tops,soils]:
            common=[snap([sum(im.getpixel((x,y))[k] for im in family for x in [4,8,23,27])/12 for k in range(3)]) for y in range(32)]
            for im in family:
                for y in range(32):
                    for distance,weight in [(0,1),(1,.66),(2,.33)]:
                        for x in [distance,31-distance]:
                            old=im.getpixel((x,y));im.putpixel((x,y),snap([old[k]*(1-weight)+common[y][k]*weight for k in range(3)]))
        join=[soils[0].getpixel((x,0)) for x in range(32)]
        for im in tops:
            for x in range(32):im.putpixel((x,31),join[x])
        for im in soils:
            for x in range(32):im.putpixel((x,0),join[x]);im.putpixel((x,31),join[x])
        tiles={**{'top_'+str(i+1):im for i,im in enumerate(tops)},**{'soil_'+str(i+1):im for i,im in enumerate(soils)}}
        def masked(im,poly):
            out=im.copy();a=Image.new('L',(32,32));ImageDraw.Draw(a).polygon(poly,fill=255);out.putalpha(a);return out
        tiles['top_left']=masked(tops[0],[(0,0),(31,0),(31,31),(5,31),(5,23),(2,18),(3,10),(0,5)]);tiles['top_right']=tiles['top_left'].transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        tiles['side_left']=masked(soils[0],[(5,0),(31,0),(31,31),(5,31),(5,23),(2,18),(3,10),(5,5)]);tiles['side_right']=tiles['side_left'].transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        tiles['bottom']=masked(soils[1],[(0,0),(31,0),(31,8),(27,8),(24,13),(20,10),(16,15),(12,10),(8,12),(4,9),(0,7)])
        for side in ['left','right']:
            mask=Image.new('L',(32,32));ImageDraw.Draw(mask).rectangle((5,0,31,31) if side=='left' else (0,0,26,31),fill=255);im=tiles['bottom'].copy();im.putalpha(ImageChops.multiply(im.getchannel('A'),mask));tiles['bottom_'+side]=im
        im=tops[2].copy();im.putalpha(ImageChops.multiply(tiles['top_left'].getchannel('A'),tiles['top_right'].getchannel('A')));tiles['isolated']=im
        for side in ['left','right']:
            im=soils[2].copy();a=im.getchannel('A');ImageDraw.Draw(a).rectangle((0,0,5,6) if side=='left' else (26,0,31,6),fill=0);im.putalpha(a);tiles['inner_'+side]=im
        for key,im in tiles.items():save(im,f'environments/{biome}/terrain_{key}.png',palette_limit=24,kind='terrain')
        environments[biome]=dict(tile_size=32,terrain=list(tiles),props=props,palette_hex=colors,material_source='sources/'+biome+'_terrain.png',material_source_crop=material_rect,edge_method='shared averaged edge with3px quantized feather; no dark source-border columns',background_colors=64,parallax=[.25,.65,1,1.08],wrap='alternating mirrored panels, not authored seamless',promotion=False)
    sheet=Image.open(SRC/'shared_fx.png').convert('RGBA');colors=['4a1713','762015','a52f13','d64c15','f7811f','ffb832','ffe269','fff4c2','8f4b1d','b66a24','d89932','eed66b']
    anchors=[[(215,173),(210,173),(180,183)],[(190,156),(180,156),(170,156)],[(256,128)]*3,[(258,118)]*3]
    fx_review=Image.new('RGB',(768,1024),'#151a20');d=ImageDraw.Draw(fx_review)
    for row,kind in enumerate(['hit','hostile_projectile','hostile_area','reward']):
        keys=[];native=[]
        for col in range(3):
            rect=(col*512,row*256,(col+1)*512,(row+1)*256);crop=sheet.crop(rect);im=base.mapped(crop.resize((128,64),Image.Resampling.BOX),colors);ax,ay=anchors[row][col];out=Image.new('RGBA',(128,128));offset=(64-round(ax*.25),64-round(ay*.25));out.paste(im,offset)
            native.append(out)
        if kind=='reward':
            # Lock one central shard; preserve only the changed outer glints.
            shard=native[0].crop((51,42,78,89))
            for im in native:ImageDraw.Draw(im).rectangle((51,42,77,88),fill=(0,0,0,0));im.paste(shard,(51,42))
        for col,out in enumerate(native):
            path=f'effects/{kind}_{col+1:02}.png';save(out,path,palette_limit=12,kind='fx');keys.append(dict(file=path,duration_ms=60,origin=[64,64]));cell=Image.new('RGBA',(128,128),'#151a20');cell.alpha_composite(out);fx_review.paste(cell.convert('RGB').resize((256,256),Image.Resampling.NEAREST),(col*256,row*256));d.text((col*256+8,row*256+8),kind+' '+str(col+1),fill='#ecd09a')
        fx[kind]=dict(frames=keys,source_scale=.25,canvas=128,scale=.5,palette_hex=colors,gameplay_authority=False,reduced_flashes='staticfirst or hidden; never modifies damage')
    save(fx_review,'reviews/SHARED_FX_REVIEW.png',kind='source_preview')
    electric=Image.open(SRC/'electric_shared.png').convert('RGBA')
    electric_colors=['071f2a','0d3b52','12627d','168db3','29b8d6','74dcef','b9f7fa','f4ffff']
    electric_review=Image.new('RGB',(768,768),'#151a20');d=ImageDraw.Draw(electric_review)
    for row,kind in enumerate(['electric_chain','electric_area','electric_onkill']):
        keys=[]
        for col in range(3):
            x0=round(col*electric.width/3);x1=round((col+1)*electric.width/3);y0=round(row*electric.height/3);y1=round((row+1)*electric.height/3)
            crop=electric.crop((x0,y0,x1,y1));im=base.mapped(crop.resize((128,85),Image.Resampling.BOX),electric_colors);out=Image.new('RGBA',(256,256));out.paste(im,(64,86))
            path=f'effects/{kind}_{col+1:02}.png';save(out,path,palette_limit=8,kind='fx');keys.append(dict(file=path,duration_ms=60,origin=[128,128]));cell=Image.new('RGBA',(256,256),'#151a20');cell.alpha_composite(out);electric_review.paste(cell.convert('RGB'),(col*256,row*256));d.text((col*256+8,row*256+8),kind+' '+str(col+1),fill='#ecd09a')
        fx[kind]=dict(frames=keys,source_scale=.25,canvas=256,scale=.5,palette_hex=electric_colors,gameplay_authority=False,anchor_status='centered candidate; chain endpoints/full hazard radius still need live binding review',reduced_flashes='static first or hidden; no damage change')
    save(electric_review,'reviews/ELECTRIC_FX_REVIEW.png',kind='source_preview')
    # New four-pose portal BODY study; reuse the same approved axe master.
    hero_palette=json.loads((ROOT.parent/'axe-idle-2x/MANIFEST.json').read_text())['palette_hex']
    hero=Image.open(SRC/'portal_body.png').convert('RGBA');hero_scale=104/470
    axe_path=ROOT.parent/'axe-idle-2x/weapon_double_axe_rotation_90_01.png'
    axe=Image.open(axe_path).convert('RGBA').rotate(8,resample=Image.Resampling.NEAREST,center=(128,128))
    grips=[(266,382),(229,392),(271,350),(258,349)];hips=[357,344,390,398];portal_keys=[];preview=[];board=Image.new('RGB',(1024,256),'#151a20');d=ImageDraw.Draw(board)
    for i in range(4):
        col=i%2;row=i//2;rect=(col*627,row*627,(col+1)*627,(row+1)*627);crop=hero.crop(rect);im=base.mapped(crop.resize((round(crop.width*hero_scale),round(crop.height*hero_scale)),Image.Resampling.BOX),hero_palette);polish.clean_fragments(im);b=im.getchannel('A').getbbox();offset=(128-round(hips[i]*hero_scale),180-b[3]);body=Image.new('RGBA',(256,256));body.paste(im,offset)
        grip=(round(grips[i][0]*hero_scale)+offset[0],round(grips[i][1]*hero_scale)+offset[1]);weapon=Image.new('RGBA',(256,256));weapon.paste(axe,(grip[0]-128,grip[1]-128))
        combined=Image.alpha_composite(body,weapon) if i<2 else Image.alpha_composite(weapon,body)
        if i<2:
            region=(grip[0]-7,grip[1]-9,grip[0]+8,grip[1]+10);fist=Image.new('RGBA',(256,256));fist.paste(body.crop(region),region[:2]);combined=Image.alpha_composite(combined,fist)
        for kind,art in [('body',body),('weapon',weapon),('combined',combined)]:save(art,f'portal/portal_enter_{i+1:02}_{kind}.png',palette_limit=32,kind='portal_'+kind)
        portal_keys.append(dict(index=i+1,body_file=f'portal/portal_enter_{i+1:02}_body.png',combined_file=f'portal/portal_enter_{i+1:02}_combined.png',weapon_file=f'portal/portal_enter_{i+1:02}_weapon.png',duration_ms=90,source_crop=rect,source_scale=hero_scale,offset=offset,grip=list(grip),weapon_degrees_from_horizontal=8,weapon_behind_body=i>=2))
        cell=Image.new('RGBA',(256,256),'#151a20');cell.alpha_composite(combined);board.paste(cell.convert('RGB'),(i*256,0));d.text((i*256+8,8),'portal '+str(i+1)+' | candidate',fill='#ecd09a');preview.append(cell.convert('RGB').resize((512,512),Image.Resampling.NEAREST))
    save(board,'reviews/PORTAL_BODY_REVIEW.png',kind='source_preview');preview[0].save(ROOT/'reviews/PORTAL_SOURCE_MOTION.gif',save_all=True,append_images=preview[1:],duration=90,loop=0,disposal=2)
    portal=dict(frames=portal_keys,canvas=256,origin=[128,128],feet_edge_y=180,palette_hex=hero_palette,body_metric_reference='source135..605 approximately104px; hair above headband separately retained',axe_master=dict(file='../axe-idle-2x/weapon_double_axe_rotation_90_01.png',sha256=digest(axe_path)),runtime_binding=False,visual_acceptance='PENDING')
    silhouette=Image.new('RGB',(1280,360),'#d7d2c5');d=ImageDraw.Draw(silhouette)
    for i,role in enumerate(configs):
        record=actors[role]['frames'][0];im=Image.open(ROOT/record['file']).convert('RGBA');im=im.resize((im.width//2,im.height//2),Image.Resampling.NEAREST);mask=im.getchannel('A');im=Image.new('RGBA',im.size,'#171821');im.putalpha(mask);silhouette.paste(im,(20+i*205,300-round(actors[role]['feet_edge_y']*.5)),im)
    save(silhouette,'reviews/UNLABELED_SILHOUETTES.png',kind='unlabeled_source_comparison')
    memory=sum(f['size'][0]*f['size'][1]*4 for f in files if f['kind']!='source_preview' and f['kind']!='unlabeled_source_comparison')
    manifest=dict(classification='REMAINING_ART_V01_AUTHORING_REVIEW_NOT_FINAL',sources=[dict(file='sources/'+p.name,sha256=digest(p),size=list(Image.open(p).size)) for p in sorted(SRC.glob('*.png'))],files=files,actors=actors,environments=environments,effects=fx,portal_body=portal,estimated_all_export_rgba_bytes=memory,memory_scope='sum of unique authoring exports at4bytes/texel, not GPU/peak/device measurement',runtime_promotion=False,visual_acceptance='PENDING',rights_clearance='PENDING',final_cultural_review='PENDING')
    (ROOT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print('RQ_REMAINING_ART_BUILD_OK actors6 bodykeys56 portalbody4 biomes3 terrain48 props15 fx21')

if __name__=='__main__':main()
