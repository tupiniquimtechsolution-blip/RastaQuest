"""Failure cases for decoded APK metadata; real signing is verified only in CI."""
import io
import unittest
import zipfile
from verify_android_test_apk import parse_badging, validate_metadata, signer_fingerprints, validate_engine_libraries

BADGING = """package: name='com.tupiniquimtechsolution.rastaquest' versionCode='1000001' versionName='1.0.0-rc.1' platformBuildVersionName='15'
application-label:'Rasta Quest'
minSdkVersion:'24'
targetSdkVersion:'35'
native-code: 'arm64-v8a'
"""


class TestApkMetadata(unittest.TestCase):
    def setUp(self):
        self.expected = {"application_id": "com.tupiniquimtechsolution.rastaquest",
            "version_code": 1000001, "version": "1.0.0-rc.1", "declared_permissions": [],
            "architectures": ["arm64-v8a"], "release_signed": False, "distribution_published": False}

    def test_accepts_complete_debug_metadata(self):
        validate_metadata(parse_badging(BADGING), self.expected, {"arm64-v8a"})

    def test_rejects_missing_and_malformed_package_metadata(self):
        for text in ("application-label:'Rasta Quest'", "package: name='x'",
                     BADGING.replace("versionCode='1000001'", "versionCode='invalid'")):
            with self.subTest(text=text), self.assertRaises(ValueError):
                parse_badging(text)

    def test_rejects_other_app_and_version(self):
        for old, new in (("com.tupiniquimtechsolution.rastaquest", "com.other.game"),
                         ("1000001", "1000002"), ("1.0.0-rc.1", "1.0.0")):
            with self.subTest(field=old), self.assertRaises(ValueError):
                validate_metadata(parse_badging(BADGING.replace(old,new)),self.expected,{"arm64-v8a"})

    def test_rejects_undeclared_permissions_including_sdk_specific(self):
        for permission in ("uses-permission: name='android.permission.INTERNET'",
                           "uses-permission-sdk-23: name='android.permission.CAMERA'"):
            with self.subTest(permission=permission), self.assertRaises(ValueError):
                validate_metadata(parse_badging(BADGING+permission+"\n"),self.expected,{"arm64-v8a"})

    def test_rejects_missing_or_extra_native_architecture(self):
        for abis in (set(), {"x86_64"}, {"arm64-v8a","armeabi-v7a"}):
            with self.subTest(abis=abis), self.assertRaises(ValueError):
                validate_metadata(parse_badging(BADGING),self.expected,abis)

    def test_does_not_label_release_or_published_build_as_debug(self):
        for flag in ("release_signed", "distribution_published"):
            with self.subTest(flag=flag), self.assertRaises(ValueError):
                validate_metadata(parse_badging(BADGING),{**self.expected,flag:True},{"arm64-v8a"})

    def test_signer_labels_and_repeated_sdk_ranges_preserve_fingerprint(self):
        digest = "ab" * 32
        for prefix in ("Signer #1", "Signer (minSdkVersion=24, maxSdkVersion=32)"):
            with self.subTest(prefix=prefix):
                text = f"{prefix} certificate SHA-256 digest: {digest}\n"
                self.assertEqual(signer_fingerprints(text + text), {digest})
        self.assertEqual(signer_fingerprints("Signer #1 certificate SHA-256 digest: " + ":".join(["AB"]*32)),{digest})

    def test_missing_or_truncated_certificate_digest_is_rejected(self):
        for text in ("Verifies\n", "Signer #1 certificate SHA-256 digest: ab12\n"):
            with self.subTest(text=text), self.assertRaises(ValueError):
                signer_fingerprints(text)

    def test_universal_profile_rejects_previous_arm64_only_build(self):
        expected = {**self.expected, "architectures": ["armeabi-v7a", "arm64-v8a"]}
        with self.assertRaises(ValueError):
            validate_metadata(parse_badging(BADGING), expected, {"arm64-v8a"})
        validate_metadata(parse_badging(BADGING),expected,{"armeabi-v7a","arm64-v8a"})

    def test_android14_range_rejects_too_new_minimum_or_too_old_maximum(self):
        expected = {**self.expected,"installation_target":{"android_api":34}}
        for text in (BADGING.replace("minSdkVersion:'24'","minSdkVersion:'35'"),
                     BADGING+"maxSdkVersion:'33'\n"):
            with self.subTest(text=text), self.assertRaises(ValueError):
                validate_metadata(parse_badging(text),expected,{"arm64-v8a"})
        validate_metadata(parse_badging(BADGING),expected,{"arm64-v8a"})

    def test_sdk_metadata_must_be_present_and_match_declaration(self):
        for text in (BADGING.replace("minSdkVersion:'24'\n",""),
                     BADGING.replace("targetSdkVersion:'35'\n","")):
            with self.subTest(text=text), self.assertRaises(ValueError):
                parse_badging(text)
        for key,value in (("min_sdk",25),("target_sdk",34)):
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate_metadata(parse_badging(BADGING),{**self.expected,key:value},{"arm64-v8a"})
        self.assertEqual(parse_badging(BADGING.replace("minSdkVersion:","sdkVersion:"))["min_sdk"],24)

    def test_universal_engine_libraries_must_have_correct_elf_headers(self):
        def header(bits,machine):
            value=bytearray(20)
            value[:4]=b"\x7fELF"
            value[4]=bits
            value[5]=1
            value[18:20]=machine.to_bytes(2,"little")
            return value
        for arm32 in (None,header(2,183),header(1,40)):
            stream=io.BytesIO()
            with zipfile.ZipFile(stream,"w") as archive:
                archive.writestr("lib/arm64-v8a/libgodot_android.so",header(2,183))
                if arm32 is not None:
                    archive.writestr("lib/armeabi-v7a/libgodot_android.so",arm32)
            stream.seek(0)
            with zipfile.ZipFile(stream) as archive:
                if arm32==header(1,40):
                    result=validate_engine_libraries(archive,["armeabi-v7a","arm64-v8a"])
                    self.assertEqual(result["armeabi-v7a"]["elf_bits"],32)
                else:
                    with self.assertRaises(ValueError):
                        validate_engine_libraries(archive,["armeabi-v7a","arm64-v8a"])


if __name__ == "__main__":
    unittest.main()
