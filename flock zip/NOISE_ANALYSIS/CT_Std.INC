'================================================================================== CT_STD.INC

'DECLARATIONS AND EQUATE DEFINITIONS FOR CT_STD.DLL FROM PERFECT SYNC SOFTWARE

'Copyright © 1998-2001 Perfect Sync. Inc.  All rights reserved

'----------------------------------------------------------------------------
'TODO: BEFORE YOU CAN USE CONSOLE TOOLS FOR THE FIRST TIME YOU WILL NEED TO
'ENTER YOUR CONSOLE TOOLS AUTHORIZATION CODE WHERE YOU SEE THE 8 DOTS:
%MY_CT_AUTHCODE = &hacc5320D3
'----------------------------------------------------------------------------

DECLARE FUNCTION AlreadyRunning            LIB "CT_STD.DLL" ALIAS "AlreadyRunning"            (BYVAL sTitle AS STRING, BYVAL lAction AS LONG) AS LONG
DECLARE SUB      ClearSavedScreen          LIB "CT_STD.DLL" ALIAS "ClearSavedScreen"          (BYVAL lBufferNumber AS LONG)
DECLARE FUNCTION ColOfLoc                  LIB "CT_STD.DLL" ALIAS "ColOfLoc"                  (BYVAL lLoc AS LONG) AS LONG
DECLARE FUNCTION Console80x                LIB "CT_STD.DLL" ALIAS "Console80x"                (BYVAL lRows AS LONG) AS LONG
DECLARE FUNCTION ConsoleControl            LIB "CT_STD.DLL" ALIAS "ConsoleControl"            (BYVAL lParameter AS LONG, BYVAL lValue AS LONG) AS LONG
DECLARE SUB      ConsoleFocus              LIB "CT_STD.DLL" ALIAS "ConsoleFocus"
DECLARE FUNCTION ConsoleHasScrollBars      LIB "CT_STD.DLL" ALIAS "ConsoleHasScrollBars"      AS LONG
DECLARE FUNCTION ConsoleHasToolBar         LIB "CT_STD.DLL" ALIAS "ConsoleHasToolbar"         AS LONG
DECLARE FUNCTION ConsoleIcon               LIB "CT_STD.DLL" ALIAS "ConsoleIcon"               (BYVAL lResourceID AS DWORD) AS LONG
DECLARE FUNCTION ConsoleInfo               LIB "CT_STD.DLL" ALIAS "ConsoleInfo"               (BYVAL lParameter AS LONG) AS LONG
DECLARE FUNCTION ConsoleInputBox           LIB "CT_STD.DLL" ALIAS "ConsoleInputBox"           (BYVAL lType AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG, BYVAL sPrompt AS STRING, BYVAL sTitle AS STRING, _
                                                                                               BYVAL sDefault AS STRING, BYVAL lFlags AS LONG, BYVAL lNormalizeConsole AS LONG) AS STRING
DECLARE FUNCTION ConsoleInputBoxCancel     LIB "CT_STD.DLL" ALIAS "ConsoleInputBoxCancel"     AS LONG
DECLARE SUB      ConsoleInputBoxDefaults   LIB "CT_STD.DLL" ALIAS "ConsoleInputBoxDefaults"   (BYVAL lType AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG, BYVAL sPrompt AS STRING, BYVAL sTitle AS STRING, _
                                                                                               BYVAL sDefault AS STRING, BYVAL lFlags AS LONG, BYVAL lNormalizeConsole AS LONG)
DECLARE FUNCTION ConsoleIsForeground       LIB "CT_STD.DLL" ALIAS "ConsoleisForeground"       AS LONG
DECLARE FUNCTION ConsoleIsFullScreen       LIB "CT_STD.DLL" ALIAS "ConsoleIsFullScreen"       AS LONG
DECLARE FUNCTION ConsoleIsHidden           LIB "CT_STD.DLL" ALIAS "ConsoleIsHidden"           AS LONG
DECLARE FUNCTION ConsoleIsMaximized        LIB "CT_STD.DLL" ALIAS "ConsoleIsMaximized"        AS LONG
DECLARE FUNCTION ConsoleIsMinimized        LIB "CT_STD.DLL" ALIAS "ConsoleIsMinimized"        AS LONG
DECLARE FUNCTION ConsoleKey                LIB "CT_STD.DLL" ALIAS "ConsoleKey"                (BYVAL sKeyDef AS STRING) AS LONG
DECLARE FUNCTION ConsoleListBox            LIB "CT_STD.DLL" ALIAS "ConsoleListBox"            (BYVAL lType AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG, BYVAL sPrompt AS STRING, BYVAL sTitle AS STRING, BYREF sItems() AS STRING, _
                                                                                               BYVAL lDefault AS LONG, BYVAL lFlags AS LONG, BYVAL lNormalizeConsole AS LONG) AS STRING
DECLARE FUNCTION ConsoleListBoxDefaults    LIB "CT_STD.DLL" ALIAS "ConsoleListBoxDefaults"    (BYVAL lType AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG, BYVAL sPrompt AS STRING, BYVAL sTitle AS STRING, BYVAL sReserved AS STRING, _
                                                                                               BYVAL lDefault AS LONG, BYVAL lFlags   AS LONG, BYVAL lNormalizeConsole AS LONG) AS LONG
DECLARE FUNCTION ConsoleMessageBox         LIB "CT_STD.DLL" ALIAS "ConsoleMessageBox"         (BYVAL sText AS STRING, BYVAL lStyle AS LONG, BYVAL sTitle AS STRING, _
                                                                                               BYVAL lIconID AS LONG, BYVAL lNormalizeConsole AS LONG) AS LONG
DECLARE SUB      ConsoleMessageBoxDefaults LIB "CT_STD.DLL" ALIAS "ConsoleMessageBoxDefaults" (BYVAL sText AS STRING, BYVAL lStyle AS LONG, BYVAL sTitle AS STRING, _
                                                                                               BYVAL lIconID AS LONG, BYVAL lNormalizeConsole AS LONG)
DECLARE FUNCTION ConsoleMetrics            LIB "CT_STD.DLL" ALIAS "ConsoleMetrics"            (BYVAL lWhich AS LONG) AS LONG
DECLARE FUNCTION ConsoleMove               LIB "CT_STD.DLL" ALIAS "ConsoleMove"               (BYVAL lXPos AS LONG, BYVAL lYPos AS LONG) AS LONG
DECLARE SUB      ConsoleNormal             LIB "CT_STD.DLL" ALIAS "ConsoleNormal"
DECLARE FUNCTION ConsolePEEK               LIB "CT_STD.DLL" ALIAS "ConsolePEEK"               (BYVAL lWhich AS LONG, BYVAL lRow AS LONG, BYVAL lCol AS LONG, BYVAL lLength AS LONG) AS STRING
DECLARE SUB      ConsolePOKE               LIB "CT_STD.DLL" ALIAS "ConsolePOKE"               (BYVAL lWhich AS LONG, BYVAL sString AS STRING, BYVAL lRow AS LONG, BYVAL lCol AS LONG)
DECLARE FUNCTION ConsoleScreenLoad         LIB "CT_STD.DLL" ALIAS "ConsoleScreenLoad"         (BYVAL sLoadSpec AS STRING, BYVAL lFirstRow AS LONG, BYVAL lRows AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION ConsoleScreenSave         LIB "CT_STD.DLL" ALIAS "ConsoleScreenSave"         (BYVAL sSaveSpec AS STRING, BYVAL lFirstRow AS LONG, BYVAL lRows AS LONG) AS LONG
DECLARE FUNCTION ConsoleState              LIB "CT_STD.DLL" ALIAS "ConsoleState"              AS LONG
DECLARE FUNCTION ConsoleStretch            LIB "CT_STD.DLL" ALIAS "ConsoleStretch"            AS LONG
DECLARE FUNCTION ConsoleTitle              LIB "CT_STD.DLL" ALIAS "ConsoleTitle"              (BYVAL sTitle AS STRING) AS STRING
DECLARE FUNCTION ConsoleToForeground       LIB "CT_STD.DLL" ALIAS "ConsoleToForeGround"       (BYVAL lType AS LONG) AS LONG
DECLARE SUB      ConsoleToTop              LIB "CT_STD.DLL" ALIAS "ConsoleToTop"
DECLARE FUNCTION ConsoleToolBar            LIB "CT_STD.DLL" ALIAS "ConsoleToolBar"            (BYVAL lOnOff AS LONG, BYVAL lShow AS LONG) AS LONG
DECLARE FUNCTION ConsoleToolsSerialNumber  LIB "CT_STD.DLL" ALIAS "ConsoleToolsSerialNumber"  AS LONG
DECLARE FUNCTION ConsoleToolsAuthorize     LIB "CT_STD.DLL" ALIAS "ConsoleToolsAuthorize" (BYVAL dwAuthCode AS DWORD) AS LONG
DECLARE FUNCTION ConsoleToolsVersion       LIB "CT_STD.DLL" ALIAS "ConsoleToolsVersion"       AS LONG
DECLARE SUB      ConsoleTopMost            LIB "CT_STD.DLL" ALIAS "ConsoleTopMost"            (BYVAL lTopMost AS LONG)
DECLARE FUNCTION ConsoleWindow             LIB "CT_STD.DLL" ALIAS "ConsoleWindow"             (BYVAL lShow AS LONG) AS LONG
DECLARE FUNCTION CustomIcon                LIB "CT_PRO.DLL" ALIAS "CustomIcon"                (BYREF sFileName AS STRING) AS LONG
DECLARE SUB      DefaultWindowMenu         LIB "CT_STD.DLL" ALIAS "DefaultWindowMenu"
DECLARE SUB      Delay                     LIB "CT_STD.DLL" ALIAS "Delay"                     (BYVAL epSeconds AS EXT)
DECLARE FUNCTION DeleteWindowMenuItem      LIB "CT_STD.DLL" ALIAS "DeleteWindowMenuItem"      (BYVAL lItem AS LONG) AS LONG
DECLARE FUNCTION hConsoleWindow            LIB "CT_STD.DLL" ALIAS "hConsoleWindow"            AS LONG
DECLARE FUNCTION hConsoleWindowMenu        LIB "CT_STD.DLL" ALIAS "hConsoleWindowMenu"        AS LONG
DECLARE FUNCTION hCustomFont               LIB "CT_STD.DLL" ALIAS "hCustomFont"               AS LONG
DECLARE FUNCTION IString                   LIB "CT_STD.DLL" ALIAS "IString"                   (BYVAL sString AS STRING) AS STRING
DECLARE FUNCTION InitCTInternals           LIB "CT_STD.DLL" ALIAS "InitCTInternals"           AS LONG
DECLARE FUNCTION InitConsoleTools          LIB "CT_STD.DLL" ALIAS "InitConsoleTools"          (BYVAL hInstance AS LONG, BYVAL lMenuBuffers AS LONG, BYVAL lScreenBuffers AS LONG, _
                                                                                               BYVAL lReserved1 AS LONG, lReserved2 AS LONG, BYVAL lReserved3 AS LONG) AS LONG
DECLARE FUNCTION LocOfCol                  LIB "CT_STD.DLL" ALIAS "LocOfCol"                  (BYVAL lCol AS LONG) AS LONG
DECLARE FUNCTION LocOfRow                  LIB "CT_STD.DLL" ALIAS "LocOfRow"                  (BYVAL lRow AS LONG) AS LONG
DECLARE FUNCTION MouseOverCol              LIB "CT_STD.DLL" ALIAS "MouseOverCol"              AS LONG
DECLARE FUNCTION MouseOverConsole          LIB "CT_STD.DLL" ALIAS "MouseOverConsole"          AS LONG
DECLARE FUNCTION MouseOverRow              LIB "CT_STD.DLL" ALIAS "MouseOverRow"              AS LONG
DECLARE FUNCTION ProgressBoxCancel         LIB "CT_STD.DLL" ALIAS "ProgressBoxCancel"         AS LONG
DECLARE SUB      ProgressBoxDefaults       LIB "CT_STD.DLL" ALIAS "ProgressBoxDefaults"       (BYVAL lType AS LONG, BYVAL lPercent AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG, BYVAL sText AS STRING, _
                                                                                               BYVAL sTitle AS STRING, BYVAL lNormalizeConsole AS LONG)
DECLARE SUB      ProgressBoxHide           LIB "CT_STD.DLL" ALIAS "ProgressBoxHide"
DECLARE SUB      ProgressBoxRefresh        LIB "CT_STD.DLL" ALIAS "ProgressBoxRefresh"
DECLARE SUB      ProgressBoxShow           LIB "CT_STD.DLL" ALIAS "ProgressBoxShow"           (BYVAL lType AS LONG, BYVAL lPercent AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG, BYVAL sText AS STRING, _
                                                                                               BYVAL sTitle AS STRING, BYVAL lNormalizeConsole AS LONG)
DECLARE FUNCTION ProgressBoxUpdate         LIB "CT_STD.DLL" ALIAS "ProgressBoxUpdate"         (BYVAL lPercent AS LONG) AS LONG
DECLARE FUNCTION RowOfLoc                  LIB "CT_STD.DLL" ALIAS "RowofLoc"                  (BYVAL lLoc AS LONG) AS LONG
DECLARE SUB      SplashBoxDefaults         LIB "CT_STD.DLL" ALIAS "SplashBoxDefaults"         (BYVAL lType AS LONG, BYVAL lDelay AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG, BYVAL sLine1 AS STRING, _
                                                                                               BYVAL sLine2 AS STRING, BYVAL sLine3 AS STRING, BYVAL lIconID AS LONG, BYVAL lNormalizeConsole AS LONG)
DECLARE SUB      SplashBoxHide             LIB "CT_STD.DLL" ALIAS "SplashBoxHide"
DECLARE SUB      SplashBoxRefresh          LIB "CT_STD.DLL" ALIAS "SplashBoxRefresh"
DECLARE SUB      SplashBoxShow             LIB "CT_STD.DLL" ALIAS "SplashBoxShow"             (BYVAL lType AS LONG, BYVAL lDelay AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG, BYVAL sLine1 AS STRING, _
                                                                                               BYVAL sLine2 AS STRING, BYVAL sLine3 AS STRING, BYVAL lIconID AS LONG, BYVAL lNormalizeConsole AS LONG)
DECLARE FUNCTION ToggleConsoleToolbar      LIB "CT_STD.DLL" ALIAS "ToggleConsoleToolbar"      AS LONG
DECLARE SUB      ToggleFullScreenMode      LIB "CT_STD.DLL" ALIAS "ToggleFullScreenMode"
DECLARE FUNCTION VirtualKey                LIB "CT_STD.DLL" ALIAS "VirtualKey"                (BYVAL sKeyDef AS STRING) AS LONG
DECLARE FUNCTION WindowsVersion            LIB "CT_STD.DLL" ALIAS "WindowsVersion"            (BYVAL lType AS LONG) AS LONG
DECLARE FUNCTION ConsoleGfx                LIB "CT_STD.DLL" ALIAS "ConsoleGfx"                (BYVAL lLeftCol AS LONG, BYVAL lTopRow AS LONG, BYVAL lRightCol AS LONG, BYVAL lBottomRow AS LONG) AS LONG
DECLARE FUNCTION MatchConsoleFont          LIB "CT_STD.DLL" ALIAS "MatchConsoleFont"          (BYVAL lOption AS LONG) AS LONG
DECLARE FUNCTION GfxTextHole               LIB "CT_STD.DLL" ALIAS "GfxTextHole"               (BYVAL lNumber AS LONG, BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION ConsoleColor              LIB "CT_STD.DLL" ALIAS "ConsoleColor"              (BYVAL lColor AS LONG) AS LONG

'=======================================================================================

        '                  PRE-DEFINED EQUATES

        'These are general-purpose equates that are used by several functions...
        %OFF                                    = 0
        %ON                                     = -1    'see "Logical True" in the Help File

        %DEFAULT                                = 32768

        %CENTER                                 = 32767
        %DESKTOP_CENTER                         = %CENTER  'alternate name for %CENTER
        %CONSOLE_CENTER                         = 32766

        'These equates are used with the ConsoleInputBox function...
        %HOME                                   = 1
        %NOEDIT                                 = 2
        %PASSWORD                               = 4
        %FIXEDLEN                               = 8
        %WARNING                                = 16
        %BOLD                                   = 32
        %MONOSPACE                              = 64
        %CUSTOMFONT                             = 128

        'These equates are used with the MenuItemProperty function...
        %CHECKON                                = 1
        %CHECKOFF                               = 2
        %DISABLE                                = 3
        %ENABLE                                 = 4
        %HILITEON                               = 5
        %HILITEOFF                              = 6

        'These equates are used to tell the ConsoleMessageBox function which
        'buttons to display...
        %OKONLY                                 = 0
        %OKCANCEL                               = 1
        %ABORTRETRYIGNORE                       = 2
        %YESNOCANCEL                            = 3
        %YESNO                                  = 4
        %RETRYCANCEL                            = 5

        'These equates tell you which ConsoleMessageBox button was clicked...
        %OKBUTTON                               = 1
        %CANCELBUTTON                           = 2
        %ABORTBUTTON                            = 3
        %RETRYBUTTON                            = 4
        %IGNOREBUTTON                           = 5
        %YESBUTTON                              = 6
        %NOBUTTON                               = 7

        'These equates are used to tell the ConsoleMessageBox function which
        'standard icon and standard Windows Event Sound to use...
        %HANDBOX                                = &H10&
        %QUESTIONBOX                            = &H20&
        %EXCLAMATIONBOX                         = &H30&
        %INFOBOX                                = &H40&

        'These equates are used to tell the ConsoleMessageBox function which
        'button to highlight as the default button...
        %DEFBUTTON1                             = 0
        %DEFBUTTON2                             = &H100&
        %DEFBUTTON3                             = &H200&

        'These equates are used to tell the ConsoleMessageBox function
        '(and others) which type of "modality" to use.
        %APPLMODAL                              = 0
        %SYSTEMMODAL                            = &H1000&
        %TASKMODAL                              = &H2000&

        'Miscellaneous ConsoleMessageBox equates...
        %ICONMASK                               = &HF0&
        %NOFOCUS                                = &H8000&
        %SETFOREGROUND                          = &H10000&
        %TOPMOST                                = &H40000&
        %RIGHT                                  = &H80000&

        'This equate, along with %CANCELBUTTON from above, is used by
        'the ProgressBoxShow function.
        %NOCANCEL                               = 1

        'These equates can be used with the ConsoleListBox function...
        %MULTIPLE                               = 1
        %RETURN_INDEX                           = 2

        'These equates are used with the PopUpMenu function...
        %ALIGNDOWN                              = 1
        %ALIGNLEFT                              = 2
        %ALIGNRIGHT                             = 4
        %LEFTSIDE                               = 8
        %POPUP_NONE                             = 29   'same value as %PULLDOWN_NONE

        'These equates are used with the ConsoleWindow function
        'and several others...
        %HIDE                                   = 0
        %SHOWNORMAL                             = 1
        %SHOWMINIMIZED                          = 2
        %MAXIMIZE                               = 3
        %SHOWMAXIMIZED                          = 3  'same as %MAXIMIZE
        %SHOWNOACTIVATE                         = 4
        %SHOW                                   = 5
        %MINIMIZE                               = 6
        %SHOWMINNOACTIVE                        = 7
        %SHOWNA                                 = 8
        %RESTORE                                = 9
        %SHOWDEFAULT                            = 10
        %NO_CHANGE                              = 99
        %UNMINIMIZE                             = -1
        %FULLSCREEN                             = -2
        %WINDOW                                 = -3
        %TOGGLE                                 = -4

        'These equates are used with the ConsoleState function...
        %RESTORED                               = 1
        %MINIMIZED                              = 2
        %MAXIMIZED                              = 3

        'These equates are used with the ConsoleToForeground function...
        %SOFT                                   = 0
        %HARD                                   = -1

        'These equates are used with the RemoveWindowMenuItem function...
        %MENUITEM_SEPARATOR                     = &H0000&
        %MENUITEM_SIZE                          = &HF000&
        %MENUITEM_MOVE                          = &HF010&
        %MENUITEM_MINIMIZE                      = &HF020&
        %MENUITEM_MAXIMIZE                      = &HF030&
        %MENUITEM_CLOSE                         = &HF060&
        %MENUITEM_RESTORE                       = &HF120&
        %MENUITEM_PROPERTIES                    = -1
        %MENUITEM_TOOLBAR                       = -2
        %MENUITEM_EDIT                          = -3
        %MENUITEM_DEFAULTS                      = -4

        'These Win32 standard equates are used to define standard icons.
        'The $IF %DEF metastatements make sure that if you have already
        'defined these (possibly by using the WIN32API.INC file) they
        'won't be defined twice...

        $IF NOT %DEF(%IDI_APPLICATION)
                %IDI_APPLICATION        = 32512&
        $ENDIF

        $IF NOT %DEF(%IDI_HAND)
                %IDI_HAND               = 32513&
        $ENDIF

        $IF NOT %DEF(%IDI_QUESTION)
                %IDI_QUESTION           = 32514&
        $ENDIF

        $IF NOT %DEF(%IDI_EXCLAMATION)
                %IDI_EXCLAMATION        = 32515&
        $ENDIF

        $IF NOT %DEF(%IDI_ASTERISK)
                %IDI_ASTERISK           = 32516&
        $ENDIF

        $IF NOT %DEF(%IDI_WINLOGO)
                %IDI_WINLOGO            = 32517&
        $ENDIF

        'And Console Tools makes the following nonstandard icons available...

        %IDI_STOPSIGN                   = 32518&
        %IDI_BIGQUESTION                = 32519&
        %IDI_COMPUTER                   = 32520&

        'This equate is used for the Console Tools "Console Icon"
        %IDI_CONSOLE       = 1
        'This equate is used for the Console Tools "Custom Icon"
        %IDI_CUSTOM        = 2

        'These equates are used with the WindowsVersion function...
        %WIN_PLATFORM      = 0
        %WIN_MAJORVERSION  = 1
        %WIN_MINORVERSION  = 2
        %WIN_BUILDNUMBER   = 3

        %PLATFORM_WIN_32s  = 0
        %PLATFORM_WIN_32   = 1
        %PLATFORM_WIN_NT   = 2

        'These equates can be used with the ConsolePEEK and ConsolePOKE functions...
        %CHARS             = 0
        %COLORS            = 1

        'These equates are used with the ConsoleInfo function, among others...
        '-----------
        %CONSOLE_LEFT      = 0
        %CONSOLE_TOP       = 1
        %CONSOLE_RIGHT     = 2
        %CONSOLE_BOTTOM    = 3
        %CONSOLE_WIDTH     = 4
        %CONSOLE_HEIGHT    = 5
        %CONSOLE_MAX_WIDTH = 6
        %CONSOLE_MAX_HEIGHT= 7
        %BUFFER_WIDTH      = 8
        %BUFFER_HEIGHT     = 9
        '-----------
        %PRINTAREA_LEFT    = 10
        %PRINTAREA_TOP     = 11
        %PRINTAREA_RIGHT   = 12
        %PRINTAREA_BOTTOM  = 13
        %PRINTAREA_WIDTH   = 14
        %PRINTAREA_HEIGHT  = 15
        %PRINTAREA_X_CENTER= 16
        %PRINTAREA_Y_CENTER= 17
        '-----------
        %WINDOW_LEFT       = 20
        %WINDOW_TOP        = 21
        %WINDOW_RIGHT      = 22
        %WINDOW_BOTTOM     = 23
        %WINDOW_WIDTH      = 24
        %WINDOW_HEIGHT     = 25
        %WINDOW_X_CENTER   = 26
        %WINDOW_Y_CENTER   = 27
        '-----------
        %DESKTOP_LEFT      = 30
        %DESKTOP_TOP       = 31
        %DESKTOP_RIGHT     = 32
        %DESKTOP_BOTTOM    = 33
        %DESKTOP_WIDTH     = 34
        %DESKTOP_HEIGHT    = 35
        %DESKTOP_X_CENTER  = 36
        %DESKTOP_Y_CENTER  = 37
        '-----------
        %SCREEN_LEFT       = 40
        %SCREEN_TOP        = 41
        %SCREEN_RIGHT      = 42
        %SCREEN_BOTTOM     = 43
        %SCREEN_WIDTH      = 44
        %SCREEN_HEIGHT     = 45
        %SCREEN_X_CENTER   = 46
        %SCREEN_Y_CENTER   = 47

        '--------------------------------------

        'ConsoleMetrics function:

        %COL_WIDTH         = 1
        %ROW_HEIGHT        = 2

        %FRAME_WIDTH       = 3
        %FRAME_HEIGHT      = 4

        %VSCROLLBAR_WIDTH  = 5
        %HSCROLLBAR_HEIGHT = 6

        %TOOLBAR_HEIGHT    = 8

        %PULLDOWN_HEIGHT   = 10

        %TITLEBAR_HEIGHT   = 12

        %BORDER_SIZE       = 14

        '--------------------------------------

        'For the Graphics Tools "MatchConsoleFont" function...

        %HEIGHT_SAME            = 1
        %HEIGHT_150_PERCENT     = 4
        %HEIGHT_DOUBLE          = 16
        %HEIGHT_TRIPLE          = 20

        %WIDTH_SAME             = 2
        %WIDTH_150_PERCENT      = 8
        %WIDTH_DOUBLE           = 32
        %WIDTH_TRIPLE           = 40

        '--------------------------------------

        'These equates define the Accelerator Keys and other Pulldown
        'Menu return values.  Except for the Function Keys, which are
        'pressed alone, Accelerator Keys require the use of the Ctrl
        'key.  For example, pressing Ctrl-X would produce %PULLDOWN_X.

        'Items that are marked with [V] are DIFFERENT from the corresponding
        'equates in the %Virtual_ section.  You must be careful to use the
        'appropriate value (%Virtual_ vs. %Pulldown_) when working with these
        'keys.  For example, %Pulldown_F1 does not have the same numeric
        'value as %Virtual_F1.

      %Pulldown_Restore     = 10
        %Pulldown_Enter       = 13
        %Pulldown_Minimize    = 20
        %Pulldown_Escape      = 27
        %Pulldown_None        = 29
        %Pulldown_Close       = 30
        %Pulldown_F1          = 31      '[V]
        %Pulldown_F2          = 32      '[V]
        %Pulldown_F3          = 33      '[V]
        %Pulldown_F4          = 34      '[V]
        %Pulldown_F5          = 35      '[V]
        %Pulldown_F6          = 36      '[V]
        %Pulldown_F7          = 37      '[V]
        %Pulldown_F8          = 38      '[V]
        %Pulldown_F9          = 39      '[V]
        %Pulldown_F10         = 40      '[V]
        %Pulldown_F11         = 41      '[V]
        %Pulldown_F12         = 42      '[V]
        %Pulldown_0           = 48
        %Pulldown_1           = 49
        %Pulldown_2           = 50
        %Pulldown_3           = 51
        %Pulldown_4           = 52
        %Pulldown_5           = 53
        %Pulldown_6           = 54
        %Pulldown_7           = 55
        %Pulldown_8           = 56
        %Pulldown_9           = 57
        %Pulldown_A           = 65
        %Pulldown_B           = 66
        %Pulldown_C           = 67
        %Pulldown_D           = 68
        %Pulldown_E           = 69
        %Pulldown_F           = 70
        %Pulldown_G           = 71
        %Pulldown_H           = 72
        %Pulldown_I           = 73
        %Pulldown_J           = 74
        %Pulldown_K           = 75
        %Pulldown_L           = 76
        %Pulldown_M           = 77
        %Pulldown_N           = 78
        %Pulldown_O           = 79
        %Pulldown_P           = 80
        %Pulldown_Q           = 81
        %Pulldown_R           = 82
        %Pulldown_S           = 83
        %Pulldown_T           = 84
        %Pulldown_U           = 85
        %Pulldown_V           = 86
        %Pulldown_W           = 87
        %Pulldown_X           = 88
        %Pulldown_Y           = 89
        %Pulldown_Z           = 90
        %Pulldown_PgUp        = 97
        %Pulldown_PgDn        = 98
        %Pulldown_AltEnter    = 99


        'Equates for ConsoleKey and VirtualKey.  These values can also be found
        'in the WIN32API.INC file that is supplied with PB/CC.  Look for the
        'equates that start with %VK_.

        'Items that are marked with [A] below are equivalent to the standard
        'ASCII value of the key, so they can be replaced by a quoted string.
        'For example, CHR$(%Virtual_SPACE) could be replaced by " " or SPACE$(1)
        'OR CHR$(32) when used with ConsoleKey or VirtualKey.

        'Items that are marked with [P] are DIFFERENT from the corresponding
        'equates in the %Pulldown_ section.  You must be careful to use the
        'appropriate value (%Virtual_ vs. %Pulldown_) when working with these
        'keys.  For example, %Pulldown_F1 does not have the same numeric
        'value as %Virtual_F1.

        %Virtual_SHIFT        = &H10
        %Virtual_CTRL         = &H11     'called %VK_CONTROL by Windows
        %Virtual_ALT          = &H12     'called %VK_MENU by Windows

        %Virtual_BACK         = &H8      '[A]
        %Virtual_CANCEL       = &H3      '[A]
        %Virtual_CAPITAL      = &H14
        %Virtual_CLEAR        = &HC
        %Virtual_DELETE       = &H2E
        %Virtual_DOWN         = &H28
        %Virtual_END          = &H23
        %Virtual_ESCAPE       = &H1B     '[A]
        %Virtual_EXECUTE      = &H2B
        %Virtual_HELP         = &H2F
        %Virtual_HOME         = &H24
        %Virtual_INSERT       = &H2D
        %Virtual_LBUTTON      = &H1
        %Virtual_LEFT         = &H25
        %Virtual_MBUTTON      = &H4
        %Virtual_NEXT         = &H22
        %Virtual_PAUSE        = &H13
        %Virtual_PGDN         = &H22
        %Virtual_PGUP         = &H21
        %Virtual_PRINT        = &H2A
        %Virtual_PRIOR        = &H21
        %Virtual_RBUTTON      = &H2
        %Virtual_RETURN       = &HD      '[A]
        %Virtual_RIGHT        = &H27
        %Virtual_SELECT       = &H29
        %Virtual_SNAPSHOT     = &H2C
        %Virtual_SPACE        = &H20     '[A]
        %Virtual_TAB          = &H9      '[A]
        %Virtual_UP           = &H26

        'VIRTUAL_A through VIRTUAL_Z are equal to their ASCII equivalents: 'A' thru 'Z' [A]
        'VIRTUAL_0 through VIRTUAL_9 are equal to their ASCII equivalents: '0' thru '9' [A]

        %Virtual_NUMPAD0      = &H60
        %Virtual_NUMPAD1      = &H61
        %Virtual_NUMPAD2      = &H62
        %Virtual_NUMPAD3      = &H63
        %Virtual_NUMPAD4      = &H64
        %Virtual_NUMPAD5      = &H65
        %Virtual_NUMPAD6      = &H66
        %Virtual_NUMPAD7      = &H67
        %Virtual_NUMPAD8      = &H68
        %Virtual_NUMPAD9      = &H69
        %Virtual_MULTIPLY     = &H6A
        %Virtual_ADD          = &H6B
        %Virtual_SEPARATOR    = &H6C
        %Virtual_SUBTRACT     = &H6D
        %Virtual_DECIMAL      = &H6E
        %Virtual_DIVIDE       = &H6F
        %Virtual_F1           = &H70     '[P]
        %Virtual_F2           = &H71     '[P]
        %Virtual_F3           = &H72     '[P]
        %Virtual_F4           = &H73     '[P]
        %Virtual_F5           = &H74     '[P]
        %Virtual_F6           = &H75     '[P]
        %Virtual_F7           = &H76     '[P]
        %Virtual_F8           = &H77     '[P]
        %Virtual_F9           = &H78     '[P]
        %Virtual_F10          = &H79     '[P]
        %Virtual_F11          = &H7A     '[P]
        %Virtual_F12          = &H7B     '[P]
        %Virtual_F13          = &H7C
        %Virtual_F14          = &H7D
        %Virtual_F15          = &H7E
        %Virtual_F16          = &H7F
        %Virtual_F17          = &H80
        %Virtual_F18          = &H81
        %Virtual_F19          = &H82
        %Virtual_F20          = &H83
        %Virtual_F21          = &H84
        %Virtual_F22          = &H85
        %Virtual_F23          = &H86
        %Virtual_F24          = &H87

        %Virtual_NUMLOCK      = &H90
        %Virtual_SCROLL       = &H91

        '------------------------- ERROR CODES -------------------------

        'If it seems like these are unusually large numbers, please read
        'the chapter titled "Console Tools Error Codes" in the Help File.

        %SUCCESS                        = 0          'ZERO ERRORS

        %ERROR_CT_FIRSTERROR            = 999000000&
        %ERROR_CT_DLL_NOT_AUTHORIZED    = 999000000&
        %ERROR_DLL_NOT_AUTHORIZED       = 999000000&

        %ERROR_CT_INVALIDPARAMETER      = 999000001&
        %ERROR_CT_CANTBEDONE            = 999000002&

        %ERROR_CT_INVALIDMENUNUMBER     = 999000010&
        %ERROR_CT_INVALIDSCREENNUMBER   = 999000011&

        %ERROR_CT_FILENOTFOUND          = 999000020&
        %ERROR_CT_INVALIDFILEFORMAT     = 999000021&

        %ERROR_CT_INVALIDMENUSYSTEM     = 999000040&
        %ERROR_CT_MENUDOESNOTEXIST      = 999000041&

        %ERROR_CT_FONTINUSE             = 999000090&

        %ERROR_CT_FEATURENOTAVAILABLE   = 999000099&

        %ERROR_CT_NOCONSOLE             = 999000999&

        'ERROR RANGES (999 each)...
        %ERROR_CT_FIRSTPBERROR          = 999001000&
        %ERROR_CT_INVALIDITEM           = 999002000&
        %ERROR_CT_INVALIDSUBMENU        = 999003000&
        %ERROR_CT_SELFREFERENCE         = 999004000&
        %ERROR_CT_INVALIDITEMNUMBER     = 999005000&

        %ERROR_CT_UNKNOWNERROR          = 999999999&
        %ERROR_CT_LASTERROR             = 999999999&

        $IF NOT %DEF(%FALSE)
                %FALSE = 0
        $ENDIF

        $IF NOT %DEF(%TRUE)
                %TRUE  = -1
        $ENDIF

'=========================================================================== end of CT_STD.INC
