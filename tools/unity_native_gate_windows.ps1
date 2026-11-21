#requires -Version 5.1
<#
Rasta Quest: native validation on Windows for the editor pinned in ProjectVersion.txt.
No downloads, installs, licensing changes, secrets, merges or store publishing.
Usage:
  .\tools\unity_native_gate_windows.ps1 -CheckOnly
  .\tools\unity_native_gate_windows.ps1 -RunProbe
  .\tools\unity_native_gate_windows.ps1 -SkipAndroid -RunProbe
  .\tools\unity_native_gate_windows.ps1 -UnityExe 'D:\Unity\6000.6.10f1\Editor\Unity.exe' -RunProbe
Close any open Unity Editor using this project before full batchmode validation.
#>
[CmdletBinding()]
param(
    [string]$UnityExe = '',
    [switch]$CheckOnly,
    [switch]$PrepareOnly,
    [switch]$SkipWindows,
    [switch]$SkipAndroid,
    [switch]$RunProbe
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$project = Join-Path $root 'unity'
$versionFile = Join-Path $project 'ProjectSettings\ProjectVersion.txt'
if (-not (Test-Path -LiteralPath $versionFile -PathType Leaf)) { throw "Unity project missing: $versionFile" }
$versionMatch = [regex]::Match([IO.File]::ReadAllText($versionFile), '(?m)^m_EditorVersion:\s*([^\r\n]+)')
if (-not $versionMatch.Success) { throw 'ProjectVersion.txt has no m_EditorVersion' }
$requiredVersion = $versionMatch.Groups[1].Value.Trim()
$stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$evidenceDir = Join-Path $project ("Builds\NativeGate\" + $stamp)
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$steps = New-Object 'System.Collections.Generic.List[object]'
$artifacts = New-Object 'System.Collections.Generic.List[object]'
$report = [ordered]@{
    schema = 1; status = 'FAIL'; required_unity = $requiredVersion;
    date_utc = (Get-Date).ToUniversalTime().ToString('o');
    editor_exe = $null; project_path = $project; repository_head = $null;
    commercial_approved = $false; physical_android_verified = $false;
    physical_windows_verified = $false; scope = 'actual-unity-editor-builds';
    steps = @(); artifacts = @(); error = $null
}
function Add-Step([string]$Name, [string]$Result, [string]$Details) {
    [void]$steps.Add([ordered]@{name=$Name;result=$Result;details=$Details})
    Write-Host ("[{0}] {1}: {2}" -f $Result,$Name,$Details)
}
function Locate-Editor {
    if ($UnityExe) { return [IO.Path]::GetFullPath($UnityExe) }
    $candidates = @()
    if ($env:ProgramFiles) { $candidates += Join-Path $env:ProgramFiles ("Unity\Hub\Editor\"+$requiredVersion+"\Editor\Unity.exe") }
    if ($env:LOCALAPPDATA) { $candidates += Join-Path $env:LOCALAPPDATA ("Programs\Unity\Hub\Editor\"+$requiredVersion+"\Editor\Unity.exe") }
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    throw "Unity $requiredVersion not found. Install through Unity Hub or pass -UnityExe with the exact Editor path."
}
function Invoke-Editor([string]$Method, [string]$BuildTarget, [string]$StepName) {
    $logFile = Join-Path $evidenceDir ($StepName + '.log')
    Write-Host ("Running Unity {0} ({1})" -f $Method,$BuildTarget)
    & $script:editorPath -batchmode -quit -projectPath $script:project -buildTarget $BuildTarget -executeMethod $Method -logFile $logFile
    $code = $LASTEXITCODE
    if ($code -ne 0) { throw "$StepName failed: Unity.exe exit=$code; log=$logFile" }
    $marker = if ($Method -eq 'RastaQuest.Editor.ReviewBuild.Prepare') { 'RQ_UNITY_PREPARE_OK' } else { 'RQ_UNITY_BUILD_OK' }
    if (-not (Test-Path -LiteralPath $logFile) -or -not (Select-String -Path $logFile -Pattern $marker -SimpleMatch -Quiet)) {
        throw "$StepName had no $marker marker. Inspect $logFile"
    }
    Add-Step $StepName 'PASS' $logFile
}
function Record-Artifact([string]$Path, [string]$Kind) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing artifact: $Path" }
    $item = Get-Item -LiteralPath $Path
    if ($item.Length -lt 1024) { throw "Unexpectedly small artifact: $Path" }
    $hash = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
    [void]$artifacts.Add([ordered]@{type=$Kind;path=$item.FullName;bytes=$item.Length;sha256=$hash})
    Add-Step "artifact:$Kind" 'PASS' ("{0} bytes, SHA256 {1}" -f $item.Length,$hash)
}
$exitCode = 1
try {
    $editorPath = Locate-Editor
    if (-not (Test-Path -LiteralPath $editorPath -PathType Leaf)) { throw "Unity.exe not found: $editorPath" }
    $report.editor_exe = $editorPath
    $editorFolder = Split-Path $editorPath -Parent
    $installedVersionFolder = Split-Path (Split-Path $editorFolder -Parent) -Leaf
    if ($installedVersionFolder -match '^\d+\.\d+\.\d+[a-z]\d+$' -and $installedVersionFolder -ne $requiredVersion) {
        throw "Editor mismatch: installed $installedVersionFolder but project requests $requiredVersion"
    }
    Add-Step 'editor-presence' 'PASS' $editorPath
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $head = (& git -C $root rev-parse HEAD 2>$null)
        if ($LASTEXITCODE -eq 0) { $report.repository_head = "$head".Trim() }
    }
    $androidRoot = Join-Path $editorFolder 'Data\PlaybackEngines\AndroidPlayer'
    $modulePaths = @(
        (Join-Path $androidRoot 'SDK'),
        (Join-Path $androidRoot 'NDK'),
        (Join-Path $androidRoot 'OpenJDK')
    )
    $missing = @($modulePaths | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Container) })
    if ($missing.Count -gt 0) { Add-Step 'android-modules' 'PENDING' ($missing -join ', ') }
    else { Add-Step 'android-modules' 'PASS' 'SDK, NDK and OpenJDK found' }
    if ($CheckOnly) {
        if (-not $SkipAndroid -and $missing.Count -gt 0) {
            throw 'Android Build Support/SDK/NDK/OpenJDK missing. Add modules using Unity Hub.'
        }
        $report.status = 'PREFLIGHT_PASS'
        $exitCode = 0
    } else {
        Invoke-Editor 'RastaQuest.Editor.ReviewBuild.Prepare' 'StandaloneWindows64' 'prepare'
        if (-not $PrepareOnly) {
            if (-not $SkipWindows) {
                Invoke-Editor 'RastaQuest.Editor.ReviewBuild.Windows' 'StandaloneWindows64' 'windows-build'
                $exe = Join-Path $project 'Builds\Windows\RastaQuestUnityReview.exe'
                Record-Artifact $exe 'windows-review-exe'
                $dataDir = Join-Path $project 'Builds\Windows\RastaQuestUnityReview_Data'
                if (-not (Test-Path -LiteralPath $dataDir -PathType Container)) { throw "Windows Data folder missing: $dataDir" }
            }
            if (-not $SkipAndroid) {
                if ($missing.Count -gt 0) { throw 'Android modules incomplete. Add modules in Unity Hub and rerun.' }
                Invoke-Editor 'RastaQuest.Editor.ReviewBuild.Android' 'Android' 'android-build'
                Record-Artifact (Join-Path $project 'Builds\Android\rasta-quest-unity-review.apk') 'android-development-apk'
            }
            if ($RunProbe) {
                if ($SkipWindows) { throw '-RunProbe requires Windows build; remove -SkipWindows' }
                $probeDir = Join-Path $evidenceDir 'NativeProbe'
                New-Item -ItemType Directory -Force -Path $probeDir | Out-Null
                $probeLog = Join-Path $evidenceDir 'native-probe.log'
                $exe = Join-Path $project 'Builds\Windows\RastaQuestUnityReview.exe'
                # Graphics enabled: captures from the real Unity player, not source mocks.
                $arguments = @('--rq-probe', ('"--rq-output=' + $probeDir + '"'), '-screen-width','1280','-screen-height','720','-logFile',('"' + $probeLog + '"'))
                $process = Start-Process -FilePath $exe -ArgumentList $arguments -WorkingDirectory (Split-Path $exe -Parent) -Wait -PassThru
                $probeReport = Join-Path $probeDir 'NATIVE_REPORT.json'
                if ($process.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $probeReport -PathType Leaf)) {
                    throw "Native probe failed ($($process.ExitCode)); inspect $probeLog"
                }
                $probe = Get-Content -LiteralPath $probeReport -Raw | ConvertFrom-Json
                if ($probe.status -ne 'PASS' -or $probe.engine -ne $requiredVersion -or @($probe.captures).Count -lt 8) {
                    throw "Native probe did not pass: $probeReport"
                }
                foreach ($capture in @($probe.captures)) {
                    if (-not (Test-Path -LiteralPath (Join-Path $probeDir $capture) -PathType Leaf)) {
                        throw "Missing native screenshot: $capture"
                    }
                }
                Add-Step 'windows-native-probe' 'PASS' $probeReport
            }
        }
        $report.status = 'PASS'
        $exitCode = 0
    }
} catch {
    $report.error = $_.Exception.Message
    Add-Step 'native-gate' 'FAIL' $report.error
} finally {
    $report.steps = @($steps.ToArray())
    $report.artifacts = @($artifacts.ToArray())
    $reportPath = Join-Path $evidenceDir 'NATIVE_GATE_REPORT.json'
    $report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $reportPath -Encoding UTF8
    Write-Host "Report: $reportPath"
    Write-Host 'Technical PASS is not physical or commercial approval.'
}
exit $exitCode
