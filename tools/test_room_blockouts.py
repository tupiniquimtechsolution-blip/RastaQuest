import copy
import json
import unittest
from validate_room_blockouts import PACKET,validate

class BlockoutPlanTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.original=json.loads(PACKET.read_text(encoding="utf-8"))
    def test_reference_catalog(self):
        self.assertEqual([],validate(self.original))
    def test_short_room_rejected(self):
        d=copy.deepcopy(self.original)
        d["rooms"][0]["planned_camera_widths"]=1
        self.assertTrue(any("horizontal length" in e for e in validate(d)))
    def test_duplicate_shell_rejected(self):
        d=copy.deepcopy(self.original)
        d["rooms"][1]["cowries"][0]["id"]=d["rooms"][0]["cowries"][0]["id"]
        self.assertTrue(any("duplicate/unstable" in e for e in validate(d)))
    def test_boss_shell_after_gate_rejected(self):
        d=copy.deepcopy(self.original)
        d["rooms"][6]["cowries"][4]["approx_screen"]=4.2
        self.assertTrue(any("beyond boss gate" in e for e in validate(d)))
    def test_false_runtime_claim_rejected(self):
        d=copy.deepcopy(self.original)
        d["rooms"][0]["unity_tested"]=True
        self.assertTrue(any("false engine/device" in e for e in validate(d)))
    def test_boss_placement_rejected(self):
        d=copy.deepcopy(self.original)
        d["rooms"][13]["boss_room"]=False
        self.assertTrue(any("boss must" in e for e in validate(d)))

if __name__=="__main__":
    unittest.main()
