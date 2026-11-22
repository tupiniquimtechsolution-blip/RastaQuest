using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEditor.SceneManagement;
using UnityEngine;
using RastaQuest.Unity;

namespace RastaQuest.Editor
{
    public sealed class ReviewImporter : AssetPostprocessor
    {
        private void OnPreprocessTexture()
        {
            if(!assetPath.StartsWith("Assets/Resources/ReviewArt/"))return;
            var t=(TextureImporter)assetImporter;t.textureType=TextureImporterType.Sprite;t.spriteImportMode=SpriteImportMode.Single;
            t.spritePixelsPerUnit=64;t.filterMode=FilterMode.Point;t.wrapMode=TextureWrapMode.Clamp;t.alphaIsTransparency=true;
            t.textureCompression=TextureImporterCompression.Uncompressed;t.maxTextureSize=2048;t.mipmapEnabled=false;
        }
    }
    public static class ReviewBuild
    {
        public const string Scene="Assets/Scenes/UnityReview.unity";
        [MenuItem("Rasta Quest/Preparar sala Unity")]
        public static void Prepare()
        {
            // Missing Sprite subassets in Unity 6.6 do not require destructive
            // .meta rewrites. ReviewArt.Sprite creates a cached runtime Sprite
            // from an imported Texture2D as a transitional fallback.
            VerifyReviewSprites();
            Directory.CreateDirectory(Path.Combine(Application.dataPath, "Scenes"));
            var scene=EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,NewSceneMode.Single);
            new GameObject("RastaQuestUnityReview").AddComponent<SliceBootstrap>();
            EditorSceneManager.SaveScene(scene,Scene);EditorBuildSettings.scenes=new[]{new EditorBuildSettingsScene(Scene,true)};
            PlayerSettings.companyName="Tupiniquim";PlayerSettings.productName="Rasta Quest Unity Review";
            PlayerSettings.bundleVersion="1.0.0-unity.1";
            PlayerSettings.defaultInterfaceOrientation=UIOrientation.AutoRotation;
            PlayerSettings.allowedAutorotateToLandscapeLeft=true;PlayerSettings.allowedAutorotateToLandscapeRight=true;
            PlayerSettings.allowedAutorotateToPortrait=false;PlayerSettings.allowedAutorotateToPortraitUpsideDown=false;
            PlayerSettings.SetApplicationIdentifier(UnityEditor.Build.NamedBuildTarget.Android,"com.tupiniquim.rastaquest.unityreview");
            PlayerSettings.Android.bundleVersionCode=1000006;PlayerSettings.Android.minSdkVersion=(AndroidSdkVersions)25;PlayerSettings.Android.targetSdkVersion=(AndroidSdkVersions)36;
            PlayerSettings.Android.targetArchitectures=AndroidArchitecture.ARMv7|AndroidArchitecture.ARM64;
            PlayerSettings.SetScriptingBackend(UnityEditor.Build.NamedBuildTarget.Android,ScriptingImplementation.IL2CPP);
            PlayerSettings.SetUseDefaultGraphicsAPIs(BuildTarget.Android,false);
            PlayerSettings.SetGraphicsAPIs(BuildTarget.Android,new[]{UnityEngine.Rendering.GraphicsDeviceType.OpenGLES3});
            AssetDatabase.SaveAssets();Debug.Log("RQ_UNITY_PREPARE_OK — review only, final art and physical QA pending");
        }
        private static void VerifyReviewSprites()
        {
            string resourceFolder = Path.Combine(Application.dataPath, "Resources/ReviewArt");
            if (!Directory.Exists(resourceFolder))
                throw new System.InvalidOperationException("ReviewArt folder missing: " + resourceFolder);

            string[] pngFiles = Directory.GetFiles(resourceFolder, "*.png", SearchOption.AllDirectories);
            if (pngFiles.Length != 274)
                throw new System.InvalidOperationException("Expected 274 review PNGs, found " + pngFiles.Length);

            int spriteCount = 0, textureCount = 0;
            foreach (string pngFile in pngFiles)
            {
                string assetPath = "Assets" + pngFile.Substring(Application.dataPath.Length).Replace('\\', '/');
                if (AssetDatabase.LoadAssetAtPath<Sprite>(assetPath) != null)
                {
                    spriteCount++;
                    continue;
                }
                if (AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath) != null)
                {
                    // Texture2D is a valid review source: runtime uses Sprite.Create.
                    textureCount++;
                    continue;
                }
                throw new System.InvalidOperationException(
                    "ReviewArt PNG missing as Sprite AND Texture2D: " + assetPath +
                    ". Check image import errors, not the GameView resolution.");
            }

            // Avoid creating the scene unless the same resources are loadable
            // by the player, not just by the Editor asset database.
            const string example = "ReviewArt/chaser/chaser_attack_01";
            if (Resources.Load<Sprite>(example) == null && Resources.Load<Texture2D>(example) == null)
                throw new System.InvalidOperationException(
                    "ReviewArt example cannot be loaded by Resources: " + example);

            Debug.Log("RQ_UNITY_REVIEW_ASSETS_OK total=" + pngFiles.Length +
                      " importedSprites=" + spriteCount + " textureFallbacks=" + textureCount);
        }
        public static void Windows()
        {
            Prepare();Build(BuildTarget.StandaloneWindows64,"Builds/Windows/RastaQuestUnityReview.exe");
        }
        public static void Android()
        {
            Prepare();Build(BuildTarget.Android,"Builds/Android/rasta-quest-unity-review.apk");
        }
        private static void Build(BuildTarget target,string path)
        {
            // Resolve beneath the Unity project, regardless of the CLI working directory.
            string projectRoot=Directory.GetParent(Application.dataPath).FullName;
            string outputPath=Path.GetFullPath(Path.Combine(projectRoot,path));
            Directory.CreateDirectory(Path.GetDirectoryName(outputPath));
            var report=BuildPipeline.BuildPlayer(new BuildPlayerOptions{scenes=new[]{Scene},locationPathName=outputPath,target=target,options=BuildOptions.Development});
            if(report.summary.result!=BuildResult.Succeeded)throw new System.Exception("Unity review build failed: "+report.summary.result);
            Debug.Log("RQ_UNITY_BUILD_OK "+target+" bytes="+report.summary.totalSize);
        }
    }
}
