import struct
import tempfile
import unittest
import zipfile
from pathlib import Path

from verify_android_native_pages import validate_elf64, verify


def elf(alignment=16384, file_offset=0, virtual_address=0):
    data = bytearray(120)
    data[:6] = b"\x7fELF\x02\x01"
    struct.pack_into("<H", data, 18, 183)
    struct.pack_into("<Q", data, 32, 64)
    struct.pack_into("<HH", data, 54, 56, 1)
    struct.pack_into("<I", data, 64, 1)
    struct.pack_into("<QQ", data, 72, file_offset, virtual_address)
    struct.pack_into("<Q", data, 112, alignment)
    return data


class NativePages(unittest.TestCase):
    def test_accepts_16k_and_larger_power_of_two(self):
        self.assertEqual(validate_elf64(elf()), [16384])
        self.assertEqual(validate_elf64(elf(65536)), [65536])

    def test_rejects_small_or_non_power_of_two_alignment(self):
        for align in [0, 4096, 20000]:
            with self.assertRaises(ValueError):
                validate_elf64(elf(align))

    def test_rejects_offset_address_mismatch(self):
        with self.assertRaises(ValueError):
            validate_elf64(elf(file_offset=4096))

    def test_rejects_missing_or_truncated_program_headers(self):
        for data in [b"", elf()[:100], elf()[:63]]:
            with self.assertRaises(ValueError):
                validate_elf64(data)

    def test_rejects_wrong_machine_and_absent_load_segment(self):
        for offset in [18, 64]:
            data = elf()
            struct.pack_into("<H" if offset == 18 else "<I", data, offset, 0)
            with self.assertRaises(ValueError):
                validate_elf64(data)

    def test_checks_uncompressed_apk_offset_but_not_aab_zip_offset(self):
        with tempfile.TemporaryDirectory() as temp:
            for suffix in [".apk", ".aab"]:
                path = Path(temp) / ("test" + suffix)
                with zipfile.ZipFile(path, "w") as archive:
                    archive.writestr("lib/arm64-v8a/engine.so", elf())
                if suffix == ".apk":
                    with self.assertRaises(ValueError):
                        verify(path)
                else:
                    self.assertEqual(verify(path)["runtime_16k"], "not-tested")

    def test_compressed_arm64_and_arm32_are_distinguished(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "test.apk"
            with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
                archive.writestr("lib/arm64-v8a/engine.so", elf())
                archive.writestr("lib/armeabi-v7a/engine.so", b"ARM32 fixture")
            result = verify(path)
            self.assertEqual(result["static_16k_checks"], "pass")
            self.assertEqual(result["native_libraries"][1]["elf_16k_requirement"], "not-applicable-to-32-bit-ABI")


if __name__ == "__main__":
    unittest.main()
