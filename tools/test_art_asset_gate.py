"""Meaningful negative/positive fixtures for the pre-promotion gate."""
from io import BytesIO
import unittest
from PIL import Image
from art_asset_gate import inspect

class GateTest(unittest.TestCase):
    def check(self, image, size=None):
        buffer = BytesIO()
        image.save(buffer, format="PNG")
        buffer.seek(0)
        return inspect(buffer, size)

    def test_accepts_clean_frame_and_rejects_antialias_and_dimensions(self):
        image = Image.new("RGBA", (128, 128))
        image.putpixel((64, 90), (32, 64, 16, 255))
        self.assertTrue(self.check(image, (128, 128))["technical_export_pass"])
        self.assertIn("frame_size_mismatch", self.check(image, (64, 64))["errors"])
        image.putpixel((65, 90), (32, 64, 16, 127))
        self.assertIn("partial_alpha_requires_cleanup", self.check(image)["errors"])

    def test_rejects_opaque_and_empty_sources(self):
        self.assertIn("empty_image", self.check(Image.new("RGBA", (128, 128)))["errors"])
        self.assertIn("no_transparent_background", self.check(Image.new("RGB", (128, 128), "red"))["errors"])

if __name__ == "__main__":
    unittest.main()
