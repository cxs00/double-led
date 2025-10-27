# Auto Push to GitHub with Personal Access Token
# This script will push your code using a Personal Access Token

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  GitHub Auto Push" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "To use this script, you need a GitHub Personal Access Token." -ForegroundColor Yellow
Write-Host ""
Write-Host "If you don't have one:" -ForegroundColor Yellow
Write-Host "1. Visit: https://github.com/settings/tokens" -ForegroundColor Cyan
Write-Host "2. Click 'Generate new token (classic)'" -ForegroundColor Cyan
Write-Host "3. Select 'repo' permission" -ForegroundColor Cyan
Write-Host "4. Generate and copy the token" -ForegroundColor Cyan
Write-Host ""

# Prompt for token
Write-Host "Please enter your Personal Access Token:" -ForegroundColor Green
$token = Read-Host -AsSecureString

# Convert to plain text
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token)
$plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

if ([string]::IsNullOrWhiteSpace($plainToken)) {
    Write-Host "`n[X] No token provided. Exiting..." -ForegroundColor Red
    exit 1
}

# Configure Git to use the token
Write-Host "`nConfiguring Git credentials..." -ForegroundColor Green
$remoteUrl = "https://$plainToken@github.com/cxs00/double-led.git"
git remote set-url origin $remoteUrl

# Push main branch
Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Pushing main branch..." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
git push -u origin master --progress

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[OK] Main branch pushed successfully!" -ForegroundColor Green
    
    # Push tags
    Write-Host "`nPushing tags..." -ForegroundColor Green
    git push origin --tags --progress
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n=====================================" -ForegroundColor Cyan
        Write-Host "  [OK] Push Complete!" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Cyan
        Write-Host "`nYour repository: https://github.com/cxs00/double-led" -ForegroundColor Yellow
    } else {
        Write-Host "`n[X] Tag push failed" -ForegroundColor Red
    }
} else {
    Write-Host "`n[X] Push failed" -ForegroundColor Red
    Write-Host "Please check your token and try again" -ForegroundColor Yellow
}

# Reset URL to remove token from config
Write-Host "`nCleaning up..." -ForegroundColor Green
git remote set-url origin https://github.com/cxs00/double-led.git

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

