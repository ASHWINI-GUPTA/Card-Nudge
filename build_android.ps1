<#
.SYNOPSIS
    Build Card Nudge Flutter app and auto-increment pubspec.yaml version.

.DESCRIPTION
    Supports APK and AppBundle, debug/release. Increments version in pubspec.yaml before build.
    Usage: .\build_android.ps1 [-Format apk|appbundle] [-Profile debug|release]

.PARAMETER Format
    Output format: apk or appbundle (default: apk)

.PARAMETER Profile
    Build profile: debug or release (default: debug)
#>

function Update-PubspecVersion {
    param(
        [string]$PubspecPath = "./pubspec.yaml"
    )
    # Backup pubspec.yaml
    Copy-Item $PubspecPath "$PubspecPath.bak" -Force

    $content = Get-Content $PubspecPath
    $versionLine = $content | Where-Object { $_ -match '^version:' }
    if ($versionLine) {
        $versionPattern = 'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)'
        if ($versionLine -match $versionPattern) {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            $patch = [int]$Matches[3] + 1
            $build = [int]$Matches[4] + 1
            $newVersion = "$major.$minor.$patch+$build"
            $newLine = "version: $newVersion"
            $newContent = $content -replace "^version:.*", $newLine
            Set-Content $PubspecPath $newContent
            Write-Host "pubspec.yaml version updated to $newVersion" -ForegroundColor Cyan
        }
    }
}

function Build-CardNudgeApp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("apk", "appbundle")]
        [string]$Format = "apk",

        [Parameter(Mandatory=$false)]
        [ValidateSet("debug", "release")]
        [string]$Profile = "debug",

        [Parameter(Mandatory=$false)]
        [string]$PubspecPath = "./pubspec.yaml"
    )

    $OutputDir = "./build/outputs"

    try {
        # Version bump
        Update-PubspecVersion -PubspecPath $PubspecPath

        Write-Host "Fetching dependencies..." -ForegroundColor Yellow
        flutter pub get
        if ($LASTEXITCODE -ne 0) { Write-Host "Error: Failed to fetch dependencies." -ForegroundColor Red; exit 1 }

        Write-Host "Cleaning Flutter project..." -ForegroundColor Yellow
        flutter clean
        if ($LASTEXITCODE -ne 0) { Write-Host "Error: Failed to clean project." -ForegroundColor Red; exit 1 }

        if ($Format -eq "apk") {
            $OutputName = if ($Profile -eq "release") { "Card-Nudge-release.apk" } else { "Card-Nudge-debug.apk" }
            $FlutterBuildOutput = if ($Profile -eq "release") { "build/app/outputs/flutter-apk/app-release.apk" } else { "build/app/outputs/flutter-apk/app-debug.apk" }
            $FlutterBuildCommand = "flutter build apk --$Profile"
        } else {
            $OutputName = if ($Profile -eq "release") { "Card-Nudge-release.aab" } else { "Card-Nudge-debug.aab" }
            $FlutterBuildOutput = if ($Profile -eq "release") { "build/app/outputs/bundle/release/app-release.aab" } else { "build/app/outputs/bundle/debug/app-debug.aab" }
            $FlutterBuildCommand = "flutter build appbundle --$Profile"
        }

        Write-Host "Building $Format ($Profile)..." -ForegroundColor Yellow
        Invoke-Expression $FlutterBuildCommand
        if ($LASTEXITCODE -ne 0) { Write-Host "Error: Failed to build $Format." -ForegroundColor Red; exit 1 }

        New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
        if (Test-Path $FlutterBuildOutput) {
            Write-Host "$Format built successfully. Renaming to $OutputName..." -ForegroundColor Green
            Move-Item -Path $FlutterBuildOutput -Destination "$OutputDir/$OutputName" -Force
            Write-Host "$Format saved to $OutputDir/$OutputName" -ForegroundColor Green
        } else {
            Write-Host "Error: $Format not found at $FlutterBuildOutput." -ForegroundColor Red
            exit 1
        }

        Write-Host "Build completed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Build failed: $_" -ForegroundColor Red
        exit 1
    }
}