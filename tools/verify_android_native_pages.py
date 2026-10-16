"""Check ARM64 ELF LOAD alignment and uncompressed APK library offsets; no runtime claim."""
import argparse
import hashlib
import json
import struct
import zipfile
from pathlib import Path

PAGE_SIZE = 16384


def validate_elf64(data):
    if len(data) < 64 or data[:6] != b"\x7fELF\x02\x01":
        raise ValueError("Not a complete little-endian ELF64 header")
    if struct.unpack_from("<H", data, 18)[0] != 183:
        raise ValueError("ARM64 path contains another ELF machine")
    offset = struct.unpack_from("<Q", data, 32)[0]
    entry_size, count = struct.unpack_from("<HH", data, 54)
    if entry_size < 56 or count == 0 or offset < 64 or offset + entry_size * count > len(data):
        raise ValueError("Invalid ELF program header table")
    loads = []
    for index in range(count):
        pos = offset + index * entry_size
        if struct.unpack_from("<I", data, pos)[0] != 1:
            continue
        file_offset, virtual_address = struct.unpack_from("<QQ", data, pos + 8)
        alignment = struct.unpack_from("<Q", data, pos + 48)[0]
        if alignment < PAGE_SIZE or alignment & (alignment - 1):
            raise ValueError("ARM64 LOAD segment is not aligned for 16 KB pages")
        if file_offset % PAGE_SIZE != virtual_address % PAGE_SIZE:
            raise ValueError("ARM64 LOAD offset/address are incongruent for 16 KB pages")
        loads.append(alignment)
    if not loads:
        raise ValueError("ELF has no LOAD segments")
    return loads


def verify(archive_path):
    is_bundle = archive_path.suffix.lower() == ".aab"
    evidence = []
    with archive_path.open("rb") as raw, zipfile.ZipFile(archive_path) as archive:
        if archive.testzip() is not None:
            raise ValueError("Archive CRC failed")
        for info in archive.infolist():
            parts = info.filename.split("/")
            if "lib" not in parts or not info.filename.endswith(".so"):
                continue
            lib_index = parts.index("lib")
            if lib_index + 2 != len(parts) - 1:
                continue
            abi = parts[lib_index + 1]
            record = {"file": info.filename, "abi": abi}
            if abi == "arm64-v8a":
                record["load_alignments"] = validate_elf64(archive.read(info))
                if is_bundle:
                    record["apk_zip_alignment"] = "pending-derived-apk-check"
                elif info.compress_type != zipfile.ZIP_STORED:
                    record["apk_zip_alignment"] = "compressed-library-extracted-at-install"
                else:
                    raw.seek(info.header_offset)
                    header = raw.read(30)
                    if len(header) != 30 or header[:4] != b"PK\x03\x04":
                        raise ValueError("Invalid local ZIP header")
                    name_size, extra_size = struct.unpack_from("<HH", header, 26)
                    data_offset = info.header_offset + 30 + name_size + extra_size
                    if data_offset % PAGE_SIZE:
                        raise ValueError(f"Uncompressed ARM64 library is not ZIP 16 KB aligned: {info.filename}")
                    record["apk_zip_alignment"] = "aligned-16k"
                    record["zip_data_offset"] = data_offset
            else:
                record["elf_16k_requirement"] = "not-applicable-to-32-bit-ABI"
            evidence.append(record)
    if not any(x["abi"] == "arm64-v8a" for x in evidence):
        raise ValueError("Archive has no ARM64 libraries")
    with archive_path.open("rb") as source:
        digest = hashlib.file_digest(source, "sha256").hexdigest()
    return {"artifact": archive_path.name, "sha256": digest, "native_libraries": evidence,
            "static_16k_checks": "pass", "runtime_16k": "not-tested",
            "store_approval": "pending", "production_signing": "not-asserted"}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = verify(args.archive)
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("RQ_ANDROID_NATIVE_PAGES_OK", result["artifact"], result["sha256"])
