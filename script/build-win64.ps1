# Build opencode-desktop Windows x64 EXE locally
# Usage: powershell -ExecutionPolicy Bypass -File script/build-win64.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$env:OPENCODE_CHANNEL = if ($env:OPENCODE_CHANNEL) { $env:OPENCODE_CHANNEL } else { "dev" }

Write-Host "==> Installing dependencies" -ForegroundColor Cyan
bun install --frozen-lockfile
if ($LASTEXITCODE -ne 0) { throw "bun install failed" }

Write-Host "==> Building opencode server" -ForegroundColor Cyan
bun run --cwd packages/opencode --conditions=browser build
if ($LASTEXITCODE -ne 0) { throw "opencode server build failed" }

Write-Host "==> Running desktop prebuild" -ForegroundColor Cyan
bun --cwd packages/desktop prebuild
if ($LASTEXITCODE -ne 0) { throw "desktop prebuild failed" }

Write-Host "==> Building desktop bundle" -ForegroundColor Cyan
bun --cwd packages/desktop build
if ($LASTEXITCODE -ne 0) { throw "desktop build failed" }

Write-Host "==> Packaging Windows x64" -ForegroundColor Cyan
Set-Location packages/desktop
bun x electron-builder --win --x64 --config electron-builder.config.ts
if ($LASTEXITCODE -ne 0) { throw "electron-builder failed" }
Set-Location $root

Write-Host "==> Done. Artifacts:" -ForegroundColor Green
Get-ChildItem packages/desktop/dist/*.exe | Select-Object Name, Length, LastWriteTime
