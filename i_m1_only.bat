@echo off
setlocal

REM ===============================
REM Mother 1 ONLY build pipeline
REM ===============================

REM Input / working files
set BASE_ROM=m12.gba
set WORK_ROM=test.gba
set OUT_ROM=Mother1_only.gba
set IPS_PATCH=tomato-m12-mother-1-only.ips

echo [1/4] Copying base ROM...
copy "%BASE_ROM%" "%WORK_ROM%" >nul

REM @introconv.exe  (disabled: intro screen not injected)

echo [2/4] Applying Mother 1 ASM patch...
xkas "%WORK_ROM%" m12.asm
IF ERRORLEVEL 1 (
  echo.
  echo [ERROR] xkas failed. Aborting.
  exit /b 1
)

echo [3/4] Inserting Mother 1 text/data...
insert_m1.exe
IF ERRORLEVEL 1 (
  echo.
  echo [ERROR] insert_m1 failed. Aborting.
  exit /b 1
)

echo [4/4] Applying M1-only selector IPS...

IF NOT EXIST "%IPS_PATCH%" (
  echo.
  echo [ERROR] Missing IPS patch: %IPS_PATCH%
  exit /b 1
)

REM IPS argument order for THIS tool:
REM ips.exe <input rom> <patch.ips> <output rom>
ips.exe "%WORK_ROM%" "%IPS_PATCH%" "%OUT_ROM%"
IF ERRORLEVEL 1 (
  echo.
  echo [ERROR] IPS patch failed.
  exit /b 1
)

echo.
echo [DONE] Mother 1 isolated ROM created:
echo        %OUT_ROM%

echo.
echo Cleaning up temporary files...
IF EXIST "%WORK_ROM%" del "%WORK_ROM%"

endlocal
