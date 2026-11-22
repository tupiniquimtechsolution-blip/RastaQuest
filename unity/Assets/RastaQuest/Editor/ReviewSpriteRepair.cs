using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace RastaQuest.Editor
{
    /// <summary>
    /// Read-only Unity 6.6 diagnostic for the 274 versioned review sprites.
    /// The former ForceReserializeAssets/SaveAndReimport repair was tried on
    /// 22 Nov 2026 and failed for all 274 assets when meta files lacked
    /// TextureImporter. Valid import metadata is now versioned in Git.
    /// Never rewrite sprites or GUIDs from an Editor menu.
    /// </summary>
    public static class ReviewSpriteRepair
    {
        [MenuItem("Rasta Quest/Verificar sprites da revisao (somente leitura)")]
        public static void VerifyFromMenu()
        {
            string folder = Path.Combine(Application.dataPath, "Resources/ReviewArt");
            if (!Directory.Exists(folder))
                throw new InvalidOperationException("ReviewArt folder missing: " + folder);

            string[] files = Directory.GetFiles(folder, "*.png", SearchOption.AllDirectories);
            if (files.Length != 274)
                throw new InvalidOperationException(
                    "RQ_UNITY_REVIEW_META_CHECK_FAILED expected=274 found=" + files.Length);

            var guids = new HashSet<string>(StringComparer.Ordinal);
            var failures = new List<string>();
            Array.Sort(files, StringComparer.Ordinal);
            foreach (string file in files)
            {
                string assetPath = "Assets" + file.Substring(Application.dataPath.Length).Replace('\\', '/');
                string meta = file + ".meta";
                if (!File.Exists(meta))
                {
                    failures.Add(assetPath + " (.meta absent)");
                    continue;
                }
                string yaml = File.ReadAllText(meta);
                Match guid = Regex.Match(yaml, @"(?m)^guid: ([0-9a-f]{32})\s*$");
                if (!guid.Success || !guids.Add(guid.Groups[1].Value))
                    failures.Add(assetPath + " (invalid or duplicate GUID)");
                if (!Regex.IsMatch(yaml, @"(?m)^TextureImporter:\s*$") ||
                    !Regex.IsMatch(yaml, @"(?m)^  spriteMode: 1\s*$") ||
                    !Regex.IsMatch(yaml, @"(?m)^  textureType: 8\s*$") ||
                    !Regex.IsMatch(yaml, @"(?m)^  spritePixelsToUnits: 64\s*$"))
                    failures.Add(assetPath + " (Sprite TextureImporter metadata absent)");
                if (AssetDatabase.LoadAssetAtPath<Sprite>(assetPath) == null)
                    failures.Add(assetPath + " (Unity does not import a Sprite)");
            }

            if (failures.Count != 0)
                throw new InvalidOperationException(
                    "RQ_UNITY_REVIEW_META_CHECK_FAILED problems=" + failures.Count +
                    ". First: " + string.Join("; ", failures.GetRange(0, Math.Min(5, failures.Count)).ToArray()) +
                    ". Restore the reviewed .meta files from the Unity 6.6 Git branch; " +
                    "do not use the obsolete automatic repair menu.");

            Debug.Log("RQ_UNITY_REVIEW_META_CHECK_OK total=274 importedSprites=274 guids=274 readOnly=true");
            EditorUtility.DisplayDialog("Rasta Quest",
                "274 Sprites e GUIDs verificados. Nenhum arquivo foi alterado.", "OK");
        }
    }
}
