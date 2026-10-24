import copy
import json
import unittest
from validate_unity_migration_evidence import PLAN, validate

class MigrationEvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = json.loads(PLAN.read_text(encoding="utf-8"))
    def test_pending_gate_packet_is_valid_plan(self):
        self.assertEqual([],validate(self.data))
    def test_false_gold_go_rejected(self):
        d=copy.deepcopy(self.data);d["release_decision"]="GO"
        self.assertTrue(any("Gold GO" in e for e in validate(d)))
    def test_empty_pass_rejected(self):
        d=copy.deepcopy(self.data);d["checks"][0]["state"]="PASS"
        self.assertTrue(any("PASS without referenced evidence" in e for e in validate(d)))
    def test_unreviewed_cultural_pass_rejected(self):
        d=copy.deepcopy(self.data)
        item=next(i for i in d["checks"] if i["id"]=="cultural-consultation")
        item["state"]="PASS";item["evidence"]=["https://github.com/example/example/issues/1"]
        item["artifact_sha256"]="a"*64
        self.assertTrue(any("accountable reviewer" in e for e in validate(d)))
    def test_duplicate_gate_rejected(self):
        d=copy.deepcopy(self.data);d["checks"].append(copy.deepcopy(d["checks"][0]))
        self.assertTrue(any("duplicated" in e for e in validate(d)))
if __name__=="__main__":
    unittest.main()
