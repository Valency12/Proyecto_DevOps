@echo off
setlocal
cd /d "%~dp0\.."

echo.
echo === PlusZone: aplicacion + Jenkins (Docker + GitHub en pipeline^) ===
docker info >nul 2>&1
if errorlevel 1 (
  echo ERROR: Docker no responde. Abre Docker Desktop y espera a que este listo.
  exit /b 1
)

docker compose -f docker-compose.yml -f docker-compose.jenkins.yml up -d --build
if errorlevel 1 exit /b 1

echo.
echo Listo - flujo local:
echo   Web ^(nginx^):  http://localhost:8888
echo   API:           http://localhost:4000
echo   Python:        http://localhost:5050
echo   Jenkins:       http://localhost:8090  -^> PlusZone-CI -^> Build Now
echo.
echo El pipeline clona desde GitHub; haz push del Jenkinsfile antes de la demo.
echo.
endlocal
