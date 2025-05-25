# build_apk.ps1
param(
    [ValidateSet("debug", "release")]
    [string]$BuildType = "debug"
)

$OutputDir = "./build/outputs"
$ApkName = if ($BuildType -eq "release") { "Card-Nudge-release.apk" } else { "Card-Nudge-debug.apk" }
$FlutterBuildOutput = if ($BuildType -eq "release") { "build/app/outputs/flutter-apk/app-release.apk" } else { "build/app/outputs/flutter-apk/app-debug.apk" }
$ApkName = "Card-Nudge.apk"
$FlutterBuildOutput = "build/app/outputs/flutter-apk/app-release.apk"

Write-Host "Cleaning Flutter project..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) { Write-Host "Error: Failed to clean project." -ForegroundColor Red; exit 1 }

Write-Host "Fetching dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) { Write-Host "Error: Failed to fetch dependencies." -ForegroundColor Red; exit 1 }

Write-Host "Generating Hive adapters..." -ForegroundColor Yellow
flutter packages pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) { Write-Host "Error: Failed to generate Hive adapters." -ForegroundColor Red; exit 1 }

Write-Host "Building release APK..." -ForegroundColor Yellow
flutter build apk --debug
if ($LASTEXITCODE -ne 0) { Write-Host "Error: Failed to build release APK." -ForegroundColor Red; exit 1 }

New-Item -ItemType Directory -Force -Path $OutputDir
if (Test-Path $FlutterBuildOutput) {
    Write-Host "APK built successfully. Renaming to $ApkName..." -ForegroundColor Green
    Move-Item -Path $FlutterBuildOutput -Destination "$OutputDir/$ApkName" -Force
    Write-Host "APK saved to $OutputDir/$ApkName" -ForegroundColor Green
} else {
    Write-Host "Error: APK not found at $FlutterBuildOutput." -ForegroundColor Red
    exit 1
}