"""Independent FX studies; separate palette, no body-frame promotion."""
import hashlib
import json
from pathlib import Path
from PIL import Image,ImageDraw

ROOT=Path(__file__).resolve().parent
PALETTE=['071f2a','0d3b52','12627d','168db3','29b8d6','74dcef','b9f7fa','f4ffff']

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def map_palette(source):
    palette=Image.new('P',(1,1))
    colors=[tuple(bytes.fromhex(v)) for v in PALETTE]
    palette.putpalette([v for c in colors for v in c]+list(colors[-1])*(256-len(colors)))
    mapped=source.convert('RGB').quantize(palette=palette,dither=Image.Dither.NONE).convert('RGBA')
    mapped.putalpha(source.getchannel('A').point(lambda n:255 if n>=160 else 0))
    clean=Image.new('RGBA',source.size);clean.paste(mapped,(0,0),mapped.getchannel('A'))
    return clean

def main():
    definitions=[('lightning_proc','lightning-source.png',[(0,0,724,724),(724,0,1448,724),(1448,0,2172,724)],1/8,60),
                 ('portal_interaction','portal-source-attempt-01.png',[(0,0,768,512),(768,0,1536,512),(0,512,768,1024),(768,512,1536,1024)],1/3,90)]
    manifest={'classification':'INDEPENDENT_EFFECT_AUTHORING_STUDIES_NOT_FINAL','frame':[256,256],
        'render_scale':0.5,'origin':[128,128],'palette_hex':PALETTE,
        'palette_scope':'8colors FX only, separate from32-color body/weapon; scene composite may use up to40 colors. No body palette extension or combined32-color claim.',
        'method':'Builtin ImageGen high-resolution sheets; one uniform scale per sheet, explicit BOX reduction, eight-color mapping/binary alpha, clear hidden RGB, common center. No per-frame refit, glow shader or native hand cleanup.',
        'frames':[],'sources':[],'files':[], 'runtime_promotion':False,'visual_acceptance':'PENDING',
        'rights_clearance':'PENDING','final_cultural_review':'PENDING',
        'not_delivered':'portal_enter body clip, trigger/lifetime hooks, reduced-flash behavior and in-room/device QA remain pending'}
    board=Image.new('RGB',(1536,2*420),'#142024');draw=ImageDraw.Draw(board)
    for row,(clip,source_name,rects,scale,duration) in enumerate(definitions):
        source=Image.open(ROOT/source_name).convert('RGBA')
        manifest['sources'].append({'file':source_name,'sha256':sha(ROOT/source_name),'size':list(source.size),'shared_scale':scale})
        reviews=[];atlas=Image.new('RGBA',(256*len(rects),256))
        for i,rect in enumerate(rects,1):
            crop=source.crop(rect)
            reduced=map_palette(crop.resize((round(crop.width*scale),round(crop.height*scale)),Image.Resampling.BOX))
            frame=Image.new('RGBA',(256,256));frame.paste(reduced,((256-reduced.width)//2,(256-reduced.height)//2))
            name=f'fx_{clip}_{i:02}.png';frame.save(ROOT/name)
            manifest['files'].append({'file':name,'sha256':sha(ROOT/name)})
            manifest['frames'].append({'clip':clip,'index':i,'file':name,'duration_ms':duration,
                'source_crop':rect,'source_scale':scale,'alpha_bbox':frame.getchannel('A').getbbox()})
            atlas.paste(frame,((i-1)*256,0))
            bg=Image.new('RGBA',(256,256),'#142024');bg.alpha_composite(frame)
            reviews.append(bg.convert('RGB').resize((768,768),Image.Resampling.NEAREST))
            board.paste(bg.convert('RGB').resize((384,384),Image.Resampling.NEAREST),((i-1)*384,row*420+24))
            draw.text(((i-1)*384+12,row*420+9),f'{clip} {i} / {duration}ms',fill='#efcf81')
        name=f'fx_{clip}_atlas.png';atlas.save(ROOT/name)
        manifest['files'].append({'file':name,'sha256':sha(ROOT/name)})
        reviews[0].save(ROOT/f'{clip.upper()}_REVIEW.gif',save_all=True,append_images=reviews[1:]+[reviews[-1]],
            duration=[duration]*len(rects)+[700],loop=0,optimize=False)
    board.save(ROOT/'EFFECTS_REVIEW.png')
    (ROOT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
