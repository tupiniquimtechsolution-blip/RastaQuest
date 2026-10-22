"""Versioned native reconstruction from preserved sources; no shipping promotion."""
import hashlib, importlib.util, json
from pathlib import Path
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parent
OLD=ROOT.parent/'forest-chaser-proof'
spec=importlib.util.spec_from_file_location('proof',OLD/'build_proof.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
digest=base.digest

def clean_fragments(im):
    pixels=im.load();seen=set();removed=0
    for y in range(im.height):
        for x in range(im.width):
            if (x,y) in seen or pixels[x,y][3]==0:continue
            stack=[(x,y)];seen.add((x,y));component=[]
            while stack:
                px,py=stack.pop();component.append((px,py))
                for nx in range(max(0,px-1),min(im.width,px+2)):
                    for ny in range(max(0,py-1),min(im.height,py+2)):
                        if (nx,ny) not in seen and pixels[nx,ny][3]:seen.add((nx,ny));stack.append((nx,ny))
            if len(component)<8:
                for pos in component:pixels[pos[0],pos[1]]=(0,0,0,0)
                removed+=len(component)
    return removed

def main():
    records=[]
    def save(im,name,**extra):
        im.save(ROOT/name)
        records.append(dict(file=name,sha256=digest(ROOT/name),size=list(im.size),**extra))
    sheet=Image.open(ROOT/'chaser-body-source.png').convert('RGBA')
    # Measured source boundaries, not assumed square cells from a prompt.
    xs=[0,354,708,1062,1416];ys=[0,291,554,831,1111]
    keys=[('idle',240),('idle',240)]+[('move',80)]*6+[('tell',100),('tell',150),('attack',80),('attack',80),('hurt',50),('hurt',50),('death',120),('death',200)]
    hands=[(120,166,214,166),(127,166,210,167),(95,166,198,166),(112,190,230,196),
           (111,148,215,166),(104,157,215,154),(105,166,207,169),(104,155,215,160),
           (92,112,214,146),(161,20,86,142),(14,112,202,188),(24,129,200,196),
           (128,74,223,143),(108,115,208,142),(85,221,180,196),(140,226,226,214)]
    hips=[190,184,184,195,184,184,184,195,190,184,200,200,192,184,184,185]
    angles=[-12,-10,-12,-8,-10,-12,-8,-12,-40,65,0,-8,-25,-12,15,0]
    shield_angles=[-8,-8,-6,-6,-10,-8,-6,-6,-15,-22,-12,-12,10,0,20,80]
    scale=.44;frames=[];counts={};contact=Image.new('RGB',(1024,1024),'#171b20');draw=ImageDraw.Draw(contact)
    for n,(clip,ms) in enumerate(keys):
        row,col=divmod(n,4);rect=(xs[col],ys[row],xs[col+1],ys[row+1])
        crop=sheet.crop(rect);alpha=crop.getchannel('A').point(lambda a:255 if a>=160 else 0)
        crop.putalpha(alpha);bounds=alpha.getbbox()
        reduced=base.mapped(crop.resize((round(crop.width*scale),round(crop.height*scale)),Image.Resampling.BOX),base.KNIGHT)
        native_bounds=reduced.getchannel('A').getbbox()
        offset=(128-round(hips[n]*scale),186-native_bounds[3])
        im=Image.new('RGBA',(256,256));im.paste(reduced,offset);removed=clean_fragments(im)
        counts[clip]=counts.get(clip,0)+1;index=counts[clip];name=f'chaser_{clip}_{index:02}.png'
        save(im,name,role='body',palette_limit=24,removed_fragment_pixels=removed)
        sx,sy,hx,hy=hands[n]
        point=lambda x,y:[round(x*scale)+offset[0]-128,round(y*scale)+offset[1]-128]
        frame=dict(clip=clip,index=index,file=name,duration_ms=ms,source_crop=rect,source_scale=scale,offset=offset,
                   sword_position=point(sx,sy),sword_degrees=angles[n],shield_position=point(hx,hy),shield_degrees=shield_angles[n])
        frames.append(frame)
    gear=Image.open(ROOT/'chaser-equipment-source.png').convert('RGBA')
    # Source split is measured; uniform fit preserves each object's proportions.
    for name,rect,canvas,pivot in [('sword',(0,0,1120,gear.height),(56,16),(46,8)),('shield',(1120,0,gear.width,gear.height),(32,52),(16,26))]:
        crop=gear.crop(rect);a=crop.getchannel('A').point(lambda x:255 if x>=160 else 0);crop.putalpha(a);crop=crop.crop(a.getbbox())
        f=min(canvas[0]/crop.width,canvas[1]/crop.height);native=base.mapped(crop.resize((round(crop.width*f),round(crop.height*f)),Image.Resampling.BOX),base.KNIGHT)
        out=Image.new('RGBA',canvas);out.paste(native,((canvas[0]-native.width)//2,(canvas[1]-native.height)//2))
        save(out,'chaser_'+name+'.png',role='rigid_equipment',pivot=pivot,palette_limit=24)
    # Contact render uses the SAME gear image and pivot in every pose.
    motion=[]
    for n,f in enumerate(frames):
        body=Image.open(ROOT/f['file']).convert('RGBA')
        for obj,pivot in [('sword',(46,8)),('shield',(16,26))]:
            gear=Image.open(ROOT/('chaser_'+obj+'.png')).convert('RGBA')
            plane=Image.new('RGBA',(256,256));plane.paste(gear,(128-pivot[0],128-pivot[1]))
            plane=plane.rotate(-f[obj+'_degrees'],resample=Image.Resampling.NEAREST,center=(128,128))
            pos=f[obj+'_position'];body.alpha_composite(plane,tuple(pos))
        cell=Image.new('RGBA',(256,256),'#171b20');cell.alpha_composite(body)
        x,y=(n%4)*256,(n//4)*256;contact.paste(cell.convert('RGB'),(x,y));draw.text((x+8,y+8),f['clip']+' '+str(f['index']),fill='#efcc87')
        preview=cell.convert('RGB').resize((512,512),Image.Resampling.NEAREST)
        ImageDraw.Draw(preview).text((16,16),'SOURCE MOTION | '+f['clip']+' '+str(f['index'])+' | REVIEW',fill='#efcc87')
        motion.append(preview)
    contact.save(ROOT/'CHASER_RIG_REVIEW.png')
    durations=[f['duration_ms'] for f in frames]
    motion[0].save(ROOT/'CHASER_SOURCE_MOTION.gif',save_all=True,append_images=motion[1:],duration=durations,loop=0,disposal=2)
    # Terrain preserves the existing material source, now sampled as local
    # roots/stone clusters, not squeezed from the entire1254px image to32px.
    terrain=Image.open(OLD/'forest-terrain-source.png').convert('RGBA')
    tops=[];soils=[]
    for i,x in enumerate([80,440,800]):
        soil=base.mapped(terrain.crop((x,340,x+256,596)).resize((32,32),Image.Resampling.BOX),base.FOREST,False)
        top=soil.copy();grass=base.mapped(terrain.crop((x,40,x+256,200)).resize((32,8),Image.Resampling.BOX),base.FOREST,False);top.paste(grass,(0,0))
        tops.append(top);soils.append(soil)
    # Shared TWO pixel boundary strips permit arbitrary variant adjacency.
    for tiles in [tops,soils]:
        for im in tiles:
            for y in range(32):
                for x in [0,1,30,31]:im.putpixel((x,y),tiles[0].getpixel((0,y)))
    join=[soils[0].getpixel((x,0)) for x in range(32)]
    for top in tops:
        for x in range(32):top.putpixel((x,31),join[x])
    for im in soils:
        for x in range(32):im.putpixel((x,0),join[x]);im.putpixel((x,31),join[x])
    tiles={}
    for i in range(3):tiles['top_'+str(i+1)]=tops[i];tiles['soil_'+str(i+1)]=soils[i]
    def masked(im,poly):
        result=im.copy();a=Image.new('L',(32,32));ImageDraw.Draw(a).polygon(poly,fill=255);result.putalpha(a);return result
    left=[(0,0),(31,0),(31,31),(7,31),(7,27),(4,25),(5,21),(2,17),(3,12),(0,8)]
    bottom=[(0,0),(31,0),(31,8),(27,8),(25,12),(21,10),(18,15),(15,11),(11,14),(8,10),(4,11),(0,7)]
    tiles['top_left']=masked(tops[0],left);tiles['top_right']=tiles['top_left'].transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    side=[(7,0),(31,0),(31,31),(7,31),(7,27),(4,25),(5,21),(2,17),(3,12),(7,8)]
    tiles['side_left']=masked(soils[0],side);tiles['side_right']=tiles['side_left'].transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    tiles['bottom']=masked(soils[1],bottom)
    # Bottom corners combine a side profile with the hanging root silhouette.
    from PIL import ImageChops
    for side in ['left','right']:
        # A bottom cap starts at the side wall's LOWER edge, not its upper
        # slope. Reusing the full side mask here made the corners identical.
        mask=Image.new('L',(32,32));ImageDraw.Draw(mask).rectangle((7,0,31,31) if side=='left' else (0,0,24,31),fill=255)
        im=tiles['bottom'].copy();im.putalpha(ImageChops.multiply(im.getchannel('A'),mask));tiles['bottom_'+side]=im
    solo=tops[2].copy();solo.putalpha(ImageChops.multiply(tiles['top_left'].getchannel('A'),tiles['top_right'].getchannel('A')));tiles['isolated']=solo
    for side in ['left','right']:
        im=soils[2].copy();a=im.getchannel('A');d=ImageDraw.Draw(a)
        d.rectangle((0,0,5,6) if side=='left' else (26,0,31,6),fill=0);im.putalpha(a);tiles['inner_'+side]=im
    tile_records=[]
    for name,im in tiles.items():
        filename='terrain_'+name+'.png';save(im,filename,role='terrain',palette_limit=24);tile_records.append(filename)
    review=Image.new('RGBA',(320,160),'#253530')
    # Wide repeated ground, four-cell suspended island and isolated-cell island.
    for x in range(10):
        review.alpha_composite(tops[x%3],(x*32,96));review.alpha_composite(soils[x%3],(x*32,128))
    for x,name in enumerate(['top_left','top_2','top_3','top_right']):review.alpha_composite(tiles[name],(32+x*32,16))
    for x,name in enumerate(['bottom_left','bottom','bottom','bottom_right']):review.alpha_composite(tiles[name],(32+x*32,48))
    review.alpha_composite(tiles['isolated'],(240,32));review.resize((1280,640),Image.Resampling.NEAREST).save(ROOT/'TERRAIN_KIT_REVIEW.png')
    manifest=dict(classification='FOREST_CHASER_POLISH_V02_REVIEW',files=records,chaser=dict(frames=frames,source_scale=scale,scale=.5,origin=[128,128],feet_edge_y=186,palette_hex=base.KNIGHT,
        rigid_equipment={'sword':{'file':'chaser_sword.png','pivot':[46,8]},'shield':{'file':'chaser_shield.png','pivot':[16,26]}},counts=counts),
        environment=dict(tile_size=32,tiles=tile_records,palette_hex=base.FOREST,background_mirror_period=2560,parallax_factors=[.25,.65,1.0,1.08]),
        sources=[dict(file=p.name,sha256=digest(p),size=list(Image.open(p).size)) for p in ROOT.glob('*-source.png')],
        referenced_terrain=dict(file='../forest-chaser-proof/forest-terrain-source.png',sha256=digest(OLD/'forest-terrain-source.png')),
        previews=[dict(file=p.name,sha256=digest(p),size=list(Image.open(p).size)) for p in [ROOT/'CHASER_RIG_REVIEW.png',ROOT/'CHASER_SOURCE_MOTION.gif',ROOT/'TERRAIN_KIT_REVIEW.png']],
        visual_acceptance='PENDING',rights_clearance='PENDING',final_cultural_review='PENDING',runtime_promotion=False)
    (ROOT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('RQ_POLISH_BUILD_OK poses16 rigid_equipment2 terrain'+str(len(tiles)))

if __name__=='__main__':main()
