"""Run source checks without installing or activating Unity."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--compiler', type=Path)
    args = parser.parse_args()
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    output = (args.output or ROOT/'unity/Builds/SourceChecks'/stamp).resolve()
    output.mkdir(parents=True, exist_ok=False)
    compiler = args.compiler or Path(os.environ.get('WINDIR', 'C:/Windows'))/'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
    evidence = dict(schema=1, scope='source-contracts-only', status='FAIL',
                    unity_editor_validated=False, apk_built=False,
                    physical_acceptance='PENDING', commercial_approved=False,
                    source_files={}, checks=[])
    patterns = ['unity/Assets/RastaQuest/**/*.cs', 'unity/Assets/RastaQuest/**/*.asmdef',
                'unity/Tests/*.cs', 'unity/Packages/manifest.json', 'unity/ProjectSettings/*',
                'unity/Assets/Resources/ReviewArt/IMPORT_MANIFEST.json',
                'tools/sync_unity_review.py', 'tools/check_unity_source.py']
    for pattern in patterns:
        for path in sorted(ROOT.glob(pattern)):
            if path.is_file():
                evidence['source_files'][path.relative_to(ROOT).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    try:
        evidence['head'] = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
        evidence['working_tree_dirty'] = bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True).strip())
        if not compiler.is_file():
            raise RuntimeError('C# compiler unavailable; pass --compiler with its location.')
        binary = output/'core-tests.exe'
        commands = [
            ('asset_bridge', [sys.executable, '-B', str(ROOT/'tools/sync_unity_review.py'), '--check']),
            ('compile_core', [str(compiler), '/nologo', '/out:'+str(binary),
                              *map(str, sorted((ROOT/'unity/Assets/RastaQuest/Core').glob('*.cs'))),
                              str(ROOT/'unity/Tests/RulesTests.cs')]),
            ('execute_core', [str(binary)]),
            ('diff_whitespace', ['git', 'diff', '--check']),
        ]
        for key, command in commands:
            result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, text=True, encoding='utf-8',
                                    errors='replace', timeout=120)
            (output/(key+'.txt')).write_text(result.stdout, encoding='utf-8')
            evidence['checks'].append(dict(name=key, exit_code=result.returncode))
            if result.returncode:
                raise RuntimeError('Failed: '+key+'; inspect '+str(output/(key+'.txt')))
            if key == 'execute_core':
                match = re.search(r'RQ_UNITY_CORE_OK (\d+) assertions; Unity runtime NOT tested', result.stdout)
                if not match:
                    raise RuntimeError('Core verification marker absent')
                evidence['assertions'] = int(match.group(1))
        evidence['status'] = 'PASS'
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        evidence['error'] = str(error)
    finally:
        report = output/'SOURCE_REPORT.json'
        report.write_text(json.dumps(evidence, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
        print(evidence['status']+': '+str(report))
        print('Unity Editor, rendering, native probe, APK and physical acceptance: NOT VERIFIED')
    return 0 if evidence['status'] == 'PASS' else 1


if __name__ == '__main__':
    raise SystemExit(main())
