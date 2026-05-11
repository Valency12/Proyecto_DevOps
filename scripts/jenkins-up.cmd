@echo off
setlocal
cd /d "%~dp0\.."

echo.
echo === Jenkins (Docker) - PlusZone ===
docker info >nul 2>&1
if errorlevel 1 (
  echo ERROR: Docker no responde. Abre Docker Desktop y espera a que este listo.
  exit /b 1
)

docker compose -f docker-compose.jenkins.yml up -d --build
if errorlevel 1 exit /b 1

echo.
echo Listo:
echo   Jenkins: http://localhost:8090
echo   Job:     PlusZone-CI  -^> Build Now
echo.
endlocal
