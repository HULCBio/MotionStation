function rtwoptions = c6000_getRtwOptions(rtwoptions)
% Add C6000-specific RTW Options.
% This is called from the RTW_OPTIONS section of the 
% system target file.
%
% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/02/06 00:29:55 $

rtwoptions(end+1).prompt      = 'TI C6000 target selection';
rtwoptions(end).type          = 'Category';
rtwoptions(end).enable        = 'on';
rtwoptions(end).default       = 7; % Number of items in category (max of 7)

rtwoptions(end+1).prompt      = 'Code generation target type';
rtwoptions(end).type          = 'Popup';
rtwoptions(end).default       = 'C6416DSK';
rtwoptions(end).popupstrings  = ['C6416DSK|C6701EVM|C6711DSK|C6713DSK' ...
    '|Custom_C6416|Custom_C6701|Custom_C6711|Custom_C6713'];
rtwoptions(end).enable        = 'on';
rtwoptions(end).tlcvariable   = 'BoardType';
rtwoptions(end).makevariable  = 'TARGET_TYPE';
rtwoptions(end).tooltip       = 'Indicate the type of board you wish to generate code for.';
rtwoptions(end).callback      = 'c6000_callback(''callback'', hSrc, hDlg, currentVar)';

rtwoptions(end+1).prompt      = 'Enable High-Speed RTDX';
rtwoptions(end).type          = 'Checkbox';
rtwoptions(end).default       = 'off';
rtwoptions(end).enable        = 'on';
rtwoptions(end).tlcvariable   = 'useHSRTDX';
rtwoptions(end).makevariable  = 'USE_HSRTDX';
rtwoptions(end).tooltip       = 'Indicate whether High-Speed RTDX should be linked into the project instead of the standard RTDX library. Requires DSK and XDS560 Emulator.';

rtwoptions(end+1).prompt      = 'Export CCS handle to MATLAB base workspace';
rtwoptions(end).type          = 'Checkbox';
rtwoptions(end).default       = 'on';
rtwoptions(end).tlcvariable   = 'exportCCSObj';
rtwoptions(end).makevariable  = 'EXPORT_OBJ';
rtwoptions(end).callback      = 'c6000_callback(''callback'', hSrc, hDlg, currentVar)';
rtwoptions(end).tooltip       = ['Place a copy of the "MATLAB Link to Code Composer Studio(R)" handle into the base workspace.'];

rtwoptions(end+1).prompt     = 'CCS handle name';
rtwoptions(end).type         = 'Edit';
rtwoptions(end).default      = 'CCS_Obj';
rtwoptions(end).tlcvariable  = 'ccsObjName';
rtwoptions(end).makevariable = 'CCS_OBJ';
rtwoptions(end).enable       = 'on';
rtwoptions(end).tooltip      = ['Specify CCS handle name'];

rtwoptions(end+1).prompt      = 'TI C6000 code generation';
rtwoptions(end).type          = 'Category';
rtwoptions(end).enable        = 'on';
rtwoptions(end).default       = 4;   % Number of items in category (max of 7)

rtwoptions(end+1).prompt      = 'Incorporate DSP/BIOS';
rtwoptions(end).type          = 'Checkbox';
rtwoptions(end).default       = 'on';
rtwoptions(end).tlcvariable   = 'useDSPBIOS';
rtwoptions(end).makevariable  = 'USE_DSPBIOS';
rtwoptions(end).callback      = 'c6000_callback(''callback'', hSrc, hDlg, currentVar)';
rtwoptions(end).tooltip       = ['Use DSP/BIOS when creating the Code Composer Studio project.'];

rtwoptions(end+1).prompt      = 'Profile performance at atomic subsystem boundaries';
rtwoptions(end).type          = 'Checkbox';
rtwoptions(end).default       = 'off';
rtwoptions(end).tlcvariable   = 'ProfileGenCode';
rtwoptions(end).makevariable  = 'PROFILE_GEN_CODE';
rtwoptions(end).tooltip       = ['Generate profiling instrumentation for atomic subsystems. DSP/BIOS only.'];

rtwoptions(end+1).prompt      = 'Inline Signal Processing Blockset functions';
rtwoptions(end).type          = 'Checkbox';
rtwoptions(end).default       = 'on';
rtwoptions(end).tlcvariable   = 'InlineDSPBlks';
rtwoptions(end).makevariable  = 'INLINE_DSPBLKS';
rtwoptions(end).tooltip       = ['For Signal Processing Blockset algorithms, mark runtime library functions with the "inline" keyword rather than creating true function calls.'];

rtwoptions(end+1).prompt      = 'Use target specific optimization for speed (allow LSB differences)';
rtwoptions(end).type          = 'Checkbox';
rtwoptions(end).default       = 'off';
rtwoptions(end).tlcvariable   = 'FPopt';
rtwoptions(end).makevariable  = 'FP_OPT';
rtwoptions(end).tooltip       = ['(Only applicable in Little Endian mode)  If enabled, several fixed-point blocks ',...
    sprintf('\n'), 'may exhibit LSB differences in exchange for improved execution speed.'];

rtwoptions(end+1).prompt      = 'TI C6000 compiler';
rtwoptions(end).type          = 'Category';
rtwoptions(end).enable        = 'on';
rtwoptions(end).default       = 5;  % Number of items in category (max of 7)

rtwoptions(end+1).prompt      = 'Optimization level';
rtwoptions(end).type          = 'Popup';
rtwoptions(end).default       = 'Function(-o2)';
rtwoptions(end).tlcvariable   = 'optLevel';
rtwoptions(end).popupstrings  = 'None|Register(-o0)|Local(-o1)|Function(-o2)|File(-o3)';
rtwoptions(end).makevariable  = 'OPT_LEVEL';
rtwoptions(end).tooltip       = ['Select compiler optimization level according to cl6x -o flag.'];

%%% Obsolete option: replaced by option under "Hardware Implementation".
%%% Automatically propagated via ActivateCallback.
% rtwoptions(end+1).prompt      = 'Byte order';
% rtwoptions(end).type          = 'Popup';
% rtwoptions(end).default       = 'Little_endian';
% rtwoptions(end).tlcvariable   = 'Endianness';
% rtwoptions(end).popupstrings  = 'Little_endian|Big_endian';
% rtwoptions(end).makevariable  = 'ENDIAN';
% rtwoptions(end).tooltip       = ['Select desired byte order'];
 
rtwoptions(end+1).prompt      = 'Compiler verbosity';
rtwoptions(end).type          = 'Popup';
rtwoptions(end).default       = 'Quiet';
rtwoptions(end).tlcvariable   = 'CompilerVerbosity';
rtwoptions(end).makevariable  = 'BANNERS';
rtwoptions(end).popupstrings  = 'Verbose|Quiet|Super_quiet';
rtwoptions(end).tooltip       = ['Select the verbosity level of the compiler'];

rtwoptions(end+1).prompt      = 'Symbolic debugging';
rtwoptions(end).type          = 'Checkbox';
rtwoptions(end).default       = 'off';
rtwoptions(end).tlcvariable   = 'SymbolicDebugOnC6x';
rtwoptions(end).makevariable  = 'SYMBOLIC_DEBUG';
rtwoptions(end).tooltip       = ['Compile with symbolic debug information'];

rtwoptions(end+1).prompt      = 'Retain .asm files';
rtwoptions(end).type          = 'Checkbox';
rtwoptions(end).default       = 'off';
rtwoptions(end).tlcvariable   = 'RetainAsmFiles';
rtwoptions(end).makevariable  = 'RETAIN_ASM';
rtwoptions(end).tooltip       = ['Keep .asm files generated by compiler'];

rtwoptions(end+1).prompt      = 'TI C6000 linker';
rtwoptions(end).type          = 'Category';
rtwoptions(end).enable        = 'on';
rtwoptions(end).default       = 4; % Number of items in category (max of 7)

rtwoptions(end+1).prompt      = 'Retain .obj files';
rtwoptions(end).type          = 'Checkbox';
rtwoptions(end).default       = 'on';
rtwoptions(end).tlcvariable   = 'RetainObjFiles';
rtwoptions(end).makevariable  = 'RETAIN_OBJ';
rtwoptions(end).tooltip       = ['Keep .obj files generated by compiler'];

rtwoptions(end+1).prompt      = 'Create .map file';
rtwoptions(end).type          = 'Checkbox';
rtwoptions(end).default       = 'on';
rtwoptions(end).enable        = 'on';
rtwoptions(end).tlcvariable   = 'CreateMapFile';
rtwoptions(end).makevariable  = 'CREATE_MAP';
rtwoptions(end).tooltip       = ['Instruct linker to generate .map file'];

rtwoptions(end+1).prompt      = 'Linker command file';
rtwoptions(end).type          = 'Popup';
rtwoptions(end).default       = 'Full_memory_map';
rtwoptions(end).tlcvariable   = 'LinkerCommandFile';
rtwoptions(end).makevariable  = 'LINKER_CMD';
rtwoptions(end).popupstrings  = ['User_defined|',...
    'Full_memory_map|',...
    'Internal_memory_map'];
rtwoptions(end).callback      = 'c6000_callback(''callback'', hSrc, hDlg, currentVar)';
rtwoptions(end).tooltip       = ['Choose a linker command file'];

rtwoptions(end+1).prompt     = 'User linker command file';
rtwoptions(end).type         = 'Edit';
rtwoptions(end).default      = 'my_file.cmd';
rtwoptions(end).tlcvariable  = 'UserLinkerCommandFile';
rtwoptions(end).makevariable = 'USER_LINKER_CMD';
rtwoptions(end).enable       = 'on';
rtwoptions(end).tooltip      = ['Type path and filename of your own',...
    sprintf('\n'),'linker command file'];

rtwoptions(end+1).prompt      = 'TI C6000 runtime';
rtwoptions(end).type          = 'Category';
rtwoptions(end).enable        = 'on';
rtwoptions(end).default       = 4; % Number of items in category (max of 7)

rtwoptions(end+1).prompt     = 'Build action';
rtwoptions(end).type         = 'Popup';
rtwoptions(end).default      = 'Build_and_execute';
rtwoptions(end).tlcvariable  = 'c6000BuildAction';
rtwoptions(end).makevariable = 'BUILD_ACTION';
rtwoptions(end).popupstrings = ['Generate_code_only|',...
    'Create_CCS_Project|',...
    'Build|',...
    'Build_and_execute'];
rtwoptions(end).callback      = 'c6000_callback(''callback'', hSrc, hDlg, currentVar)';
rtwoptions(end).tooltip      = ['Select action to be performed after code generation'];

rtwoptions(end+1).prompt     = 'Current C6701EVM CPU clock rate';
rtwoptions(end).type         = 'Popup';
rtwoptions(end).default      = '100MHz';
rtwoptions(end).tlcvariable  = 'c6701evmCpuClockRate';
rtwoptions(end).makevariable = 'C6701_EVM_CPU_CLOCK_RATE';
rtwoptions(end).popupstrings = '25MHz|33.25MHz|100MHz|133MHz';
rtwoptions(end).tooltip      = ['Specify the clock rate your C6701EVM is configured for. ' sprintf('\n') ...
    'This information is required for code generation. The '  sprintf('\n') ...
    'default rate is 100 MHz, but you can change this value ' sprintf('\n') ...
    'via DOS utilities and/or DIP switches. If you are using ' sprintf('\n') ...
    'a DSK, the clock speed is fixed, and this ' sprintf('\n') ...
    'option does not apply. '];

rtwoptions(end+1).prompt     = 'Overrun action';
rtwoptions(end).type         = 'Popup';
rtwoptions(end).default      = 'Notify_and_halt';
rtwoptions(end).tlcvariable  = 'OverrunAction';
rtwoptions(end).makevariable = 'OVERRUN_ACTION';
rtwoptions(end).popupstrings = 'None|Notify_and_continue|Notify_and_halt';
rtwoptions(end).callback      = 'c6000_callback(''callback'', hSrc, hDlg, currentVar)';
rtwoptions(end).tooltip      = ['Select action to perform when an interrupt overrun condition is detected.'];

rtwoptions(end+1).prompt     = 'Overrun notification method';
rtwoptions(end).type         = 'Popup';
rtwoptions(end).default      = 'Turn_on_LEDs';
rtwoptions(end).tlcvariable  = 'OverrunNotificationMethod';
rtwoptions(end).makevariable = 'OVERRUN_NOTIFICATION_METHOD';
rtwoptions(end).popupstrings = 'Print_message|Turn_on_LEDs|Print_message_and_turn_on_LEDs';
rtwoptions(end).tooltip      = ['Select notification method. If Print_message is selected,' sprintf('\n') ...
    'the message is printed in Stdout window or in Message Log' sprintf('\n') ...
    'if DSP/BIOS is used.'];

% EOF c6000_getRtwOptions.m
