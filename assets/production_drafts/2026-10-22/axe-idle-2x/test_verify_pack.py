import unittest
from verify_pack import inspect_images, load_images


class PackChecks(unittest.TestCase):
    def setUp(self):
        self.images = load_images()

    def test_real_prototype_and_no_automatic_approval(self):
        result = inspect_images(self.images)
        self.assertTrue(result["prototype_integrity_pass"], result["errors"])
        self.assertFalse(result["automatic_approval"])

    def test_rotated_repaint_cannot_claim_rigid_rotation(self):
        altered = self.images["weapon_double_axe_rotation_90_01.png"].copy()
        altered.putpixel((200, 200), (17, 16, 20, 255))
        self.images["weapon_double_axe_rotation_90_01.png"] = altered
        self.assertIn("rotation_not_rigid_quarter_turn", inspect_images(self.images)["errors"])

    def test_moved_feet_are_rejected(self):
        altered = self.images["body_idle_02.png"].copy()
        altered.putpixel((100, 180), (17, 16, 20, 255))
        self.images["body_idle_02.png"] = altered
        self.assertIn("idle2:feet_drift", inspect_images(self.images)["errors"])

    def test_incomplete_set_is_rejected(self):
        self.images.pop("player_idle_04.png")
        self.assertFalse(inspect_images(self.images)["prototype_integrity_pass"])

    def test_wrong_frame_size_is_rejected(self):
        self.images["player_idle_01.png"] = self.images["player_idle_01.png"].crop((0, 0, 128, 128))
        self.assertIn("player_idle_01.png:frame_size", inspect_images(self.images)["errors"])

    def test_partial_alpha_is_rejected(self):
        altered = self.images["player_idle_01.png"].copy()
        altered.putpixel((100, 100), (17, 16, 20, 127))
        self.images["player_idle_01.png"] = altered
        self.assertIn("player_idle_01.png:partial_alpha", inspect_images(self.images)["errors"])


if __name__ == "__main__":
    unittest.main()
