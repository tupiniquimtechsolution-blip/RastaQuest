"""Copy the existing, explicitly non-commercial review payload without altering pixels.

Run from any directory. --check verifies the entire bridge and copied-byte manifest.
This is not an art converter, license validator or Unity build.
"""
from pathlib import Path
import argparse
import hashlib
import json
import uuid

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'game/visual_review'
DEST = ROOT / 'unity/Assets/Resources/ReviewArt'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def resource(file):
    path = Path(file)
    if path.is_absolute() or '..' in path.parts or path.suffix != '.png':
        raise ValueError(f'Unsafe review path: {file}')
    return 'ReviewArt/' + path.with_suffix('').as_posix()


def build():
    raw = (SOURCE / 'catalog.json').read_bytes().replace(b'\r\n', b'\n')
    catalog = json.loads(raw)
    assert catalog['commercial_approved'] is False
    bridge = {'commercialApproved': False, 'actors': [], 'environments': []}
    for key, spec in [('player', catalog['player']), *catalog['actors'].items(), ('portal', catalog['portal'])]:
        clips = []
        for clip, frames in spec['clips'].items():
            rendered = []
            for i, frame in enumerate(frames):
                item = {'file': resource(frame['file']), 'seconds': frame['duration_ms'] / 1000}
                equipment = spec.get('equipment', {})
                keys = equipment.get('keys', {}).get(clip, [])
                if keys:
                    pose = keys[min(i, len(keys)-1)]
                    if key == 'chaser':
                        item['equipment'] = [resource(equipment[x]) for x in ['sword', 'shield']]
                        item['transforms'] = [*pose['sword_position'], pose['sword_degrees'], *pose['shield_position'], pose['shield_degrees']]
                    elif 'file' in equipment:
                        item['equipment'] = [resource(equipment['file'])]
                        item['transforms'] = [*pose['position'], pose['degrees']]
                rendered.append(item)
            clips.append({'key': clip, 'frames': rendered})
        bridge['actors'].append({'key': key, 'clips': clips})
    for key, spec in catalog['environments'].items():
        bridge['environments'].append({'key': key, 'background': resource(spec['background']), 'tile': resource(spec['tiles']['top_1'])})
    bridge['actors'].append({'key': 'effect', 'clips': [
        {'key': key, 'frames': [{'file': resource(f), 'seconds': .08} for f in frames]}
        for key, frames in catalog['effects'].items()
    ]})
    files = {}
    for entry in catalog['files']:
        file = entry['file']
        resource(file)
        data = (SOURCE / file).read_bytes()
        assert digest(data) == entry['sha256'], file
        files[file] = data
    files['bridge.json'] = (json.dumps(bridge, ensure_ascii=False, indent=2)+'\n').encode('utf-8')
    manifest = {'classification': 'transitional-review-only', 'commercial_approved': False,
                'source_catalog_lf_sha256': digest(raw), 'pixel_operations': [],
                'files': [{'file': name, 'sha256': digest(data), 'bytes': len(data)} for name, data in sorted(files.items())]}
    files['IMPORT_MANIFEST.json'] = (json.dumps(manifest, indent=2)+'\n').encode('utf-8')
    return files


def metadata():
    for path in sorted((ROOT/'unity/Assets').rglob('*')):
        if path.suffix == '.meta':
            continue
        meta = Path(str(path)+'.meta')
        if meta.exists():
            continue
        guid = uuid.uuid5(uuid.NAMESPACE_URL, 'rastaquest/'+path.relative_to(ROOT).as_posix()).hex
        text = f'fileFormatVersion: 2\nguid: {guid}\n'
        if path.is_dir():
            text += 'folderAsset: yes\nDefaultImporter:\n  externalObjects: {}\n  userData: \n  assetBundleName: \n  assetBundleVariant: \n'
        elif path.suffix == '.cs':
            text += 'MonoImporter:\n  externalObjects: {}\n  serializedVersion: 2\n  defaultReferences: []\n  executionOrder: 0\n  icon: {instanceID: 0}\n  userData: \n  assetBundleName: \n  assetBundleVariant: \n'
        # Texture import settings are applied by ReviewImporter on the first real Editor import.
        meta.write_text('\n'.join(line.rstrip() for line in text.splitlines())+'\n', encoding='utf-8', newline='\n')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    files = build()
    for name, data in files.items():
        path = DEST/name
        if args.check:
            assert path.read_bytes() == data, f'Stale Unity import: {name}'
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
    if not args.check:
        metadata()
    guids = []
    for path in (ROOT/'unity/Assets').rglob('*'):
        if path.suffix == '.meta':
            continue
        meta = Path(str(path)+'.meta')
        assert meta.exists(), f'Missing Unity metadata: {path}'
        guid = next(line[6:] for line in meta.read_text(encoding='utf-8').splitlines() if line.startswith('guid: '))
        assert len(guid) == 32 and all(c in '0123456789abcdef' for c in guid), path
        guids.append(guid)
    assert len(guids) == len(set(guids)), 'Duplicate Unity GUID'
    print(f'RQ_UNITY_BRIDGE_OK {len(files)-2} unchanged PNG files; Unity import/runtime NOT tested')


if __name__ == '__main__':
    main()
