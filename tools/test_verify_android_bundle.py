import unittest
from verify_android_bundle import parse_manifest
from verify_android_test_apk import validate_metadata

XML = """<manifest xmlns:android="http://schemas.android.com/apk/res/android"
package="com.tupiniquimtechsolution.rastaquest" android:versionCode="1000001" android:versionName="1.0.0-rc.1">
<uses-sdk android:minSdkVersion="24" android:targetSdkVersion="36"/>
</manifest>"""


class BundleManifest(unittest.TestCase):
    def test_reads_actual_bundle_contract(self):
        observed = parse_manifest(XML)
        self.assertEqual(observed["target_sdk"], 36)
        self.assertEqual(observed["min_sdk"], 24)
        self.assertIsNone(observed["max_sdk"])
        self.assertEqual(observed["permissions"], [])

    def test_does_not_hide_sdk_specific_permission(self):
        text = XML.replace("</manifest>", '<uses-permission-sdk-23 android:name="android.permission.CAMERA"/></manifest>')
        self.assertEqual(parse_manifest(text)["permissions"], ["android.permission.CAMERA"])

    def test_rejects_missing_or_malformed_sdk_metadata(self):
        with self.assertRaises(ValueError):
            parse_manifest(XML.replace('<uses-sdk android:minSdkVersion="24" android:targetSdkVersion="36"/>', ""))
        with self.assertRaises(ValueError):
            parse_manifest(XML.replace('android:targetSdkVersion="36"', 'android:targetSdkVersion="bad"'))

    def test_rejects_bundle_target_lower_than_store_contract(self):
        observed = parse_manifest(XML.replace('android:targetSdkVersion="36"', 'android:targetSdkVersion="35"'))
        expected = {"application_id": observed["application_id"], "version": observed["version"],
                    "version_code": observed["version_code"], "declared_permissions": [],
                    "architectures": ["arm64-v8a"], "target_sdk": 36,
                    "release_signed": False, "distribution_published": False}
        with self.assertRaises(ValueError):
            validate_metadata(observed, expected, ["arm64-v8a"])


if __name__ == "__main__":
    unittest.main()
