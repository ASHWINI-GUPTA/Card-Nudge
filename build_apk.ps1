function Build-CardNudgeApp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("apk", "appbundle")]
        [string]$Format = "apk",

        [Parameter(Mandatory=$false)]
        [ValidateSet("debug", "release")]
        [string]$Profile = "debug"
    )

    $OutputDir = "./build/outputs"

    if ($Format -eq "apk") {
        $OutputName = if ($Profile -eq "release") { "Card-Nudge-release.apk" } else { "Card-Nudge-debug.apk" }
        $FlutterBuildOutput = if ($Profile -eq "release") { "build/app/outputs/flutter-apk/app-release.apk" } else { "build/app/outputs/flutter-apk/app-debug.apk" }
        $FlutterBuildCommand = "flutter build apk --$Profile"
    } else {
        $OutputName = if ($Profile -eq "release") { "Card-Nudge-release.aab" } else { "Card-Nudge-debug.aab" }
        $FlutterBuildOutput = if ($Profile -eq "release") { "build/app/outputs/bundle/release/app-release.aab" } else { "build/app/outputs/bundle/debug/app-debug.aab" }
        $FlutterBuildCommand = "flutter build appbundle --$Profile"
    }

    Write-Host "Cleaning Flutter project..." -ForegroundColor Yellow
    flutter clean
    if ($LASTEXITCODE -ne 0) { Write-Host "Error: Failed to clean project." -ForegroundColor Red; exit 1 }

    Write-Host "Fetching dependencies..." -ForegroundColor Yellow
    Write-Host "Building $Format ($Profile)..." -ForegroundColor Yellow
    Invoke-Expression $FlutterBuildCommand
    if ($LASTEXITCODE -ne 0) { Write-Host "Error: Failed to build $Format." -ForegroundColor Red; exit 1 }

    New-Item -ItemType Directory -Force -Path $OutputDir
    if (Test-Path $FlutterBuildOutput) {
        Write-Host "$Format built successfully. Renaming to $OutputName..." -ForegroundColor Green
        Move-Item -Path $FlutterBuildOutput -Destination "$OutputDir/$OutputName" -Force
        Write-Host "$Format saved to $OutputDir/$OutputName" -ForegroundColor Green
    } else {
        Write-Host "Error: $Format not found at $FlutterBuildOutput." -ForegroundColor Red
        exit 1
    }
}