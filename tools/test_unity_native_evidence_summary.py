"""Offline fixture tests for the sanitized Unity native-evidence collector."""
import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from unity_native_evidence_summary import summarize


class EvidenceSummaryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.artifact = self.root / "fake-windows-player.exe"
        self.artifact.write_bytes(b"A" * 4096)
        self.probe_dir = self.root / "NativeProbe"
        self.probe_dir.mkdir()
        self.names = [f"capture_{index}_1280x720.png" for index in range(8)]
        for name in self.names:
            (self.probe_dir / name).write_bytes(b"\x89PNG\r\n\x1a\n" + b"\x00" * 16)
        self.gate_path = self.root / "NATIVE_GATE_REPORT.json"
        self.probe_path = self.probe_dir / "NATIVE_REPORT.json"
        self.gate = {
            "status": "PASS",
            "required_unity": "6000.6.10f1",
            "repository_head": "a" * 40,
            "editor_exe": r"C:\Users\PrivatePerson\Unity.exe",
            "project_path": r"C:\Users\PrivatePerson\secret-project",
            "artifacts": [{
                "type": "windows-review-exe",
                "path": str(self.artifact),
                "bytes": 4096,
                "sha256": hashlib.sha256(self.artifact.read_bytes()).hexdigest(),
            }],
        }
        self.probe = {
            "status": "PASS",
            "engine": "6000.6.10f1",
            "failures": [],
            "captures": list(self.names),
        }
        self.flush()

    def flush(self):
        self.gate_path.write_text(json.dumps(self.gate), encoding="utf-8")
        self.probe_path.write_text(json.dumps(self.probe), encoding="utf-8")

    def test_valid_report_removes_sensitive_paths_and_verifies_hashes(self):
        result = summarize(self.gate_path, self.probe_path)
        self.assertEqual(result["screenshot_count_reported"], 8)
        self.assertEqual(result["screenshots_present_next_to_probe"], 8)
        self.assertTrue(result["artifacts"][0]["current_local_file_verified"])
        self.assertEqual(result["source_commit"], "a" * 40)
        self.assertFalse(result["physical_android_verified"])
        self.assertFalse(result["commercial_approved"])
        self.assertNotIn("PrivatePerson", json.dumps(result))
        self.assertNotIn(str(self.root), json.dumps(result))

    def test_rejects_mismatched_artifact(self):
        self.artifact.write_bytes(b"B" * 4096)
        with self.assertRaisesRegex(ValueError, "differs"):
            summarize(self.gate_path, self.probe_path)

    def test_rejects_failed_probe(self):
        self.probe["status"] = "FAIL"
        self.flush()
        with self.assertRaisesRegex(ValueError, "PASS"):
            summarize(self.gate_path, self.probe_path)

    def test_rejects_disagreement_about_source_commit(self):
        with self.assertRaisesRegex(ValueError, "differs"):
            summarize(self.gate_path, self.probe_path, "b" * 40)

    def test_missing_artifact_is_not_misrepresented_as_verified(self):
        self.artifact.unlink()
        result = summarize(self.gate_path, self.probe_path)
        self.assertFalse(result["artifacts"][0]["current_local_file_verified"])


if __name__ == "__main__":
    unittest.main()
