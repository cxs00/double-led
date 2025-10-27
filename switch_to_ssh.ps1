# Switch to SSH for GitHub push
# This script switches remote repository from HTTPS to SSH

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Switch to SSH Push Method" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if SSH key exists
$sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa.pub"

if (Test-Path $sshKeyPath) {
    Write-Host "[OK] SSH key found" -ForegroundColor Green
    
    # Display public key
    Write-Host "`nYour SSH public key:" -ForegroundColor Yellow
    Get-Content $sshKeyPath
    Write-Host ""
    
    Write-Host "Public key copied to clipboard!" -ForegroundColor Green
    Get-Content $sshKeyPath | Set-Clipboard
    
    Write-Host "`nPlease follow these steps:" -ForegroundColor Yellow
    Write-Host "1. Visit https://github.com/settings/keys" -ForegroundColor Cyan
    Write-Host "2. Click 'New SSH key'" -ForegroundColor Cyan
    Write-Host "3. Paste the public key and save" -ForegroundColor Cyan
    Write-Host "`nPress any key after you've added the key to GitHub..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} else {
    Write-Host "[!] No SSH key found, generating now..." -ForegroundColor Yellow
    Write-Host ""
    
    # Create .ssh directory if it doesn't exist
    $sshDir = "$env:USERPROFILE\.ssh"
    if (!(Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir | Out-Null
    }
    
    # Generate SSH key
    Write-Host "Generating SSH key..." -ForegroundColor Cyan
    ssh-keygen -t rsa -b 4096 -C "cxs00@github" -f "$env:USERPROFILE\.ssh\id_rsa" -N '""'
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[OK] SSH key generated successfully!" -ForegroundColor Green
        
        # Display public key
        Write-Host "`nYour SSH public key:" -ForegroundColor Yellow
        Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
        Write-Host ""
        
        Write-Host "Public key copied to clipboard!" -ForegroundColor Green
        Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub" | Set-Clipboard
        
        Write-Host "`nPlease follow these steps:" -ForegroundColor Yellow
        Write-Host "1. Visit https://github.com/settings/keys" -ForegroundColor Cyan
        Write-Host "2. Click 'New SSH key'" -ForegroundColor Cyan
        Write-Host "3. Paste the public key (in clipboard) and save" -ForegroundColor Cyan
        Write-Host "`nPress any key after you've added the key to GitHub..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } else {
        Write-Host "[X] SSH key generation failed" -ForegroundColor Red
        exit 1
    }
}

# Test SSH connection
Write-Host "`nTesting SSH connection to GitHub..." -ForegroundColor Green
$sshTest = ssh -T git@github.com 2>&1
Write-Host $sshTest

# Switch remote repository URL
Write-Host "`nSwitching remote repository to SSH..." -ForegroundColor Green
git remote set-url origin git@github.com:cxs00/double-led.git

# Verify configuration
Write-Host "`nCurrent remote repository:" -ForegroundColor Yellow
git remote -v

# Try to push
Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Starting push..." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
git push -u origin master

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[OK] Main branch pushed successfully!" -ForegroundColor Green
    
    # Push tags
    Write-Host "`nPushing tags..." -ForegroundColor Green
    git push origin --tags
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n=====================================" -ForegroundColor Cyan
        Write-Host "  [OK] Push Complete!" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Cyan
        Write-Host "`nVisit your repository: https://github.com/cxs00/double-led" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[X] Push failed" -ForegroundColor Red
    Write-Host "Please check if SSH key is correctly added to GitHub" -ForegroundColor Yellow
    Write-Host "Visit: https://github.com/settings/keys" -ForegroundColor Cyan
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

