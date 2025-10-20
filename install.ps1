# M3U8 Downloader Installation Script for Windows PowerShell
# This script installs ffmpeg (if needed) and sets up the m3u8 downloader function

param(
    [switch]$Force
)

# Check execution policy and provide guidance
function Test-ExecutionPolicy {
    $currentPolicy = Get-ExecutionPolicy
    if ($currentPolicy -eq "Restricted") {
        Write-Warning "PowerShell execution policy is set to 'Restricted'"
        Write-Host "To fix this, run this command first:" -ForegroundColor Yellow
        Write-Host "Set-ExecutionPolicy Bypass -Scope Process" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Or run PowerShell as Administrator and execute:" -ForegroundColor Yellow
        Write-Host "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Continuing with installation anyway..." -ForegroundColor Green
    }
}

# Colors for output
$ErrorActionPreference = "Stop"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to check if ffmpeg is installed
function Test-FFmpeg {
    if (Test-Command "ffmpeg") {
        Write-Success "ffmpeg is already installed"
        try {
            ffmpeg -version | Select-Object -First 1
        }
        catch {
            Write-Warning "ffmpeg found but version check failed"
        }
        return $true
    }
    else {
        Write-Warning "ffmpeg is not installed"
        return $false
    }
}

# Function to install ffmpeg on Windows
function Install-FFmpeg {
    Write-Status "Installing ffmpeg on Windows..."
    
    if (Test-Command "winget") {
        Write-Status "Using winget to install ffmpeg..."
        try {
            winget install ffmpeg --accept-package-agreements --accept-source-agreements
            Write-Success "ffmpeg installed successfully via winget"
            return
        }
        catch {
            Write-Warning "winget installation failed: $($_.Exception.Message)"
        }
    }
    
    if (Test-Command "choco") {
        Write-Status "Using Chocolatey to install ffmpeg..."
        try {
            choco install ffmpeg -y
            Write-Success "ffmpeg installed successfully via Chocolatey"
            return
        }
        catch {
            Write-Warning "Chocolatey installation failed: $($_.Exception.Message)"
        }
    }
    
    if (Test-Command "scoop") {
        Write-Status "Using Scoop to install ffmpeg..."
        try {
            scoop install ffmpeg
            Write-Success "ffmpeg installed successfully via Scoop"
            return
        }
        catch {
            Write-Warning "Scoop installation failed: $($_.Exception.Message)"
        }
    }
    
    Write-Error "No package manager found. Please install ffmpeg manually:"
    Write-Host "  1. Download from: https://ffmpeg.org/download.html" -ForegroundColor Cyan
    Write-Host "  2. Or install a package manager:" -ForegroundColor Cyan
    Write-Host "     - winget (built-in on Windows 10/11)" -ForegroundColor Cyan
    Write-Host "     - Chocolatey: https://chocolatey.org/install" -ForegroundColor Cyan
    Write-Host "     - Scoop: https://scoop.sh/" -ForegroundColor Cyan
    exit 1
}

# Function to get PowerShell profile path
function Get-PowerShellProfile {
    if ($PROFILE) {
        return $PROFILE
    }
    else {
        # Default PowerShell profile path
        return "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    }
}

# Function to check if m3u8 function already exists
function Test-M3U8Function {
    param([string]$ProfilePath)
    
    if (-not (Test-Path $ProfilePath)) {
        return $false
    }
    
    $content = Get-Content $ProfilePath -Raw
    return $content -match "function m3u8"
}

# Function to remove existing m3u8 function
function Remove-M3U8Function {
    param([string]$ProfilePath)
    
    Write-Warning "Removing existing m3u8 function..."
    
    if (Test-Path $ProfilePath) {
        $content = Get-Content $ProfilePath
        $newContent = @()
        $skipNext = $false
        
        foreach ($line in $content) {
            if ($line -match "function m3u8") {
                $skipNext = $true
                continue
            }
            elseif ($skipNext -and $line -match "^\s*}\s*$") {
                $skipNext = $false
                continue
            }
            elseif (-not $skipNext) {
                $newContent += $line
            }
        }
        
        $newContent | Set-Content $ProfilePath
    }
}

# Function to add the m3u8 function
function Add-M3U8Function {
    param([string]$ProfilePath)
    
    # Create profile directory if it doesn't exist
    $profileDir = Split-Path $ProfilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        Write-Status "Created PowerShell profile directory: $profileDir"
    }
    
    # Create profile file if it doesn't exist
    if (-not (Test-Path $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
        Write-Status "Created PowerShell profile: $ProfilePath"
    }
    
    # Add function to profile
    $functionCode = @"

# M3U8 Downloader
function m3u8 {
    `$link = Read-Host "Enter m3u8 link to download by ffmpeg"
    `$filename = Read-Host "Enter output filename"
    Write-Host "Starting download..." -ForegroundColor Yellow
    ffmpeg -i `$link -bsf:a aac_adtstoasc -vcodec copy -c copy -crf 50 "`$filename.mp4"
    if (`$LASTEXITCODE -eq 0) {
        `$fullPath = (Get-Location).Path + "\" + "`$filename.mp4"
        Write-Host "Download completed successfully! File saved to: `$fullPath" -ForegroundColor Green
    } else {
        Write-Host "Download failed!" -ForegroundColor Red
    }
}
"@
    
    Add-Content -Path $ProfilePath -Value $functionCode
    Write-Success "Added m3u8 function to $ProfilePath"
}

# Main installation process
function Main {
    Write-Status "Starting M3U8 Downloader installation for Windows PowerShell..."
    Write-Host ""
    
    # Check execution policy
    Test-ExecutionPolicy
    Write-Host ""
    
    # Check and install ffmpeg
    if (-not (Test-FFmpeg)) {
        Install-FFmpeg
        Write-Success "ffmpeg installation completed"
    }
    
    Write-Host ""
    
    # Get PowerShell profile path
    $profilePath = Get-PowerShellProfile
    
    Write-Status "Using PowerShell profile: $profilePath"
    
    # Check if function already exists
    if (Test-M3U8Function $profilePath) {
        Write-Warning "m3u8 function already exists in $profilePath"
        Remove-M3U8Function $profilePath
    }
    
    # Add the function
    Add-M3U8Function $profilePath
    
    Write-Host ""
    Write-Success "Installation completed successfully!"
    Write-Host ""
    Write-Status "To use the m3u8 downloader:"
    Write-Host "  1. Reload your PowerShell profile:" -ForegroundColor Cyan
    Write-Host "     . `$PROFILE" -ForegroundColor Cyan
    Write-Host "  2. Or restart PowerShell" -ForegroundColor Cyan
    Write-Host "  3. Then run: m3u8" -ForegroundColor Cyan
    Write-Host ""
    Write-Status "Usage:"
    Write-Host "  m3u8" -ForegroundColor Cyan
    Write-Host "  # Follow the prompts to enter m3u8 link and output filename" -ForegroundColor Cyan
    Write-Host ""
}

# Run main function
try {
    Main
}
catch {
    Write-Error "Installation failed: $($_.Exception.Message)"
    exit 1
}
