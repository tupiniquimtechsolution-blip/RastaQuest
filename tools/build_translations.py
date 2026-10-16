"""Deterministically export the reviewed CSV catalog as native UTF-8 gettext resources."""
import argparse
import csv
import json
from pathlib import Path


def render(rows, locale):
    quote = lambda value: json.dumps(value, ensure_ascii=False)
    header = f"Language: {locale}\nContent-Type: text/plain; charset=UTF-8\n"
    lines = ['msgid ""', "msgstr " + quote(header), ""]
    seen = set()
    for row in rows:
        key = row["key"]
        if not key or key in seen or not row.get(locale):
            raise ValueError(f"Missing/duplicate key or translation: {key}/{locale}")
        seen.add(key)
        lines.extend(["msgid " + quote(key), "msgstr " + quote(row[locale]), ""])
    return "\n".join(lines)


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--check", action="store_true")
    a = p.parse_args()
    directory = Path("game/localization")
    with (directory / "strings.csv").open(encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    for locale in ("en", "pt_BR"):
        path = directory / f"strings.{locale}.po"
        text = render(rows, locale)
        if a.check:
            if not path.is_file() or path.read_text(encoding="utf-8") != text:
                raise SystemExit(f"Translation resource differs from CSV: {path}")
        else:
            path.write_text(text, encoding="utf-8")
    print(f"RQ_TRANSLATION_CATALOG_OK locales=2 keys={len(rows)}")
