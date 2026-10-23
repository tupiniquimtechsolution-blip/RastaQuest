"""Explicit native reconstruction and rigid registrations; no final acceptance."""
from pathlib import Path
from PIL import Image, ImageDraw
import hashlib, importlib.util, json

ROOT=Path(__file__).resolve().parent
OLD=ROOT.parents[1]/'2026-10-22'
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path);mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
base=module('proof',OLD/'forest-chaser-proof/build_proof.py')
helper=module('remaining',OLD/'remaining-art-v01/build_art.py')
clean=module('clean',OLD/'forest-chaser-polish/build_polish.py').clean_fragments
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    files=[];actors={}
    def save(im,file,**meta):
        p=ROOT/file;p.parent.mkdir(parents=True,exist_ok=True);im.save(p);files.append(dict(file=file,sha256=sha(p),size=list(im.size),**meta))
    order=['idle']*2+['move']*6+['tell']*2+['attack']*2+['hurt']*2+['death']*2
    # Hand measurements in original equal384x256 cells. All grips are proposals
    # inspected on native composites, not inferred from generated labels.
    hands={
      'ranged':[(150,121),(150,121),(147,123),(146,123),(138,107),(150,107),(155,112),(153,112),(142,121),(146,122),(108,82),(116,85),(145,92),(145,93),(142,156),(62,187)],
      'controller':[(164,94),(164,94),(164,100),(164,100),(145,88),(146,88),(150,92),(149,92),(143,93),(148,103),(76,70),(76,72),(147,78),(150,85),(147,155),(62,183)]}
    for role,height in [('ranged',128),('controller',128),('charger',112),('exploder',128)]:
        source=Image.open(ROOT/'sources'/f'{role}_alpha.png').convert('RGBA')
        # Visible generated gradient pixels have intermediate alpha. Retain only
        # confidently opaque subject pixels before palette/density reconstruction.
        source.putalpha(source.getchannel('A').point(lambda a:255 if a>=200 else 0))
        colors=helper.palette(source,32);w,h=source.size
        crops=[source.crop((c*w//4,r*h//4,(c+1)*w//4,(r+1)*h//4)) for r in range(4) for c in range(4)]
        first=crops[0].getchannel('A').getbbox();factor=height/(first[3]-first[1]);records=[];counts={};keys={};composites=[]
        weapon=None;grip=None
        if role in hands:
            item='crossbow' if role=='ranged' else 'staff';raw=Image.open(ROOT/'sources'/f'{item}.png').convert('RGBA');raw.putalpha(raw.getchannel('A').point(lambda a:255 if a>=200 else 0));raw=raw.crop(raw.getchannel('A').getbbox())
            canvas=(72,32) if role=='ranged' else (24,112)
            s=min(canvas[0]/raw.width,canvas[1]/raw.height);native=base.mapped(raw.resize((round(raw.width*s),round(raw.height*s)),Image.Resampling.BOX),colors)
            weapon=Image.new('RGBA',canvas);weapon.paste(native,((canvas[0]-native.width)//2,(canvas[1]-native.height)//2));clean(weapon)
            grip=[51,22] if role=='ranged' else [12,70]
            save(weapon,f'equipment/{item}.png',kind='rigid_equipment',palette_limit=32)
        for n,(crop,clip) in enumerate(zip(crops,order)):
            im=base.mapped(crop.resize((round(crop.width*factor),round(crop.height*factor)),Image.Resampling.BOX),colors);clean(im);b=im.getchannel('A').getbbox()
            # Center the torso, not a swinging cape, using consistent source hip
            # anchors. Death uses its visible center to keep the body in frame.
            center=round((210 if role in hands else 195)*factor) if clip!='death' else (b[0]+b[2])//2
            offset=(128-center,186-b[3]);out=Image.new('RGBA',(256,256));out.paste(im,offset)
            # Fail instead of silently cutting source anatomy at a canvas edge.
            if sum(out.getchannel('A').tobytes())!=sum(im.getchannel('A').tobytes()):raise ValueError(role+' clipped '+str(n))
            counts[clip]=counts.get(clip,0)+1;idx=counts[clip];ms={'idle':200,'move':80,'tell':100,'attack':80,'hurt':70,'death':160}[clip]
            file=f'actors/{role}/{clip}_{idx:02}.png';save(out,file,kind='body',palette_limit=32)
            rec=dict(clip=clip,index=idx,file=file,duration_ms=ms,source_cell=[n%4,n//4],source_scale=factor,offset=list(offset),alpha_bbox=list(out.getchannel('A').getbbox()));records.append(rec)
            combined=out.copy()
            if weapon:
                # Find the leading fist in the upper-body band of this exact
                # native key; generated poses are not centered in equal cells.
                bounds=out.getchannel('A').getbbox();bh=bounds[3]-bounds[1]
                pixels=out.load();band=[]
                for yy in range(bounds[1]+round(bh*.20),bounds[1]+round(bh*.58)):
                    row=[xx for xx in range(256) if pixels[xx,yy][3]]
                    if row:band.append((min(row),yy))
                leading=min(x for x,y in band);ys=sorted(y for x,y in band if x<=leading+2)
                native_point=[leading+4-128,ys[len(ys)//2]-128]
                if clip=='death':native_point=[bounds[0]+12-128,bounds[3]-8-128]
                angle=0 if clip!='death' else (15 if idx==1 else 82)
                # Only one master texture; engine mirrors/rotates it at this grip.
                key={'position':native_point,'degrees':angle};keys.setdefault(clip,[]).append(key)
                layer=Image.new('RGBA',(256,256));layer.paste(weapon,(128+native_point[0]-grip[0],128+native_point[1]-grip[1]));layer=layer.rotate(-angle,resample=Image.Resampling.NEAREST,center=(128+native_point[0],128+native_point[1]))
                layer.alpha_composite(out);combined=layer
            cell=Image.new('RGBA',(256,256),'#151a20');cell.alpha_composite(combined);composites.append(cell.convert('RGB'))
        review=Image.new('RGB',(1024,1024),'#151a20');draw=ImageDraw.Draw(review)
        for n,im in enumerate(composites):review.paste(im,((n%4)*256,(n//4)*256));draw.text(((n%4)*256+8,(n//4)*256+8),order[n]+' '+str(records[n]['index']),fill='#dfca98')
        save(review,f'reviews/{role}_keys.png',kind='source_preview')
        # Only cyclic movement, not a misleading GIF concatenating all states.
        composites[2].save(ROOT/f'reviews/{role}_walk.gif',save_all=True,append_images=composites[3:8],duration=80,loop=0,disposal=2)
        actors[role]=dict(canvas=256,origin=[128,128],feet_edge_y=186,palette_hex=colors,clips=counts,frames=records,patterns={role:['tell','attack']},visual_acceptance='PENDING')
        if weapon:actors[role]['equipment']=dict(file=f'equipment/{item}.png',grip=grip,keys=keys,source_file=f'sources/{item}.png')
    sources=[dict(file=p.relative_to(ROOT).as_posix(),sha256=sha(p),size=list(Image.open(p).size)) for p in sorted((ROOT/'sources').glob('*.png'))]
    manifest=dict(schema=1,sources=sources,files=files,actors=actors,commercial_approved=False,rights_status='PENDING',cultural_review='PENDING',visual_acceptance='PENDING',method='Built-in ImageGen poses; measured uniform BOX reduction/32color common palette/alpha>=200/native registration; no final animation approval')
    (ROOT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print('RQ_PLAYABLE_POLISH_BUILT actors4 bodykeys64 rigidmasters2')
if __name__=='__main__':main()
