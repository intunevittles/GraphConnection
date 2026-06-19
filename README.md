\# Graph Console CLI



A lightweight, multi-tenant Microsoft Graph CLI built in PowerShell.



\## Features

\- Interactive CLI (graph)

\- Quick connect (g <tenant>)

\- Device authentication (works anywhere)

\- Multi-tenant support

\- Token reuse (no repeated logins)



\---



\## 🚀 Full Setup (Copy/Paste Friendly)



\### 1. Clone Repo



```powershell

git clone https://github.com/<your-username>/GraphConsole.git

cd GraphConsole

```



\### 2. Install Microsoft Graph Module



```powershell

Install-Module Microsoft.Graph -Scope AllUsers -Force

```



\### 3. Configure PowerShell Profile



```powershell

notepad $PROFILE

```



Paste THIS into your profile:



```powershell

\# =========================

\# Graph Console Setup

\# =========================



$GraphHome = "C:\\Tools\\GraphConsole"



function graph {

&#x20;   . "$GraphHome\\GraphConsoleV1.8.ps1"

&#x20;   Start-GraphConsole

}



function g {

&#x20;   param($tenant)



&#x20;   . "$GraphHome\\GraphConsoleV1.8.ps1"



&#x20;   if (-not $tenant) {

&#x20;       Write-Host "Usage: g <tenant>" -ForegroundColor Red

&#x20;       return

&#x20;   }



&#x20;   # GUID

&#x20;   if ($tenant -match "^\[0-9a-fA-F-]{36}$") {

&#x20;       Connect-GraphClean -Tenant $tenant

&#x20;       return

&#x20;   }



&#x20;   # onmicrosoft domain

&#x20;   if ($tenant -match "\\.onmicrosoft\\.com$") {

&#x20;       Connect-GraphClean -Tenant $tenant

&#x20;       return

&#x20;   }



&#x20;   # Custom domain resolve → tenantID

&#x20;   try {

&#x20;       Write-Host "Resolving tenant for $tenant..." -ForegroundColor Yellow



&#x20;       $meta = Invoke-RestMethod `

&#x20;           -Uri "https://login.microsoftonline.com/$tenant/v2.0/.well-known/openid-configuration"



&#x20;       $tenantId = ($meta.issuer -split "/")\[3]



&#x20;       Write-Host "Resolved TenantId: $tenantId" -ForegroundColor Cyan



&#x20;       Connect-GraphClean -Tenant $tenantId

&#x20;   }

&#x20;   catch {

&#x20;       Write-Host "❌ Failed to resolve tenant: $tenant" -ForegroundColor Red

&#x20;   }

}

```



Reload your profile:



```powershell

. $PROFILE

```



\---



\## ✅ Usage



\### Launch Interactive Console

```powershell

graph

```



\### Quick Connect

```powershell

g contoso.com

g tenant.onmicrosoft.com

g 72f988bf-86f1-41af-91ab-2d7cd011db47

```



\---



\## ✅ Validation (IMPORTANT)



```powershell

Get-MgUser -Top 1

```



If this returns a user → ✅ fully connected  

If it errors → ❌ login not completed



\---



\## 🧠 Notes



\- Tokens are cached per tenant

\- First connection requires device login

\- Subsequent connections to same tenant are instant

\- Custom domains are automatically resolved to tenant ID



\---



\## 📁 Structure



```

GraphConsole/

&#x20;├── GraphConsoleV1.8.ps1

&#x20;└── README.md

```



\---



\## ⚡ Future Improvements



\- Auto-reconnect

\- Tenant history

\- Session switching

\- PowerShell module packaging

