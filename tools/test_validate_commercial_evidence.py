"""Synthetic fixtures only; no player approval or real evidence is manufactured."""
import copy
import unittest
from validate_commercial_evidence import inspect, DEVICE_CHECKS, REVIEWS


def fixture():
    build = {"source_commit": "1" * 40, "artifact_sha256": "2" * 64}
    evidence = {
        "candidate": {**build, "version": "test-fixture", "production_signed": True, "ci_green": True},
        "devices": [{**build, "model": "synthetic-device", "android": "test", "tested_at": "fixture",
                     "evidence_refs": ["synthetic-only"], "measurements": {"fixture": True},
                     "checks": {k: "PASS" for k in DEVICE_CHECKS}}],
        "movement_testers": [{**build, "tester_alias": f"fixture{i}", "result": "PASS",
                              "evidence_refs": ["synthetic-only"]} for i in range(3)],
        "beta_runs": [{**build, "run_id": f"fixture{i}", "complete": True, "device": "fixture",
                       "duration_seconds": 1, "evidence_refs": ["synthetic-only"]} for i in range(20)],
        "known_blockers": [], "known_criticals": [],
        "reviews": {k: {**build, "decision": "APPROVED", "reviewer": "synthetic-fixture",
                        "date": "fixture", "evidence_refs": ["synthetic-only"]} for k in REVIEWS},
    }
    assets = [{"asset_path": "fixture", "source": "synthetic", "license": "fixture",
               "proof_location": "synthetic-only", "release_approved": "true"}]
    return evidence, assets


class CommercialEvidence(unittest.TestCase):
    def test_empty_records_fail_closed(self):
        result = inspect({}, [])
        self.assertTrue(result["pending"])
        self.assertFalse(result["automatic_gold_go"])

    def test_complete_structure_never_becomes_automatic_gold_go(self):
        data, assets = fixture()
        result = inspect(data, assets)
        self.assertEqual(result["pending"], [])
        self.assertEqual(result["evidence_truth"], "not-independently-verified")
        self.assertFalse(result["automatic_gold_go"])

    def test_wrong_build_device_is_rejected(self):
        data, assets = fixture()
        data["devices"][0]["artifact_sha256"] = "3" * 64
        self.assertIn("device[0]:wrong-build", inspect(data, assets)["pending"])

    def test_duplicate_testers_do_not_satisfy_three_players(self):
        data, assets = fixture()
        data["movement_testers"] = [data["movement_testers"][0]] * 3
        self.assertIn("three_external_movement_testers", inspect(data, assets)["pending"])

    def test_duplicate_beta_runs_do_not_satisfy_twenty_runs(self):
        data, assets = fixture()
        data["beta_runs"] = [data["beta_runs"][0]] * 20
        self.assertIn("twenty_unique_complete_beta_runs", inspect(data, assets)["pending"])

    def test_debug_signature_cannot_be_treated_as_production(self):
        data, assets = fixture()
        data["candidate"]["production_signed"] = False
        self.assertIn("production_signed", inspect(data, assets)["pending"])

    def test_rights_need_proof_and_explicit_approval(self):
        data, assets = fixture()
        for field in ["source", "license", "proof_location", "release_approved"]:
            missing = copy.deepcopy(assets)
            missing[0][field] = ""
            self.assertIn("asset[0]:rights-or-approval", inspect(data, missing)["pending"])

    def test_prior_revision_review_does_not_approve_current_candidate(self):
        data, assets = fixture()
        data["reviews"]["cultural_final"]["source_commit"] = "4" * 40
        self.assertIn("review:cultural_final:wrong-build", inspect(data, assets)["pending"])


if __name__ == "__main__":
    unittest.main()
