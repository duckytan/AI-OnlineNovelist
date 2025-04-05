# Set execution policy to allow scripts to run
Set-ExecutionPolicy Bypass -Scope Process -Force

# Create necessary directories
$aiProjectPath = "D:\AI-Project"
$mcpjsonPath = $env:USERPROFILE + "\.cursor\mcp.json"
$dPath = "D:\AI-Project\D"
$memoryFilePath = "D:\AI-Project\memory.json"

if (-not (Test-Path $aiProjectPath)) {
    New-Item -ItemType Directory -Path $aiProjectPath -Force
    Write-Host "Created directory: $aiProjectPath" -ForegroundColor Green
}

if (-not (Test-Path $dPath)) {
    New-Item -ItemType Directory -Path $dPath -Force
    Write-Host "Created directory: $dPath" -ForegroundColor Green
}

# Create empty memory.json file
if (-not (Test-Path $memoryFilePath)) {
    "{}" | Out-File -FilePath $memoryFilePath -Encoding utf8
    Write-Host "Created memory file: $memoryFilePath" -ForegroundColor Green
}

# Check if Node.js is installed
$nodeInstalled = $false
try {
    $nodeVersion = node -v
    $npmVersion = npm -v
    $nodeInstalled = $true
    Write-Host "Node.js is installed! Version: $nodeVersion" -ForegroundColor Green
    Write-Host "npm is installed! Version: $npmVersion" -ForegroundColor Green
} 
catch {
    Write-Host "Node.js is not installed, starting download and installation..." -ForegroundColor Yellow
}

# If Node.js is not installed, download and install it
if (-not $nodeInstalled) {
    # Download and install Node.js (includes npm)
    Write-Host "Downloading and installing Node.js..." -ForegroundColor Cyan
    $nodeUrl = "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi"
    $nodeInstallerPath = "$env:TEMP\node-installer.msi"
    Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstallerPath
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $nodeInstallerPath, "/quiet", "/norestart" -Wait
    Remove-Item $nodeInstallerPath -Force

    # Verify Node.js installation
    try {
        $nodeVersion = node -v
        $npmVersion = npm -v
        Write-Host "Node.js installation successful! Version: $nodeVersion" -ForegroundColor Green
        Write-Host "npm installation successful! Version: $npmVersion" -ForegroundColor Green
    } 
    catch {
        Write-Host "Node.js or npm installation failed, please install manually." -ForegroundColor Red
        exit 1
    }
}

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if Git is installed
$gitInstalled = $false
try {
    $gitVersion = git --version
    $gitInstalled = $true
    Write-Host "Git is installed! Version: $gitVersion" -ForegroundColor Green
} 
catch {
    Write-Host "Git is not installed, starting download and installation..." -ForegroundColor Yellow
}

# If Git is not installed, download and install it
if (-not $gitInstalled) {
    # Download and install Git
    Write-Host "Downloading and installing Git..." -ForegroundColor Cyan
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
    $gitInstallerPath = "$env:TEMP\git-installer.exe"
    Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstallerPath
    Start-Process -FilePath $gitInstallerPath -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
    Remove-Item $gitInstallerPath -Force

    # Verify Git installation
    try {
        $gitVersion = git --version
        Write-Host "Git installation successful! Version: $gitVersion" -ForegroundColor Green
    } 
    catch {
        Write-Host "Git installation failed, please install manually." -ForegroundColor Red
        exit 1
    }
}

# Check if Python is installed
$pythonInstalled = $false
try {
    $pythonVersion = python --version
    $pythonInstalled = $true
    Write-Host "Python is installed! Version: $pythonVersion" -ForegroundColor Green
} 
catch {
    Write-Host "Python is not installed, starting download and installation..." -ForegroundColor Yellow
}

# If Python is not installed, download and install it
if (-not $pythonInstalled) {
    # Download and install Python
    Write-Host "Downloading and installing Python..." -ForegroundColor Cyan
    $pythonUrl = "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe"
    $pythonInstallerPath = "$env:TEMP\python-installer.exe"
    Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstallerPath
    Start-Process -FilePath $pythonInstallerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "Include_test=0" -Wait
    Remove-Item $pythonInstallerPath -Force

    # Verify Python installation
    try {
        $pythonVersion = python --version
        Write-Host "Python installation successful! Version: $pythonVersion" -ForegroundColor Green
    } 
    catch {
        Write-Host "Python installation failed, please install manually." -ForegroundColor Red
        exit 1
    }
}

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if Visual Studio Build Tools is installed
$vsBuildToolsInstalled = $false
if (Test-Path "C:\BuildTools\MSBuild\Current\Bin\MSBuild.exe") {
    $vsBuildToolsInstalled = $true
    Write-Host "Visual Studio Build Tools is installed!" -ForegroundColor Green
}
else {
    Write-Host "Visual Studio Build Tools is not installed, starting download and installation..." -ForegroundColor Yellow
}

# If Visual Studio Build Tools is not installed, download and install it
if (-not $vsBuildToolsInstalled) {
    # Install Visual Studio Build Tools
    Write-Host "Downloading and installing Visual Studio Build Tools..." -ForegroundColor Cyan
    $vsUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe"
    $vsInstallerPath = "$env:TEMP\vs_buildtools.exe"
    Invoke-WebRequest -Uri $vsUrl -OutFile $vsInstallerPath

    # Install Visual Studio Build Tools with C++ build tools
    Start-Process -FilePath $vsInstallerPath -ArgumentList "--quiet", "--wait", "--norestart", "--nocache", `
        "--installPath", "C:\BuildTools", `
        "--add", "Microsoft.VisualStudio.Workload.VCTools", `
        "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64", `
        "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041" -Wait
    Remove-Item $vsInstallerPath -Force

    Write-Host "Visual Studio Build Tools installation completed" -ForegroundColor Green
}

# Check if MCP related dependencies are installed
Write-Host "Checking MCP related dependencies..." -ForegroundColor Cyan
$sequentialThinkingInstalled = $false
$memoryInstalled = $false
$filesystemInstalled = $false

try {
    $npmList = npm list -g
    if ($npmList -match "@modelcontextprotocol/server-sequential-thinking") {
        $sequentialThinkingInstalled = $true
        Write-Host "@modelcontextprotocol/server-sequential-thinking is installed" -ForegroundColor Green
    }
    if ($npmList -match "@modelcontextprotocol/server-memory") {
        $memoryInstalled = $true
        Write-Host "@modelcontextprotocol/server-memory is installed" -ForegroundColor Green
    }
    if ($npmList -match "@modelcontextprotocol/server-filesystem") {
        $filesystemInstalled = $true
        Write-Host "@modelcontextprotocol/server-filesystem is installed" -ForegroundColor Green
    }
}
catch {
    Write-Host "Error checking MCP dependencies, will try to install all dependencies" -ForegroundColor Yellow
}

# Install MCP related dependencies
Write-Host "Installing MCP related dependencies..." -ForegroundColor Cyan
if (-not $sequentialThinkingInstalled) {
    npm install -g @modelcontextprotocol/server-sequential-thinking
    Write-Host "@modelcontextprotocol/server-sequential-thinking installation completed" -ForegroundColor Green
}
if (-not $memoryInstalled) {
    npm install -g @modelcontextprotocol/server-memory
    Write-Host "@modelcontextprotocol/server-memory installation completed" -ForegroundColor Green
}
if (-not $filesystemInstalled) {
    npm install -g @modelcontextprotocol/server-filesystem
    Write-Host "@modelcontextprotocol/server-filesystem installation completed" -ForegroundColor Green
}

# Check if mcp.json file exists, if not create it
if (-not (Test-Path $mcpjsonPath)) {
    $mcpJsonContent = @'
{
    "mcpServers": {
      "sequential-thinking": {
          "_comment1": "Sequential Thinking",
          "command": "cmd",
          "args": [
            "/c",
            "npx",
            "@modelcontextprotocol/server-sequential-thinking"
          ]
      },
      "memory": {
          "_comment2": "Memory",
          "command": "cmd",
          "args": [
            "/c",
            "npx",
            "@modelcontextprotocol/server-memory"
          ],
          "env": {
            "MEMORY_FILE_PATH": "D:\\AI-Project"
          }
        },
      "filesystem": {
          "_comment3": "File System",
          "command": "cmd",
          "args": [
            "/c",
            "npx",
            "@modelcontextprotocol/server-filesystem",
            "D:\\AI-Project"
          ]
      }
    }
}
'@
    $mcpJsonContent | Out-File -FilePath $mcpjsonPath -Encoding utf8
    Write-Host "Created MCP configuration file: $mcpjsonPath" -ForegroundColor Green
}
else {
    Write-Host "MCP configuration file already exists: $mcpjsonPath" -ForegroundColor Green
}

Write-Host "All dependencies installation completed!" -ForegroundColor Green
Write-Host "Please restart your computer, then open Cursor and configure MCP service." -ForegroundColor Yellow
Write-Host "Your MCP configuration file is located at: $mcpjsonPath" -ForegroundColor Yellow