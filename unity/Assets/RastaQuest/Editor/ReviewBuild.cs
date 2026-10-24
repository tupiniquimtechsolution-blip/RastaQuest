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
