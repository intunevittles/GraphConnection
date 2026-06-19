# =========================
# Graph Console Installer
# =========================

Write-Host "=== Installing Graph Console ===" -ForegroundColor Cyan

$repo = "https://github.com/intunevittles/GraphConnection"
$zip = "$env:TEMP\graphconsole.zip"
$dest = "C:\Tools"

# ✅ Create base folder
if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest | Out-Null
}

# ✅ Download repo as zip
Write-Host "Downloading repo..." -ForegroundColor Yellow
Invoke-WebRequest "$repo/archive/refs/heads/main.zip" -OutFile $zip

# ✅ Extract
Write-Host "Extracting..." -ForegroundColor Yellow
Expand-Archive $zip -DestinationPath $dest -Force

# ✅ Find extracted folder
$extractPath = Join-Path $dest "GraphConnection-main"
$finalPath = Join-Path $dest "GraphConsole"

# ✅ Rename / move cleanly
if (Test-Path $finalPath) {
    Remove-Item $finalPath -Recurse -Force
}
Rename-Item $extractPath $finalPath

# ✅ Install Graph module
Write-Host "Installing Microsoft.Graph module..." -ForegroundColor Yellow
try {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force -ErrorAction Stop
} catch {
    Write-Host "Module install skipped or already present" -ForegroundColor DarkGray
}

# ✅ Configure PROFILE
$profilePath = $PROFILE

# Ensure profile file exists
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

Write-Host "Configuring PowerShell profile..." -ForegroundColor Yellow

$profileContent = @"
# =========================
# Graph Console Setup
# =========================

`$GraphHome = "C:\Tools\GraphConsole"

function graph {
    . "`$GraphHome\GraphConsoleV1.8.ps1"
    Start-GraphConsole
}

function g {
    param(`$tenant)

    . "`$GraphHome\GraphConsoleV1.8.ps1"

    if (-not `$tenant) {
        Write-Host "Usage: g <tenant>" -ForegroundColor Red
        return
    }

    if (`$tenant -match "^[0-9a-fA-F-]{36}$") {
        Connect-GraphClean -Tenant `$tenant
        return
    }

    if (`$tenant -match "\.onmicrosoft\.com$") {
        Connect-GraphClean -Tenant `$tenant
        return
    }

    try {
        `$meta = Invoke-RestMethod `
            -Uri "https://login.microsoftonline.com/`$tenant/v2.0/.well-known/openid-configuration"

        `$tenantId = (`$meta.issuer -split "/")[3]

        Connect-GraphClean -Tenant `$tenantId
    }
    catch {
        Write-Host "Failed to resolve tenant" -ForegroundColor Red
    }
}
"@

# ✅ Append (avoid overwriting existing stuff)
Add-Content -Path $profilePath -Value $profileContent

# ✅ Reload profile
. $profilePath

Write-Host "`n✅ Graph Console Installed!" -ForegroundColor Green
Write-Host "Run 'graph' or 'g <tenant>' to start." -ForegroundColor Cyan