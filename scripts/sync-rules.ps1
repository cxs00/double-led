# Git Bidirectional Sync Rules Script (PowerShell)
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("pull", "push", "status", "auto")]
    [string]$Command = "status"
)

$ErrorActionPreference = "Continue"
$PROXY = "http://127.0.0.1:7897"
$RULES_REPO = "https://github.com/cxs00/stm32-cursor-rules.git"
$RULES_FILE = ".cursor/rules/current/.cursorrules"

Write-Host "STM32 Cursor Rules Sync Tool" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

if ($Command -eq "status") {
    Write-Host "Local rules file:" -ForegroundColor Yellow
    if (Test-Path $RULES_FILE) {
        $hash = (Get-FileHash $RULES_FILE -Algorithm MD5).Hash.Substring(0,8)
        Write-Host "  File: $RULES_FILE [EXISTS]" -ForegroundColor Green
        Write-Host "  Hash: $hash..." -ForegroundColor Gray
    } else {
        Write-Host "  File: $RULES_FILE [NOT FOUND]" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Remote repository:" -ForegroundColor Yellow
    Write-Host "  $RULES_REPO" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\sync-rules.ps1 pull   - Pull from rules repo"
    Write-Host "  .\sync-rules.ps1 push   - Push to rules repo"
    Write-Host "  .\sync-rules.ps1 status - Show status"
    Write-Host "  .\sync-rules.ps1 auto   - Auto sync"
} elseif ($Command -eq "pull") {
    Write-Host "Pulling from rules repository..." -ForegroundColor Cyan
    $tempDir = Join-Path $env:TEMP "rules-pull-$(Get-Random)"
    git -c http.proxy=$PROXY clone --depth 1 $RULES_REPO $tempDir
    if ($LASTEXITCODE -eq 0) {
        Copy-Item "$tempDir\.cursorrules" $RULES_FILE -Force
        Write-Host "Rules synced successfully!" -ForegroundColor Green
        Remove-Item $tempDir -Recurse -Force
    }
} elseif ($Command -eq "push") {
    Write-Host "Pushing to rules repository..." -ForegroundColor Cyan
    Write-Host "This feature requires manual Git operations" -ForegroundColor Yellow
} else {
    Write-Host "Command: $Command" -ForegroundColor Yellow
}

Write-Host ""

