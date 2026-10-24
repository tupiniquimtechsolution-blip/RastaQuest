import copy
import json
import unittest
from validate_unity_content_pack import PACK, validate

class ContentPackTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = json.loads(PACK.read_text(encoding="utf-8"))
    def test_current_draft(self):
        self.assertEqual([],validate(cls.data))
    def test_placeholder_drift(self):
        d=copy.deepcopy(self.data)
        d["locales"]["es"]["ui.health"]="Vida {current}"
        self.assertTrue(any("placeholder mismatch" in e for e in validate(d)))
    def test_unsafe_save_claim(self):
        d=copy.deepcopy(self.data)
        d["save"]["target_write_enabled"]=True
        self.assertTrue(any("unsafe save migration" in e for e in validate(d)))
    def test_unknown_upgrade(self):
        d=copy.deepcopy(self.data)
        d["choices"][0]["upgrade"]="nonexistent"
        self.assertTrue(any("missing upgrade" in e for e in validate(d)))
if __name__=="__main__":
    unittest.main()
