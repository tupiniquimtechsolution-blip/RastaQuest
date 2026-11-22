using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace RastaQuest.Editor
{
    /// <summary>
    /// Repairs the GUID-only PNG .meta files shipped with transitional ReviewArt.
    /// Never deletes/recreates meta files; the GUIDs remain stable.
    /// Works around Unity 6000.6 TextureImporter metadata reserialization issues.
    /// </summary>
    public static class ReviewSpriteRepair
    {
        [MenuItem("Rasta Quest/Reparar metadados dos sprites (Unity 6.6)")]
        public static void RepairFromMenu()
        {
            Repair();
        }

        public static void Repair()
        {
            string folder = Path.Combine(Application.dataPath, "Resources/ReviewArt");
            if (!Directory.Exists(folder))
                throw new InvalidOperationException("ReviewArt not found: " + folder);

            string[] files = Directory.GetFiles(folder, "*.png", SearchOption.AllDirectories);
            if (files.Length != 274)
                throw new InvalidOperationException("Expected 274 ReviewArt PNGs, got " + files.Length);

            var paths = new List<string>(files.Length);
            foreach (string file in files)
                paths.Add("Assets" + file.Substring(Application.dataPath.Length).Replace('\\', '/'));
            paths.Sort(StringComparer.Ordinal);

            // Unity 6.6 can keep warning about obsolete TextureImporter .meta YAML
            // after a normal Reimport. Rewrite metadata rather than removing it.
            // This retains all Unity asset GUIDs and does not edit image bytes.
            Debug.Log("RQ_REVIEW_META_REPAIR_BEGIN sprites=" + paths.Count);
            AssetDatabase.ForceReserializeAssets(
                paths, ForceReserializeAssetsOptions.ReserializeMetadata);

            var failed = new List<string>();
            try
            {
                for (int i = 0; i < paths.Count; i++)
                {
                    string path = paths[i];
                    if (i % 10 == 0)
                        EditorUtility.DisplayProgressBar(
                            "Rasta Quest - reparar sprites",
                            "Atualizando " + (i + 1) + "/" + paths.Count + ": " + path,
                            (float)i / paths.Count);

                    var importer = AssetImporter.GetAtPath(path) as TextureImporter;
                    if (importer == null)
                    {
                        failed.Add(path + " (TextureImporter ausente)");
                        continue;
                    }

                    importer.textureType = TextureImporterType.Sprite;
                    importer.spriteImportMode = SpriteImportMode.Single;
                    importer.spritePixelsPerUnit = 64;
                    importer.filterMode = FilterMode.Point;
                    importer.wrapMode = TextureWrapMode.Clamp;
                    importer.alphaIsTransparency = true;
                    importer.mipmapEnabled = false;
                    importer.textureCompression = TextureImporterCompression.Uncompressed;
                    importer.maxTextureSize = 2048;

                    // Always save, including when getters already reported Sprite.
                    // A mere ForceUpdate without metadata serialization was insufficient.
                    importer.SaveAndReimport();

                    if (AssetDatabase.LoadAssetAtPath<Sprite>(path) == null)
                    {
                        AssetDatabase.ImportAsset(path,
                            ImportAssetOptions.ForceSynchronousImport |
                            ImportAssetOptions.ForceUpdate);
                    }
                    if (AssetDatabase.LoadAssetAtPath<Sprite>(path) == null)
                        failed.Add(path + " (Sprite ainda ausente)");
                }
            }
            finally
            {
                EditorUtility.ClearProgressBar();
                AssetDatabase.SaveAssets();
            }

            if (failed.Count != 0)
                throw new InvalidOperationException(
                    "RQ_REVIEW_META_REPAIR_FAILED: " + failed.Count +
                    " imagens sem Sprite. Primeiras: " +
                    string.Join("; ", failed.GetRange(0, Math.Min(5, failed.Count)).ToArray()));

            Debug.Log("RQ_REVIEW_META_REPAIR_OK total=" + paths.Count);
            EditorUtility.DisplayDialog("Rasta Quest",
                "274 sprites verificados. Agora clique em Rasta Quest > Preparar sala Unity.",
                "OK");
        }
    }
}
