# =========================
# Graph Console Setup
# =========================

$GraphHome = "C:\Tools\GraphConsole"

function graph {
    . "$GraphHome\GraphConsoleV1.8.ps1"
    Start-GraphConsole
}

function g {
    param($tenant)

    . "$GraphHome\GraphConsoleV1.8.ps1"

    if (-not $tenant) {
        Write-Host "Usage: g <tenant>" -ForegroundColor Red
        return
    }

    # ✅ normalize tenant input
    if ($tenant -match "^[0-9a-fA-F-]{36}$") {
        Connect-GraphClean -Tenant $tenant
        return
    }

    if ($tenant -match "\.onmicrosoft\.com$") {
        Connect-GraphClean -Tenant $tenant
        return
    }

    try {
        Write-Host "Resolving tenant for $tenant..." -ForegroundColor Yellow

        $meta = Invoke-RestMethod `
            -Uri "https://login.microsoftonline.com/$tenant/v2.0/.well-known/openid-configuration"

        $tenantId = ($meta.issuer -split "/")[3]

        Write-Host "Resolved TenantId: $tenantId" -ForegroundColor Cyan

        Connect-GraphClean -Tenant $tenantId
    }
    catch {
        Write-Host "❌ Failed to resolve tenant" -ForegroundColor Red
    }
}
