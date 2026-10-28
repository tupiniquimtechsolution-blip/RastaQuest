"""Read-only validation for the 21 side-scrolling room planning packet."""
from pathlib import Path
import json
import math

ROOT = Path(__file__).resolve().parents[1]
PACKET = ROOT / "docs/production/room_blockouts/ROOM_BLOCKOUTS_V1.json"

def validate(doc, root=ROOT):
    errors=[]
    def expect(condition, message):
        if not condition: errors.append(message)
    expect(doc.get("version")==1 and doc.get("status")=="BLOCKOUT_PLAN_ONLY", "planning schema/status")
    expect(doc.get("all_in_2d") is True, "2D first")
    for key in ("physical_testing","unity_editor_testing","commercial_approved"):
        expect(doc.get(key) is False, "premature claim "+key)
    rooms=doc.get("rooms",[])
    expect(len(rooms)==21, "21 rooms required")
    target=[f"{b}-{i:02d}" for b in ("forest","castle","caves") for i in range(1,8)]
    expect([r.get("id") for r in rooms]==target, "canonical room order")
    cowrie_ids=set()
    for room in rooms:
        rid=room.get("id","?")
        art=room.get("reference_image","")
        expect(isinstance(art,str) and art.startswith("assets/production_drafts/")
               and (root/art).is_file(), f"{rid}: missing preserved artwork")
        expect(room.get("approval")=="PLANNING_ONLY",f"{rid}: not an approved level")
        expect(room.get("unity_tested") is False and room.get("android_tested") is False,
               f"{rid}: false engine/device claim")
        expect(room.get("projection")=="2D_LANDSCAPE_SIDE_SCROLL", f"{rid}: not side-scroll")
        count=room.get("planned_camera_widths")
        valid_width=isinstance(count,int) and 5<=count<=8
        expect(valid_width,f"{rid}: intended horizontal length")
        landmarks=room.get("landmarks",[])
        expect(valid_width and len(landmarks)==count and
               all(p.get("index")==i and bool(p.get("name")) for i,p in enumerate(landmarks)),
               f"{rid}: segments incomplete")
        side=room.get("side_route",{})
        expect(side.get("rejoins_main") is True and side.get("requires_unreleased_ability") is False,
               f"{rid}: unreachable secondary route")
        boss=room.get("room_number")==7
        expect(room.get("boss_room") is boss, f"{rid}: boss must be room 07")
        expected_exit=("FINAL_VICTORY" if room.get("biome")=="caves" else "BIOME_BOSS_DEFEATED") if boss else "ENCOUNTER_CLEARED"
        expect(room.get("exit_rule")==expected_exit, f"{rid}: inconsistent room exit")
        cowries=room.get("cowries",[])
        expect(len(cowries)==5 and room.get("reward_for_five",{}).get("extra_lives")==1,
               f"{rid}: cowrie reward")
        for idx,shell in enumerate(cowries):
            uid=f"{rid}-b{idx+1}"
            expect(shell.get("id")==uid and shell.get("number")==idx+1 and uid not in cowrie_ids,
                   f"{rid}: duplicate/unstable cowrie")
            cowrie_ids.add(uid)
            pos=shell.get("approx_screen",-1)
            expect(isinstance(pos,(int,float)) and math.isfinite(pos) and pos>0 and
                   valid_width and pos<count, f"{rid}: cowrie out of bounds")
            if boss:
                expect(isinstance(pos,(int,float)) and pos<room.get("boss_start_screen",0),
                       f"{rid}: cowrie beyond boss gate")
            expect(shell.get("status")=="CANDIDATE_UNTESTED",f"{rid}: unverified placement")
    expect(len(cowrie_ids)==105, "105 unique cowrie IDs")
    expect(sum(bool(r.get("boss_room")) for r in rooms)==3, "three bosses")
    expect(doc.get("visual_source_count")==21 and doc.get("expected_cowries")==105,
           "manifest totals drift")
    return errors

if __name__=="__main__":
    problems=validate(json.loads(PACKET.read_text(encoding="utf-8")))
    if problems:
        raise SystemExit("ROOM_BLOCKOUT_FAIL: " + "; ".join(problems))
    print("ROOM_BLOCKOUT_OK 21 planned 2D rooms, 105 cowries, 3 bosses; Unity/editor/Android NOT tested")
