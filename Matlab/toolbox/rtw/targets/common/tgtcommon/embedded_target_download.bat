@echo off
REM ********************************************************
REM
REM embedded_target_download.bat
REM
REM Batch file to launch the embedded_target_download 
REM GUI from a Windows command prompt.
REM (For releases since R13SP1)
REM
REM ********************************************************
REM 
if "%1"=="-help" goto HELP
cls
echo.
echo ------------------------------------------------------
echo Launching Embedded Target Download (Standalone)
echo (Embedded Target for Motorola MPC555 R13SP1 or later)
echo.
echo Note: For R13SP1 the utility may fail after the 
echo download has completed.  If this occurs, please
echo terminate the utility by pressing Ctrl-C in the DOS 
echo window, and then restart it.
echo. 
echo (run "embedded_target_download -help" for help)
echo ------------------------------------------------------
echo.

setlocal
REM Set DOWNLOAD_WORK_DIR to the directory where your applications are saved to.
set DOWNLOAD_WORK_DIR="d:\work_dirs\Aetargets\work"
echo Work directory is set to = %DOWNLOAD_WORK_DIR%
java -cp comm.jar;ecoder.jar com.mathworks.toolbox.ecoder.canlib.CanDownload.StandaloneMPC555Control %DOWNLOAD_WORK_DIR% "./" 
goto EXIT

:HELP
cls
echo -----------------------------------------------------
echo.
echo Embedded Target Download (Standalone) Help
echo (Embedded Target for Motorola MPC555 R13SP1 or later)
echo.
echo.
echo DOWNLOAD_WORK_DIR:
echo.     
echo The location used to look for application files to 
echo download. You can edit this batch file 
echo (embedded_target_download.bat) to set your own location.
echo.
echo.
echo Required Files for R13SP1 and later:
echo.
echo Copy the files listed below into a new directory, $(DOWNLOAD_TOOL), 
echo outside of your MATLAB installation.
echo.
echo $(DOWNLOAD_TOOL)/embedded_target_download.bat:
echo     This batch file (used to launch the download GUI)
echo.
echo $(DOWNLOAD_TOOL)/comm.jar: 
echo     Copy from $(MATLABROOT)\java\jarext\commapi\comm.jar
echo.
echo $(DOWNLOAD_TOOL)/ecoder.jar: 
echo     Copy from $(MATLABROOT)java\jar\toolbox\ecoder.jar
echo.
echo $(DOWNLOAD_TOOL)/vector_can_library_exports.dll: 
echo     Copy from $(MATLABROOT)\bin\win32\vector_can_library_exports.dll
echo.
echo $(DOWNLOAD_TOOL)/rxtxSerial.dll:
echo     Copy from $(MATLABROOT)\bin\win32\rxtxSerial.dll
echo.
echo.
echo EXTRA Required Files for R14 and later:
echo. 
echo $(DOWNLOAD_TOOL)/vector_can_library_standalone.dll: 
echo     Copy from $(MATLABROOT)\bin\win32\vector_can_library_standalone.dll
echo.
echo $(DOWNLOAD_TOOL)/mpc555dk/mpc555dk/mpc555bootver.txt: 
echo     Copy from $(MATLABROOT)\toolbox\rtw\targets\mpc555dk\mpc555dk\mpc555bootver.txt
echo.
echo.
echo Other Requirements:
echo.
echo Java Virtual Machine (JVM):
echo     This utility is written using Java, and requires a JVM
echo     in order to run.   Please install a Java Runtime Environment
echo     on your system and ensure that the path to the Java
echo     Interpreter is added to the system path, so that java.exe can
echo     be executed from the command line. (http://java.sun.com)
echo.
echo For downloading over CAN:
echo.
echo Vector-Informatik CAN Programming DLL (vcand32.dll): 
echo     This file is available from Vector-Informatik, and 
echo     must be somewhere on the system path (includes current dir)
echo     (http://www.vector-informatik.de/english)
echo.
echo Vector-Informatik CAN Drivers:
echo     Hardware drivers for your CAN hardware must be installed on the system.
echo     These drivers are available from Vector-Informatik
echo     (http://www.vector-informatik.de/english)
echo.
echo --------------------------------------------------------------------------
goto done


:EXIT 
echo.  
echo ---------------------------------
echo Finished Embedded Target Download 
echo ---------------------------------

:done
