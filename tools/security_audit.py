"""Read-only, redacted credential-pattern scan of all reachable Git blobs.

Not a general vulnerability scanner. Never prints matched values or blob text.
"""
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATTERNS = {
    "private_key": rb"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----",
    "github_token": rb"(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{50,})",
    "openai_key": rb"sk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{32,}",
    "aws_access_id": rb"(?:AKIA|ASIA)[A-Z0-9]{16}",
    "stripe_live_secret": rb"(?:sk|rk)_live_[A-Za-z0-9]{20,}",
}

def run(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)

def scan():
    objects = run("rev-list", "--objects", "--all").decode("utf-8").splitlines()
    records = {}
    for obj in objects:
        sha, _, path = obj.partition(" ")
        records.setdefault(sha, path)
    proc = subprocess.Popen(["git", "cat-file", "--batch"], cwd=ROOT,
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    findings, blobs, binary = [], 0, 0
    for sha, path in records.items():
        proc.stdin.write((sha + "\n").encode())
        proc.stdin.flush()
        header = proc.stdout.readline().decode().split()
        if len(header) != 3:
            raise RuntimeError("Git object unavailable")
        content = proc.stdout.read(int(header[2]))
        proc.stdout.read(1)
        if header[1] != "blob":
            continue
        blobs += 1
        if b"\x00" in content:
            binary += 1
            continue
        for kind, pattern in PATTERNS.items():
            matches = list(re.finditer(pattern, content))
            if matches:
                findings.append({"blob": sha, "path": path, "kind": kind,
                                 "count": len(matches), "values": "REDACTED"})
    proc.stdin.close()
    if proc.wait() != 0:
        raise RuntimeError("git cat-file failed")
    return {"scope": "all locally reachable refs/history", "head": run("rev-parse", "HEAD").decode().strip(),
            "blobs": blobs, "binary_skipped": binary, "findings": findings,
            "limitations": "pattern-only; no entropy scan, remote secrets or unreachable objects"}

if __name__ == "__main__":
    result = scan()
    print(json.dumps(result, indent=2))
    raise SystemExit(bool(result["findings"]))
