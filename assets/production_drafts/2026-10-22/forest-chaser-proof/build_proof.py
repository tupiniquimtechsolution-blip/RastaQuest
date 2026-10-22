"""New sources -> explicitly reconstructed exports for a separate proof room."""
import hashlib,json
from pathlib import Path
from PIL import Image,ImageDraw

ROOT=Path(__file__).resolve().parent
FOREST=['101b19','1b2822','29372b','3b4932','52623a','72854a','9aa858','c1c479',
 '171b1c','2c3030','444847','656a5c','8b8e74','bab595','211c19','34271f',
 '513a27','725139','96724b','b99969','10303a','1d4a52','37676a','679092']
KNIGHT=['111016','201a22','30282c','493a3d','655255','827071','ac9590','d0b9a4',
 '272731','3b3a46','52515e','6c6a76','8a8591','aaa0a8','c9c0c7','eee0d9',
 '2e1020','52152a','7e2037','aa2947','d1425a','f26479','ff9b9e','422c28']

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def mapped(source,colors,transparent=True):
    pal=Image.new('P',(1,1));rgb=[tuple(bytes.fromhex(v)) for v in colors]
    pal.putpalette([v for c in rgb for v in c]+list(rgb[-1])*(256-len(rgb)))
    im=source.convert('RGB').quantize(palette=pal,dither=Image.Dither.NONE).convert('RGBA')
    if transparent:
        im.putalpha(source.convert('RGBA').getchannel('A').point(lambda n:255 if n>=160 else 0))
        clean=Image.new('RGBA',im.size);clean.paste(im,(0,0),im.getchannel('A'));return clean
    return im

def main():
    files=[]
    def save(im,name,**extra):
        im.save(ROOT/name);files.append({'file':name,'sha256':digest(ROOT/name),'size':list(im.size),**extra})
    bg=Image.open(ROOT/'forest-background-source.png').convert('RGB')
    # Uniform cover, central crop to1280x720; preserve source, no stretch claim.
    scale=max(1280/bg.width,720/bg.height);size=(round(bg.width*scale),round(bg.height*scale))
    bg=bg.resize(size,Image.Resampling.BOX);x=(bg.width-1280)//2;y=(bg.height-720)//2
    bg=bg.crop((x,y,x+1280,y+720)).quantize(colors=64,dither=Image.Dither.NONE).convert('RGB')
    save(bg,'forest_background.png',palette_scope='adaptive64 environmental proposal, not body palette')
    source=Image.open(ROOT/'forest-modules-source.png').convert('RGBA')
    props=[('tree',(0,0,655,700),(128,128)),('column',(655,110,974,700),(64,96)),
           ('log',(980,450,1536,700),(64,32)),('fern_left',(0,710,550,1024),(64,48)),
           ('fern_right',(580,710,1090,1024),(64,48)),('rubble',(1100,730,1536,1024),(32,32))]
    prop_records=[]
    for name,rect,canvas in props:
        crop=source.crop(rect)
        # Ignore the generated transparent RGB haze; derive visible alpha bounds.
        bounds=crop.getchannel('A').point(lambda n:255 if n>=160 else 0).getbbox()
        crop=crop.crop(bounds);factor=min(canvas[0]/crop.width,canvas[1]/crop.height)
        native=mapped(crop.resize((max(1,round(crop.width*factor)),max(1,round(crop.height*factor))),Image.Resampling.BOX),FOREST)
        out=Image.new('RGBA',canvas);out.paste(native,((canvas[0]-native.width)//2,canvas[1]-native.height))
        save(out,'forest_'+name+'.png',palette_limit=24)
        prop_records.append({'file':'forest_'+name+'.png','source_crop':rect,'scale':factor,'canvas':canvas})
    terrain=Image.open(ROOT/'forest-terrain-source.png').convert('RGBA')
    # Reconstruct a readable six-pixel grass band separately from the26px soil;
    # this explicit material remapping is not a native seamless source claim.
    top_source=Image.new('RGBA',(32,32))
    top_source.paste(terrain.crop((0,45,1254,220)).resize((32,6),Image.Resampling.BOX),(0,0))
    top_source.paste(terrain.crop((0,220,1254,1254)).resize((32,26),Image.Resampling.BOX),(0,6))
    top=mapped(top_source,FOREST,False)
    soil=mapped(terrain.crop((0,252,1254,1254)).resize((32,32),Image.Resampling.BOX),FOREST,False)
    # Declare exact native boundary edits: flat contact row and shared edge
    # columns/rows. Pixel equality is not proof of visually natural repetition.
    for xx in range(32):
        top.putpixel((xx,0),(114,133,74,255))
    for yy in range(32):
        top.putpixel((31,yy),top.getpixel((0,yy)))
        soil.putpixel((31,yy),soil.getpixel((0,yy)))
    for xx in range(32):
        soil.putpixel((xx,0),top.getpixel((xx,31)))
        soil.putpixel((xx,31),top.getpixel((xx,31)))
    save(top,'terrain_top_32.png',palette_limit=24);save(soil,'terrain_soil_32.png',palette_limit=24)
    grid=Image.new('RGBA',(96,96))
    for yy in range(3):
        for xx in range(3):grid.paste(top if yy==0 else soil,(xx*32,yy*32))
    grid.resize((768,768),Image.Resampling.NEAREST).save(ROOT/'TERRAIN_REPEAT_REVIEW.png')

    sheet=Image.open(ROOT/'chaser-poses-source.png').convert('RGBA')
    # Body density shared across every pose. The follow-through sword crosses
    # the nominal cell gutter: an explicit isolation mask excludes its neighbor.
    keys=[('idle',1,(0,0,443,443),260,None,240),('move',1,(443,0,887,443),265,None,120),
          ('move',2,(887,0,1330,443),270,None,120),('tell',1,(1330,0,1774,443),265,None,250),
          ('attack',1,(330,443,887,887),340,[(10,110),(270,112),(292,56),(390,56),(450,150),(557,250),(557,444),(210,444),(185,290),(235,185),(10,165)],160),
          ('hurt',1,(887,443,1288,887),265,None,100),('death',1,(1288,690,1774,887),290,None,320)]
    frame_records=[];contact=Image.new('RGB',(1536,768),'#171b20');draw=ImageDraw.Draw(contact)
    for idx,(clip,index,rect,hip_x,poly,ms) in enumerate(keys):
        crop=sheet.crop(rect)
        if poly:
            mask=Image.new('L',crop.size);ImageDraw.Draw(mask).polygon(poly,fill=255)
            from PIL import ImageChops
            crop.putalpha(ImageChops.multiply(crop.getchannel('A'),mask))
        factor=.30
        reduced=mapped(crop.resize((round(crop.width*factor),round(crop.height*factor)),Image.Resampling.BOX),KNIGHT)
        bounds=reduced.getchannel('A').getbbox()
        im=Image.new('RGBA',(256,256));offset=(128-round(hip_x*factor),186-bounds[3]);im.paste(reduced,offset)
        name=f'chaser_{clip}_{index:02}.png';save(im,name,palette_limit=24)
        frame_records.append({'clip':clip,'index':index,'file':name,'duration_ms':ms,'origin':[128,128],'feet_edge_y':186,
            'source_crop':rect,'source_scale':factor,'source_hip_x_estimated':hip_x,'source_isolation_polygon':poly,'offset':offset,'alpha_bbox':im.getchannel('A').getbbox()})
        cell=Image.new('RGBA',(256,256),'#171b20');cell.alpha_composite(im)
        contact.paste(cell.convert('RGB').resize((384,384),Image.Resampling.NEAREST),((idx%4)*384,(idx//4)*384))
        draw.text(((idx%4)*384+10,(idx//4)*384+12),clip+' '+str(index)+' | study',fill='#efcc87')
    contact.save(ROOT/'CHASER_KEYS_REVIEW.png')
    sources=[{'file':p.name,'size':list(Image.open(p).size),'sha256':digest(p)} for p in sorted(ROOT.glob('*-source.png'))]
    m={'classification':'FOREST_CHASER_SEPARATE_ROOM_PROOF_NOT_FINAL','sources':sources,'files':files,
       'props':prop_records,'chaser':{'source_frame':[256,256],'scale':.5,'source_density':.30,'palette_hex':KNIGHT,'frames':frame_records,
          'states':['idle','move','tell','attack','hurt','death'],'authored_selected_pose_count':7,'move_poses':2,
          'unused_source_pose':'lower-left repeats raised tell silhouette, excluded from active impact because damage would already be active',
          'remaining':'more motion keys, rigid enemy sword/shield continuity, anatomy/weapon/hitbox and death cleanup'},
       'environment':{'tile':[32,32],'source_pixels_per_world_unit':1,'prop_palette_hex':FOREST,'background_colors':64,
          'terrain_method':'separate material reconstruction6px grass/26px soil; flat contact row, exact shared edge columns and joining soil rows; natural repetition/edge variants not accepted',
          'remaining':'full corners/bottom/isolated platform kit, genuine parallax/wrap QA, props/collision/phone review'},
       'runtime_promotion':False,'visual_acceptance':'PENDING','rights_clearance':'PENDING','final_cultural_review':'PENDING'}
    (ROOT/'MANIFEST.json').write_text(json.dumps(m,indent=2)+'\n',encoding='utf-8')
    print('built environmental exports and7Chaser pose keys for6states')

if __name__=='__main__':main()
