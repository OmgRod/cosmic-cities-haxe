@echo off
REM Build for Windows without Discord RPC (avoids antivirus triggers)
lime build windows -cpp -DDISABLE_DISCORD_RPC
pause
