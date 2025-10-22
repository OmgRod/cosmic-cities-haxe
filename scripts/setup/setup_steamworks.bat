@echo off
cd ../..
set /p STEAMPATH=Enter path to Steam SDK root (folder that contains "\redistributable_bin", no trailing slash):
set /p HXCPP=Enter path to hxccp root (folder that contains "\include", no trailing slash):

mkdir native\include\steam 2>nul
mkdir native\lib\win32 2>nul
mkdir native\lib\win64 2>nul
mkdir native\lib\osx64 2>nul
mkdir native\lib\linux32 2>nul
mkdir native\lib\linux64 2>nul
mkdir native\include\hx 2>nul

copy "%STEAMPATH%\public\steam\*.h" native\include\steam\
copy "%STEAMPATH%\redistributable_bin\steam_api.dll" native\lib\win32\
copy "%STEAMPATH%\redistributable_bin\steam_api.lib" native\lib\win32\
copy "%STEAMPATH%\redistributable_bin\win64\steam_api64.dll" native\lib\win64\
copy "%STEAMPATH%\redistributable_bin\win64\steam_api64.lib" native\lib\win64\
copy "%STEAMPATH%\redistributable_bin\osx\libsteam_api.dylib" native\lib\osx64\
copy "%STEAMPATH%\redistributable_bin\linux32\libsteam_api.so" native\lib\linux32\
copy "%STEAMPATH%\redistributable_bin\linux64\libsteam_api.so" native\lib\linux64\
copy "%HXCPP%\include\hx\*.h" native\include\hx
pause
cd scripts/setup