param(
    [int]$ListenPort = 8443,
    [string]$VncHost = "127.0.0.1",
    [int]$VncPort = 5900,
    [string]$CertPath = "scripts/certs/cert.pem",
    [string]$KeyPath = "scripts/certs/key.pem"
)

Write-Host "Setting up WSS gateway for Tiny10 (noVNC/websockify)" -ForegroundColor Cyan
Write-Host "Listen (WSS): port=$ListenPort" -ForegroundColor Cyan
Write-Host "Forward to VNC: $VncHost:$VncPort" -ForegroundColor Cyan

function Ensure-Python {
    $pythonCmds = @("python", "py")
    foreach ($cmd in $pythonCmds) {
        try { & $cmd --version > $null 2>&1; return $cmd } catch { }
    }
    throw "Python is required. Install Python 3 and ensure it is in PATH."
}

function Ensure-Websockify($pythonCmd) {
    try {
        & $pythonCmd -m websockify --help > $null 2>&1
        return
    } catch {
        Write-Host "Installing websockify via pip..." -ForegroundColor Yellow
        try { & $pythonCmd -m pip install websockify } catch { throw "Failed to install websockify. Ensure pip is available." }
    }
}

$python = Ensure-Python
Ensure-Websockify $python

if (-not (Test-Path $CertPath) -or -not (Test-Path $KeyPath)) {
    Write-Host "TLS cert/key not found: $CertPath / $KeyPath" -ForegroundColor Yellow
    Write-Host "Generate a self-signed cert for localhost using OpenSSL:" -ForegroundColor Yellow
    Write-Host "  openssl req -x509 -newkey rsa:2048 -keyout $KeyPath -out $CertPath -days 365 -nodes -subj \"/CN=localhost\"" -ForegroundColor Yellow
    Write-Host "Then re-run this script." -ForegroundColor Yellow
    exit 2
}

Write-Host "Starting websockify WSS proxy..." -ForegroundColor Cyan
& $python -m websockify $ListenPort "$VncHost:$VncPort" --cert "$CertPath" --key "$KeyPath"