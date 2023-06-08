@echo off
cls
echo.
ECHO ===============================================================================
echo Paste or write the complete path to install.esd or install.wim file
echo ^(without quotes marks "" even if the path contains spaces^)
ECHO ===============================================================================
echo.
set /p WIMFILE=
if "%WIMFILE%"=="" echo Incorrect file name or path&echo.&PAUSE&GOTO :QUIT

title ESD ^<^> WIM
color 1f
%windir%\system32\reg.exe query "HKU\S-1-5-19" >nul 2>&1 || (
echo      -------
echo  *** WARNING ***
echo      -------
echo.
echo.
echo ADMINISTRATOR PRIVILEGES NOT DETECTED
echo ____________________________________________________________________________
echo.
echo This script require administrator privileges.
echo.
echo To do so, right click on this script and select 'Run as administrator'
echo.
echo.
echo.
echo Press any key to exit...
pause >nul
goto :eof
)
cd /d "%~dp0"
if exist "%CD%\dism\dism.exe" set Path=%CD%\dism;%Path%
SET ERRORTEMP=
set /A count=0

dism /get-wiminfo /wimfile:"%WIMFILE%" >nul 2>&1 || (
echo.
echo Incorrect file name or path
echo.
echo Press any key to exit.
pause >nul
goto :eof
)
setlocal EnableDelayedExpansion
FOR /F "tokens=2 delims=: " %%i IN ('dism /english /Get-WimInfo /WimFile:"%WIMFILE%" ^| findstr "Index"') DO SET images=%%i
for /L %%i in (1, 1, %images%) do call :setcount %%i

if "%WIMFILE:~-3%"=="esd" GOTO :ESDMENU
if "%WIMFILE:~-3%"=="wim" GOTO :WIMMENU
exit

:setcount
set /A count+=1
for /f "tokens=1* delims=: " %%i in ('dism /english /get-wiminfo /wimfile:"%WIMFILE%" /index:%1 ^| find /i "Name"') do set name%count%="%%j"
goto :eof

:ESDMENU
cls
ECHO ===============================================================================
ECHO.                   Detected ESD file contains %images% indexes:
ECHO.
for /L %%i in (1, 1, %images%) do (
ECHO.  %%i. !name%%i!
)
ECHO.
ECHO ===============================================================================
ECHO.                                  Options:
ECHO ===============================================================================
ECHO.                   1 - Export 1st index
ECHO.                   2 - Export all indexes
ECHO.                   3 - Export selected single index
ECHO.                   4 - Export selected range of indexes
ECHO ===============================================================================
ECHO.                            Press 'Q' to Quit
ECHO ===============================================================================

choice /c 1234q /n /m "Choose a menu option, or Q to quit: "
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP%==1 GOTO :ESD1
IF %ERRORTEMP%==2 GOTO :ESD2
IF %ERRORTEMP%==3 GOTO :ESD3
IF %ERRORTEMP%==4 GOTO :ESD4
IF %ERRORTEMP%==5 GOTO :QUIT
GOTO :MAINMENU

:ESD1
cls
IF EXIST "%CD%\install.wim" (
ECHO ===============================================================================
ECHO.  An install.wim file is already present in the current folder.
ECHO ===============================================================================
ECHO.
echo Press any key to exit.
pause >nul
GOTO :QUIT
)
ECHO ===============================================================================
Echo Exporting ESD Index 1 to a new install.wim file...
ECHO ===============================================================================
mkdir temp
dism /Quiet /Capture-Image /ImageFile:install.wim /CaptureDir:.\temp /Name:container /Compress:max /CheckIntegrity
rmdir /s /q temp
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:1 /DestinationImageFile:install.wim /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)
dism /Quiet /Delete-Image /ImageFile:install.wim /Index:1 /CheckIntegrity
echo.
echo Done.
echo.
echo Press any key to exit.
pause >nul
GOTO :QUIT

:ESD2
cls
IF EXIST "%CD%\install.wim" (
ECHO ===============================================================================
ECHO.  An install.wim file is already present in the current folder.
ECHO ===============================================================================
ECHO.
echo Press any key to exit.
pause >nul
GOTO :QUIT
)
ECHO ===============================================================================
Echo Exporting ESD Index 1 to a new install.wim file...
ECHO ===============================================================================
mkdir temp
dism /Quiet /Capture-Image /ImageFile:install.wim /CaptureDir:.\temp /Name:container /Compress:max /CheckIntegrity
rmdir /s /q temp
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:1 /DestinationImageFile:install.wim /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)
dism /Quiet /Delete-Image /ImageFile:install.wim /Index:1 /CheckIntegrity

if "%images%"=="1" (
echo.
echo Done.
echo.
echo Press any key to exit.
pause >nul
GOTO :QUIT
)

for /L %%i in (2, 1, %images%) do (
ECHO.
ECHO ===============================================================================
Echo Exporting ESD Index %%i to install.wim file...
ECHO ===============================================================================
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:%%i /DestinationImageFile:install.wim /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)
)
echo.
echo Done.
echo.
echo Press any key to exit.
pause >nul
GOTO :QUIT

:ESD3
cls
set _index=
ECHO ===============================================================================
ECHO.                   Detected ESD file contains %images% indexes:
ECHO.
for /L %%i in (1, 1, %images%) do (
ECHO.  %%i. !name%%i!
)
ECHO.
ECHO ===============================================================================
ECHO.                     Enter desired index number to export
ECHO ===============================================================================
ECHO.                    Enter zero '0' to go back to Main Menu
ECHO ===============================================================================
set /p _index= ^> 
if /i "%_index%"=="0" goto :ESDMENU
if [%_index%]==[] goto :ESD3
if /i %_index% GTR %images% echo.&echo Selected number is higher than available indexes&echo.&PAUSE&goto :ESD3

cls
IF EXIST "%CD%\install.wim" (
ECHO ===============================================================================
ECHO.  An install.wim file is already present in the current folder.
ECHO ===============================================================================
ECHO.
echo Press any key to exit.
pause >nul
GOTO :QUIT
)
ECHO ===============================================================================
Echo Exporting ESD Index %_index% to a new install.wim file...
ECHO ===============================================================================
mkdir temp
dism /Quiet /Capture-Image /ImageFile:install.wim /CaptureDir:.\temp /Name:container /Compress:max /CheckIntegrity
rmdir /s /q temp
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:%_index% /DestinationImageFile:install.wim /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)
dism /Quiet /Delete-Image /ImageFile:install.wim /Index:1 /CheckIntegrity
echo.
echo Done.
echo.
echo Press any key to exit.
pause >nul
GOTO :QUIT

:ESD4
cls
set _range=
set _start=
set _end=
ECHO ===============================================================================
ECHO.                   Detected ESD file contains %images% indexes:
ECHO.
for /L %%i in (1, 1, %images%) do (
ECHO.  %%i. !name%%i!
)
ECHO.
ECHO ===============================================================================
ECHO.              Enter desired Range of indexes to export: Start-End
ECHO.                          Example: 2-4 or 1-3 or 3-4
ECHO ===============================================================================
ECHO.                      Enter zero '0' to go back to Main Menu
ECHO ===============================================================================
set /p _range= ^> 
if /i "%_range%"=="0" goto :ESDMENU
if [%_range%]==[] goto :ESD4
for /f "tokens=1 delims=-" %%i in ('echo %_range%') do set _start=%%i
for /f "tokens=2 delims=-" %%i in ('echo %_range%') do set _end=%%i
if /i %_start% GTR %images% echo.&echo Range Start is higher than available indexes&echo.&PAUSE&goto :ESD4
if /i %_end% GTR %images% echo.&echo Range End is higher than available indexes&echo.&PAUSE&goto :ESD4
if /i %_start% EQU %_end% echo.&echo Range Start and End are equal. Use option 3 of main menu to export single index&echo.&PAUSE&goto :ESDMENU

cls
IF EXIST "%CD%\install.wim" (
ECHO ===============================================================================
ECHO.  An install.wim file is already present in the current folder.
ECHO ===============================================================================
ECHO.
echo Press any key to exit.
pause >nul
GOTO :QUIT
)
ECHO ===============================================================================
Echo Exporting ESD Index %_start% to a new install.wim file...
ECHO ===============================================================================
mkdir temp
dism /Quiet /Capture-Image /ImageFile:install.wim /CaptureDir:.\temp /Name:container /Compress:max /CheckIntegrity
rmdir /s /q temp
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:%_start% /DestinationImageFile:install.wim /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)
dism /Quiet /Delete-Image /ImageFile:install.wim /Index:1 /CheckIntegrity

set /a _start+=1
for /L %%i in (%_start%, 1, %_end%) do (
ECHO.
ECHO ===============================================================================
Echo Exporting ESD Index %%i to install.wim file...
ECHO ===============================================================================
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:%%i /DestinationImageFile:install.wim /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)
)
echo.
echo Done.
echo.
echo Press any key to exit.
pause >nul
GOTO :QUIT

:WIMMENU
cls
ECHO ===============================================================================
ECHO.                   Detected WIM file contains %images% indexes:
ECHO.
for /L %%i in (1, 1, %images%) do (
ECHO.  %%i. !name%%i!
)
ECHO.
ECHO ===============================================================================
ECHO.                                  Options:
ECHO ===============================================================================
ECHO.                   1 - Export 1st index
ECHO.                   2 - Export all indexes
ECHO.                   3 - Export selected single index
ECHO.                   4 - Export selected range of indexes
ECHO ===============================================================================
ECHO.                            Press 'Q' to Quit
ECHO ===============================================================================

choice /c 1234q /n /m "Choose a menu option, or Q to quit: "
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP%==1 GOTO :WIM1
IF %ERRORTEMP%==2 GOTO :WIM2
IF %ERRORTEMP%==3 GOTO :WIM3
IF %ERRORTEMP%==4 GOTO :WIM4
IF %ERRORTEMP%==5 GOTO :QUIT
GOTO :MAINMENU

:WIM1
cls
IF EXIST "%CD%\install.esd" (
ECHO ===============================================================================
ECHO.  An install.esd file is already present in the current folder.
ECHO ===============================================================================
ECHO.
echo Press any key to exit.
pause >nul
GOTO :QUIT
)
ECHO ===============================================================================
Echo Exporting WIM Index 1 to a new install.esd file...
ECHO ===============================================================================
echo.
echo *** This will require some time, high CPU and Disk usage, please be patient ***
echo.
dism /export-image /sourceimagefile:"%WIMFILE%" /Sourceindex:1 /destinationimagefile:install.esd /compress:recovery /checkintegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)
echo.
echo Done.
echo.
echo Press any key to exit.
pause >nul
GOTO :QUIT

:WIM2
cls
IF EXIST "%CD%\install.esd" (
ECHO ===============================================================================
ECHO.  An install.esd file is already present in the current folder.
ECHO ===============================================================================
ECHO.
echo Press any key to exit.
pause >nul
GOTO :QUIT
)
ECHO ===============================================================================
Echo Exporting WIM Index 1 to a new install.esd file...
ECHO ===============================================================================
echo.
echo *** This will require some time, high CPU and Disk usage, please be patient ***
echo.
dism /Export-Image /SourceImageFile:"%WIMFILE%" /Sourceindex:1 /DestinationImageFile:install.esd /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)

if "%images%"=="1" (
echo.
echo Done.
echo.
echo Press any key to exit.
pause >nul
GOTO :QUIT
)

for /L %%i in (2, 1, %images%) do (
ECHO.
ECHO ===============================================================================
Echo Exporting WIM Index %%i to install.esd file...
ECHO ===============================================================================
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:%%i /DestinationImageFile:install.esd /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)
)
echo.
echo Done.
echo.
echo Press any key to exit.
pause >nul
GOTO :QUIT

:WIM3
cls
set _index=
ECHO ===============================================================================
ECHO.                   Detected WIM file contains %images% indexes:
ECHO.
for /L %%i in (1, 1, %images%) do (
ECHO.  %%i. !name%%i!
)
ECHO.
ECHO ===============================================================================
ECHO.                     Enter desired index number to export
ECHO ===============================================================================
ECHO.                    Enter zero '0' to go back to Main Menu
ECHO ===============================================================================
set /p _index= ^> 
if /i "%_index%"=="0" goto :WIMMENU
if [%_index%]==[] goto :WIM3
if /i %_index% GTR %images% echo.&echo Selected number is higher than available indexes&echo.&PAUSE&goto :WIM3

cls
IF EXIST "%CD%\install.esd" (
ECHO ===============================================================================
ECHO.  An install.esd file is already present in the current folder.
ECHO ===============================================================================
ECHO.
echo Press any key to exit.
pause >nul
GOTO :QUIT
)
ECHO ===============================================================================
Echo Exporting WIM Index %_index% to a new install.esd file...
ECHO ===============================================================================
echo.
echo *** This will require some time, high CPU and Disk usage, please be patient ***
echo.
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:%_index% /DestinationImageFile:install.esd /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)
echo.
echo Done.
echo.
echo Press any key to exit.
pause >nul
GOTO :QUIT

:WIM4
cls
set _range=
set _start=
set _end=
ECHO ===============================================================================
ECHO.                   Detected WIM file contains %images% indexes:
ECHO.
for /L %%i in (1, 1, %images%) do (
ECHO.  %%i. !name%%i!
)
ECHO.
ECHO ===============================================================================
ECHO.              Enter desired Range of indexes to export: Start-End
ECHO.                          Example: 2-4 or 1-3 or 3-4
ECHO ===============================================================================
ECHO.                      Enter zero '0' to go back to Main Menu
ECHO ===============================================================================
set /p _range= ^> 
if /i "%_range%"=="0" goto :WIMMENU
if [%_range%]==[] goto :WIM4
for /f "tokens=1 delims=-" %%i in ('echo %_range%') do set _start=%%i
for /f "tokens=2 delims=-" %%i in ('echo %_range%') do set _end=%%i
if /i %_start% GTR %images% echo.&echo Range Start is higher than available indexes&echo.&PAUSE&goto :WIM4
if /i %_end% GTR %images% echo.&echo Range End is higher than available indexes&echo.&PAUSE&goto :WIM4
if /i %_start% EQU %_end% echo.&echo Range Start and End are equal. Use option 3 of main menu to export single index&echo.&PAUSE&goto :WIMMENU

cls
IF EXIST "%CD%\install.esd" (
ECHO ===============================================================================
ECHO.  An install.esd file is already present in the current folder.
ECHO ===============================================================================
ECHO.
echo Press any key to exit.
pause >nul
GOTO :QUIT
)
ECHO ===============================================================================
Echo Exporting WIM Index %_start% to a new install.esd file...
ECHO ===============================================================================
echo.
echo *** This will require some time, high CPU and Disk usage, please be patient ***
echo.
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:%_start% /DestinationImageFile:install.esd /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)

set /a _start+=1
for /L %%i in (%_start%, 1, %_end%) do (
ECHO.
ECHO ===============================================================================
Echo Exporting WIM Index %%i to install.esd file...
ECHO ===============================================================================
dism /Export-Image /SourceImageFile:"%WIMFILE%" /SourceIndex:%%i /DestinationImageFile:install.esd /compress:recovery /CheckIntegrity
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% NEQ 0 (ECHO.&Echo Errors were reported during dism export.&PAUSE&GOTO :QUIT)
)
echo.
echo Done.
echo.
echo Press any key to exit.
pause >nul
GOTO :QUIT

:QUIT