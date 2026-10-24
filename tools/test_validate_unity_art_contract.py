import copy
import json
import unittest
from pathlib import Path
from validate_unity_art_contract import PACKET, validate

class ArtPacketTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.base = json.loads(PACKET.read_text(encoding="utf-8"))

    def test_reference_contract_is_consistent(self):
        self.assertEqual([], validate(self.base))

    def test_does_not_promote_shipping_approval(self):
        d = copy.deepcopy(self.base)
        d["commercial_approved"] = True
        self.assertTrue(any("commercial_approved" in x for x in validate(d)))

    def test_missing_required_clips_fails(self):
        d = copy.deepcopy(self.base)
        d["characters"][0]["clips"].remove("portal_enter")
        self.assertTrue(any("missing core clips" in x for x in validate(d)))

    def test_no_collision_claim_from_painting(self):
        d = copy.deepcopy(self.base)
        d["environments"][0]["gameplay_collision_from_art"] = True
        self.assertTrue(any("collision" in x for x in validate(d)))

if __name__ == "__main__":
    unittest.main()
