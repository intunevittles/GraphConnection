function Connect-GraphClean {
    param(
        [string]$Tenant,
        [string[]]$Scopes = @("User.ReadWrite.All","Directory.ReadWrite.All")
    )

    Import-Module Microsoft.Graph.Authentication -Force
    Import-Module Microsoft.Graph.Users -Force

    try { Disconnect-MgGraph -ErrorAction SilentlyContinue } catch {}

    Write-Host ""
    Write-Host "👇 DEVICE LOGIN PROMPT INCOMING 👇" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Starting device login..." -ForegroundColor Yellow
    Write-Host "Follow the prompt that appears below:" -ForegroundColor DarkGray

    # ✅ Launch browser automatically
    Start-Process "msedge.exe" "--no-first-run https://login.microsoftonline.com/device"

    # ✅ Let Graph handle auth (DO NOT TOUCH)
    Connect-MgGraph `
        -TenantId $Tenant `
        -UseDeviceAuthentication `
        -Scopes $Scopes `
        -NoWelcome

    # ✅ Smarter validation
    $ctx = Get-MgContext

    if ($ctx -and $ctx.Account -and $ctx.TenantId) {
        Write-Host "`n✅ Connected as $($ctx.Account)" -ForegroundColor Green
    }
    else {
        Write-Host "`n❌ Authentication incomplete or delayed" -ForegroundColor Red
    }

    return $ctx
}
