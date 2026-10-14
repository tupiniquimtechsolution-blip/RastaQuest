"""Failure cases for decoded APK metadata; real signing is verified only in CI."""
import unittest
from verify_android_test_apk import parse_badging, validate_metadata

BADGING = """package: name='com.tupiniquimtechsolution.rastaquest' versionCode='1000001' versionName='1.0.0-rc.1' platformBuildVersionName='15'
application-label:'Rasta Quest'
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


if __name__ == "__main__":
    unittest.main()
