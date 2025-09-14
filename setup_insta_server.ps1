# Instagram Server Setup Script - PowerShell Version with GitHub Clone
Write-Host "===============================================" -ForegroundColor Green
Write-Host "Instagram Server Setup Script with GitHub Clone" -ForegroundColor Green  
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# Ask for subdomain
do {
    $subdomain = Read-Host "Enter your subdomain (example: myinstaapi)"
} while ([string]::IsNullOrWhiteSpace($subdomain))

Write-Host "Selected subdomain: $subdomain" -ForegroundColor Yellow
Write-Host "Your server will be available at: https://$subdomain.loca.lt" -ForegroundColor Yellow
Write-Host ""

# Check Node.js
Write-Host "Checking Node.js installation..." -ForegroundColor Cyan
try {
    $nodeVersion = node --version
    Write-Host "Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Node.js not found!" -ForegroundColor Red
    Write-Host "Please install Node.js from: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "Choose the LTS version and make sure to add to PATH during installation." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check npm  
try {
    $npmVersion = npm --version
    Write-Host "npm found: v$npmVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: npm not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check Git
Write-Host "Checking Git installation..." -ForegroundColor Cyan
try {
    $gitVersion = git --version
    Write-Host "Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Git not found!" -ForegroundColor Red
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host "Make sure to add Git to PATH during installation." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Set repository details
$repoUrl = "https://github.com/rkgcode/ig-postdownload-server-api.git"
$repoDir = "ig-postdownload-server-api"

# Clone repository if it doesn't exist
if (Test-Path $repoDir) {
    Write-Host "Repository directory already exists: $repoDir" -ForegroundColor Yellow
    Write-Host "Removing existing directory to clone fresh copy..." -ForegroundColor Yellow
    try {
        Remove-Item -Recurse -Force $repoDir
        Write-Host "Existing directory removed successfully." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to remove existing directory!" -ForegroundColor Red
        Write-Host "Please manually delete the '$repoDir' folder and run this script again." -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host "Cloning repository from GitHub..." -ForegroundColor Cyan
Write-Host "Repository URL: $repoUrl" -ForegroundColor White

try {
    git clone $repoUrl
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Repository cloned successfully!" -ForegroundColor Green
    } else {
        throw "Git clone failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Host "ERROR: Failed to clone repository!" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    Write-Host "You can also manually clone: git clone $repoUrl" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Navigate to the cloned directory
Write-Host ""
Write-Host "Entering repository directory: $repoDir" -ForegroundColor Cyan
try {
    Set-Location $repoDir
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to enter repository directory!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check if package.json exists
if (!(Test-Path "package.json")) {
    Write-Host "ERROR: package.json not found in the repository!" -ForegroundColor Red
    Write-Host "The repository structure might be different than expected." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
} else {
    Write-Host "Found package.json in repository." -ForegroundColor Green
}

# Check if index.js exists
if (!(Test-Path "index.js")) {
    Write-Host "ERROR: index.js not found in the repository!" -ForegroundColor Red
    Write-Host "The repository structure might be different than expected." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
} else {
    Write-Host "Found index.js in repository." -ForegroundColor Green
}

Write-Host ""

# Display package.json content
Write-Host "Repository package.json content:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
try {
    $packageContent = Get-Content "package.json" -Raw
    Write-Host $packageContent -ForegroundColor White
} catch {
    Write-Host "Could not read package.json content." -ForegroundColor Yellow
}
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Install dependencies
Write-Host "Installing npm dependencies..." -ForegroundColor Cyan
Write-Host "This may take a few minutes depending on your internet connection..." -ForegroundColor Yellow

try {
    npm install
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Dependencies installed successfully!" -ForegroundColor Green
    } else {
        throw "npm install failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    Write-Host "You can manually run: npm install" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check if localtunnel is installed globally
Write-Host "Checking localtunnel installation..." -ForegroundColor Cyan
try {
    $ltVersion = npm list -g localtunnel --depth=0 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "localtunnel is already installed globally." -ForegroundColor Green
    } else {
        throw "localtunnel not found globally"
    }
} catch {
    Write-Host "localtunnel not found globally. Installing..." -ForegroundColor Yellow
    try {
        npm install -g localtunnel
        if ($LASTEXITCODE -eq 0) {
            Write-Host "localtunnel installed successfully!" -ForegroundColor Green
        } else {
            Write-Host "Warning: Failed to install localtunnel globally." -ForegroundColor Yellow
            Write-Host "Installing localtunnel locally as fallback..." -ForegroundColor Yellow
            npm install localtunnel
            if ($LASTEXITCODE -eq 0) {
                Write-Host "localtunnel installed locally." -ForegroundColor Green
                $useLocalLT = $true
            } else {
                throw "Failed to install localtunnel locally as well"
            }
        }
    } catch {
        Write-Host "ERROR: Failed to install localtunnel!" -ForegroundColor Red
        Write-Host "You may need to run PowerShell as Administrator for global installs." -ForegroundColor Yellow
        Read-Host "Press Enter to continue without localtunnel"
        $skipLT = $true
    }
}

Write-Host ""

# Display final setup information
Write-Host "===============================================" -ForegroundColor Green
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Server Configuration:" -ForegroundColor White
Write-Host "  - Port: 9000" -ForegroundColor White
Write-Host "  - Local URL: http://localhost:9000" -ForegroundColor White
if (!$skipLT) {
    Write-Host "  - Public URL: https://$subdomain.loca.lt" -ForegroundColor White
}
Write-Host ""
Write-Host "Project Directory: $(Get-Location)" -ForegroundColor White
Write-Host ""

# Start services
Write-Host "Starting services..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

if (!$skipLT) {
    # Start localtunnel in background
    Write-Host "Starting localtunnel in background..." -ForegroundColor Cyan
    if ($useLocalLT) {
        # Use local localtunnel installation
        Start-Process powershell -ArgumentList "-Command", "Start-Sleep 5; npx localtunnel --port 9000 --subdomain $subdomain; Read-Host 'LocalTunnel stopped. Press Enter to close'" -WindowStyle Normal
    } else {
        # Use global localtunnel installation
        Start-Process powershell -ArgumentList "-Command", "Start-Sleep 5; lt --port 9000 --subdomain $subdomain; Read-Host 'LocalTunnel stopped. Press Enter to close'" -WindowStyle Normal
    }
    
    Write-Host "Waiting 3 seconds for localtunnel to initialize..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "Starting Instagram Proxy Server" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

if (!$skipLT) {
    Write-Host "🌐 Public URL: https://$subdomain.loca.lt" -ForegroundColor Yellow
}
Write-Host "🏠 Local URL: http://localhost:9000" -ForegroundColor Yellow
Write-Host ""
Write-Host "API Endpoints:" -ForegroundColor White
Write-Host "  GET  / - Server status" -ForegroundColor White
Write-Host "  POST /api/download - Download Instagram media" -ForegroundColor White
Write-Host ""
Write-Host "Example usage:" -ForegroundColor White
Write-Host "  curl -X POST https://$subdomain.loca.lt/api/download \" -ForegroundColor Gray
Write-Host "       -H 'Content-Type: application/json' \" -ForegroundColor Gray
Write-Host "       -d '{\"url\": \"https://instagram.com/p/XXXXXXXXX/\"}'" -ForegroundColor Gray
Write-Host ""
Write-Host "Server logs will appear below:" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

# Start the server
try {
    node index.js
} catch {
    Write-Host ""
    Write-Host "Server stopped or encountered an error." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "Server stopped." -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Read-Host "Press Enter to exit"