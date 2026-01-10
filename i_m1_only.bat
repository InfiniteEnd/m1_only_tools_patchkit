@echo off
copy m12.gba test.gba

REM @introconv.exe  (disabled: intro screen not injected)

@xkas test.gba m12.asm
IF ERRORLEVEL 1 (
  echo.
  echo [ERROR] xkas failed. Aborting before insert_m1.
  exit /b 1
)

@insert_m1.exe
