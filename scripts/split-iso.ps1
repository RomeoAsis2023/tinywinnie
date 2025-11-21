param(
    [string]$Url,
    [string]$Input,
    [int]$ChunkSizeMB = 8
)

$ErrorActionPreference = "Stop"

if (-not $Url -and -not $Input) { throw "Provide -Url or -Input" }

$isoPath = if ($Input) { $Input } else { Join-Path (Get-Location) "Tiny10.iso" }

if ($Url) { Invoke-WebRequest -Uri $Url -OutFile $isoPath -UseBasicParsing }

if (-not (Test-Path $isoPath)) { throw "ISO not found: $isoPath" }

$outDir = Join-Path (Get-Location) "iso"
$partsDir = Join-Path $outDir "parts"
New-Item -ItemType Directory -Force -Path $partsDir | Out-Null

$fs = [System.IO.File]::OpenRead($isoPath)
$size = $fs.Length
$chunk = $ChunkSizeMB * 1MB
$parts = @()
$i = 1
$offset = 0
while ($offset -lt $size) {
    $remain = $size - $offset
    $len = [System.Math]::Min($chunk, $remain)
    $buf = New-Object byte[] $len
    [void]$fs.Read($buf, 0, $len)
    $name = ('part_{0:D4}.bin' -f $i)
    $path = Join-Path $partsDir $name
    [System.IO.File]::WriteAllBytes($path, $buf)
    $parts += @{ path = (Join-Path "iso/parts" $name); size = $len }
    $offset += $len
    $i++
}
$fs.Dispose()

$manifest = @{ name = (Split-Path $isoPath -Leaf); size = $size; parts = $parts }
$json = $manifest | ConvertTo-Json -Depth 4
Set-Content -Path (Join-Path $outDir "manifest.json") -Value $json -Encoding UTF8