# Arranca Jenkins con Docker + job "PlusZone-CI" ligado a GitHub (Pipeline desde SCM).
# Requisito: Docker Desktop abierto y motor en ejecución (ver icono en bandeja).
#
# Si PowerShell bloquea npm.ps1, usa desde CMD: scripts\jenkins-up.cmd
# o: npm.cmd run jenkins:up

$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
$root = Get-Location

Write-Host ""
Write-Host "=== PlusZone: Jenkins + GitHub (Docker) ===" -ForegroundColor Cyan
Write-Host "Directorio: $root"

docker info | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Docker no responde. Abre Docker Desktop y espera a que termine de cargar." -ForegroundColor Red
    exit 1
}

Write-Host "Construyendo imagen y levantando contenedor..." -ForegroundColor Yellow
docker compose -f docker-compose.jenkins.yml up -d --build

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Listo." -ForegroundColor Green
Write-Host "  Interfaz Jenkins:  http://localhost:8090" -ForegroundColor Green
Write-Host "  Job de demo:       PlusZone-CI  (Pipeline desde GitHub -> rama main)" -ForegroundColor Green
Write-Host ""
Write-Host "Para la presentación:" -ForegroundColor Cyan
Write-Host "  1. Abre http://localhost:8090"
Write-Host "  2. Entra al job 'PlusZone-CI'"
Write-Host "  3. Pulsa 'Build Now' y abre la salida de consola del build"
Write-Host ""
Write-Host "Webhook GitHub -> Jenkins en tu PC requiere una URL pública (p. ej. ngrok)." -ForegroundColor DarkGray
Write-Host "  En local basta con 'Build Now' o Poll SCM en la config del job." -ForegroundColor DarkGray
Write-Host ""
