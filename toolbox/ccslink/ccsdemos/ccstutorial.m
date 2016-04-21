% CCSTUTORIAL Link for CCS® tutorial.
%   CCSTUTORIAL is an example script intended to get the user started with
%   the Link for Code Composer Studio®.
%
%   A simple target DSP application is loaded and run on the target DSP.
%   CCS IDE and debug operations such as setting/deleting breakpoints,
%   reading data from the DSP and writing data to the DSP are demonstrated.
%
%   Methods that are demonstrated include
%   Global Functions:
%     ccsboardinfo, boardprocsel, ccsdsp
%   CCSDSP object methods:
%     run, isrunning, halt, restart, insert, visible, load, build
%     read, write, address, info
%
%   If Data Manipulation is supported on the processor, an additional debug
%   approach is demonstrated.  The demo shows how to create handles to C
%   variables, and how to use these to conveniently access information
%   associated with these variables.
%
%   Methods that are demonstrated include
%   CCSDSP object method:
%     createobj
%   Memory and Register object methods:
%     read        (for numeric, pointer, string, enum, struct data)
%     write       (for numeric, pointer, string, enum, struct data)
%     cast        (for numeric, pointer, string, enum, struct data)
%     deref       (for pointer data)
%     getmember   (for struct data)
%     readnumeric (for enum data)
%
%   To run the CCSTUTORIAL from MATLAB, type 'ccstutorial' at the command
%   prompt.
%
%  See also HILTUTORIAL, RTDXTUTORIAL, CCSFIRDEMO, RTDXLMSDEMO, CCSINSPECT,
%           CCSDSP 

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.34.4.3 $  $Date: 2004/04/01 16:00:39 $

echo off
existingVars = whos;
existingVars = {existingVars.name};
board_variable = 0;

timeoutValue = 100;  % Value (in seconds) to set default CCSDSP and OBJECT timeout 

try
% ========================================================================
% Intro
disp(sprintf(['=================================================================\n'...
        ' The ''Link for Code Composer Studio'' provides a direct\n'...
        '  connection between MATLAB and a DSP in Code Composer.  This\n'...
        '  provides a mechanism for controlling and manipulating an\n'...
        '  embedded application using the full computational power of\n'...
        '  MATLAB. This can be used to assist DSP debugging and development.\n'...
        '  Another possible use is for creation of MATLAB scripts for\n'...
        '  verification and testing of algorithms that exist in their \n'...
        '  final implementation on an actual DSP target.\n\n'...
        ' Before discussing the methods available with the link object,\n'...
        '  it''s necessary to select a DSP target.  When the link\n'...
        '  is created, it is specific to a particular CPU, (i.e. a DSP\n'...
        '  processor) so selection is required before proceeding.\n'...
        '  In general, the selection process is only necessary \n'...
        '  for multiprocessor configurations of Code Composer Studio.\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue ---');
pause;

% ========================================================================
% command line board/processor selection command: ccsboardinfo
disp(sprintf(['=================================================================\n'...
        ' The ''Link for Code Composer Studio'' provides two tools\n'...
        '  for selecting a DSP board and processor in multiprocessor\n'... 
        '  configurations.  First, a command line version called: ''ccsboardinfo'' \n'...
        '  which generates a list of the available boards and processors.\n'...
        '  For scripting, this command can return a structure, which\n'...
        '  can be applied programmatically to select a particular DSP chip.\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue:  ccsboardinfo ---');
pause;
echo on

ccsboardinfo

echo off;

% ========================================================================
% GUI board/processor selection tool: boardprocsel
disp(sprintf(['=================================================================\n'...
        ' Another selection option is a GUI tool called ''boardprocsel''.\n'...
        '  Please Note - the CPU that is selected in the GUI will be used\n'...
        '  for the rest of this tutorial.  For single processor installations,\n'...
        '  of Code Composer Studio, simply select ''OK'' from the message box\n'...
        '  to continue.\n'...
        '=================================================================\n\n']));

disp('---  Press any key to continue, then select a DSP from the GUI (or click OK):  boardprocsel ---');
pause;
echo on

[boardNum,procNum] = boardprocsel
drawnow;

echo off
if isempty(boardNum) || isempty(procNum),
    disp(sprintf(['The board/processor GUI was canceled without selecting a valid device\n'...
            ' Please restart the tutorial and select a valid board and processor\n']));
    error('No board or processor selected to create Link' );
else
    fprintf(1,['\n The goal of this selection process is a board number\n'...
            '  and processor number that uniquely identify a particular\n'...
            '  target DSP.  These values are then applied during the link creation.\n\n'...
            ' You selected board number = %d, and processor number = %d\n\n'],boardNum,procNum);
end
%========================================================================
% Object Constructor: ccsdsp
disp(sprintf(['=================================================================\n'...
        ' Next, the actual connection between the MATLAB command line and Code \n'...
        '  Composer will be established.  This link is represented by a MATLAB\n'...
        '  object, which for this session will be saved in variable ''cc''.  The\n'...
        '  link object is created with the ''ccsdsp'' command, which accepts the\n'...
        '  board  number and processor number as input parameters.  Other\n'...
        '  properties can also be defined during the object creation; refer to\n'...
        '  the ''ccsdsp'' documentation for more information on these properties.\n'...  
        '  The generated ''cc'' object will be used to direct actions to the \n'...
        '  designated DSP chip.  Therefore, it will appear in all commands that\n'...
        '  follow the object creation.  Naturally, in multiprocessor \n'...
        '  implementations it is possible to have more than one link object.\n'...
        ' NOTE: Before proceeding, your DSP hardware should be reset and \n'...
        '  configured as needed for operation by Code Code Composer.\n'...
        '=================================================================\n\n']));

disp('--- Press any key to continue:  ccsdsp ---');
pause;
echo on

cc = ccsdsp('boardnum',boardNum,'procnum',procNum)

timeoutValue
set(cc,'timeout',timeoutValue); % Set CCSDSP default timeout value

echo off
%========================================================================
% Visibility of Code Composer
disp(sprintf(['=================================================================\n'...
        ' You may have noticed Code Composer appear briefly when ''ccsdsp''\n'...
        '  was called.  If Code Composer was not running before the link\n'...
        '  is established, it is started and then placed in the background.\n'...
        '  In most cases, you will need to interact with Code Composer,\n'...
        '  so the first method that will be introduced (called ''visible'')\n'...
        '  controls the state of Code Composer on the desktop. This accepts\n'...
        '  a Boolean input that makes Code Composer visible (1) or \n'...
        '  invisible (0) on the desktop.  For the rest of this tutorial, \n'...
        '  we will need to interact with Code Composer, so we''ll use \n'...
        '  ''visible'' to bring it up to the desktop.\n'...
        '=================================================================\n']));
disp('--- Press any key to continue ---');
pause;
echo on

visible(cc,1)  % Force Code Composer to be visible on the desktop

echo off
%========================================================================
% Link Status: info, isrunning, disp
disp(sprintf(['=================================================================\n'...
        ' With the link in place, it is now possible from MATLAB to\n'...
        '  query Code Composer for status on the specified DSP.\n'...
        '  Four methods are available to get status information:  \n'...
        '  ''info''          - returns a structure of testable Target conditions.\n'...
        '  ''display''       - prints a list of information about the target CPU.\n'...
        '  ''isrunning''     - returns the state (running or halted) of the CPU.\n'...
        '  ''isrtdxcapable'' - reports CPUs ability to perform RTDX(tm) transfers.\n'...
        '  The next segment will demonstrate these methods.\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue:  display ---');
pause;
echo on

display(cc)

echo off
disp('--- Press any key to continue:  info, isrunning ---');
pause;
echo on

linkinfo = info(cc)

cpurunstatus = isrunning(cc)

isrtdxcapable(cc)

echo off

%========================================================================
% Determine family variants (28x or 54x or 55x or 6x11 or 6x0x?)
board = GetDemoProp(cc,'ccstutorial');
board_variable = 1;

if linkinfo.family==470
    proc_name = sprintf('TMS470R%1s%02d MPU',dec2hex(linkinfo.subfamily),linkinfo.revfamily);
else % assume a 'C'
    proc_name = sprintf('TMS%03dC%2s%02d DSP',linkinfo.family,dec2hex(linkinfo.subfamily),linkinfo.revfamily);
end
disp(sprintf(['\nFrom the ''subfamily'' and ''revfamily'' members of the structure\n'...
        ' returned by the ''info'' method, it was determined that you selected\n'...
        ' a %s.\n'...
        'Please note - In some cases, the values reported by Code Composer\n'...
        ' do not match the physical device numbering scheme.\n\n'],proc_name));

%========================================================================
% The Code Composer Files: open

disp(sprintf(['=================================================================\n'...
        ' Now that a connection has been established, the target CPU needs\n'...
        '  something to do!  Therefore, the next step is to create executable \n'...
        '  code for the target DSP with Code Composer. For this tutorial, a\n'...
        '  Code Composer project file and a board specific executable were \n'...
        '  created and included with MATLAB. We will first attempt to load\n'...
        '  the included executable directly, and if the load fails (could be\n'...
        '  because it is a different board or processor), we will build the\n'...
        '  included project. The following set of commands will locate the\n'...
        '  tutorial project and load it into Code Composer.  This will use the\n'...
        '  ''open'' method, which can direct Code Composer to load a project\n'...
        '  file or a program file. \n'...
        '=================================================================\n']));
disp('--- Press any key to continue:  open,cd ---');
pause;
warning off
echo on

projfile = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','ccstutorial',board.ccstut.projname)  

projpath = fileparts(projfile)

open(cc,projfile)     % Open project file

cd(cc,projpath)       % Change working directory of Code Composer(only)

echo off
warning on
%========================================================================
% The Code Composer program file: Load
disp(sprintf(['=================================================================\n'...
        ' You should notice the tutorial''s project loaded in Code Composer.\n'...
        '  Examine the files in Code Composer that comprise this project -\n'...  
        '  the main source file used by this tutorial is ''ccstut.c'', a linker\n'... 
        '  command file (*.cmd) and vector table source file (*.asm), which\n'...
        '  will be different, depending on the DSP family you are using. \n'...
        '  Before building this project, we will attempt to load the included\n'...
        '  executable. This will use the ''load'' method, which should only\n'...
        '  be used for program files.\n'...
        '  The ''Link for Code Composer Studio'' includes methods for reading\n'...
        '  the target''s symbol table to give direct access to data in the DSP memory.\n'...
        '  NOTE: The symbol table is only available after the program file is built\n'...
        '  and then loaded into the DSP. Notice the results of checking the symbol table\n'...
        '  for the variable ''ddat'' before and after the load.\n'...
        '=================================================================\n']));
disp('--- Press any key to continue:  load,address,dec2hex ---');
pause;
try
    
echo on

% Before loading target execution file:
warnState = warning('on');   % Enable warnings to demonstrate the next command

address(cc,'ddat')  % Note - This may (correctly) issue a warning before the executable file is loaded.

warning(warnState);  % Reinstate warning state

% Load the target execution file
load(cc,board.ccstut.loadfile,30)    

% After loading target execution file:
ddatA = address(cc,'ddat')   % Now it should find the address of global value: ddat
dec2hex(ddatA)     % in hexadecimal (address and page)

echo off    
catch 
echo off    
    warning(warnState);
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
    disp(lasterr);
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
    disp(sprintf(['\n',...
        '!!!!! A problem  is encountered while loading ''%s'' on the target.\n',...
        'This might happen if the target that the program file was created for is \n',...
        'different than the one you are using. \n\n'...
        'We will now attempt to rebuild the program and then load it before proceeding. \n',...
        'This is done with the ''build'' and ''load'' methods. The time to build a project \n',...
        'varies depending on your configuration. Therefore, an explicit 1500 second timeout \n'...
        'is supplied with the ''build'' method. \n'],board.ccstut.loadfile));
    
disp('--- Press any key to continue:  build,load---');
pause;
% Setting the right build options 
setbuildopt(cc,'Compiler',board.ccstut.Cbuildopt);
% Directing output program file to a temporary directory on your system
setbuildopt(cc,'Linker', ['-c -o "' tempdir board.ccstut.loadfile '" -x']);
disp('Please wait for the ''build'' operation to complete');
echo on

build(cc,'all',1500);

echo off
sprintf('\n');
disp('--- Press any key to continue:  load ---');
pause
sprintf('\n');
try 
echo on

% Attempt to load the program file from the temporary directory
load(cc,[tempdir board.ccstut.loadfile],40);
ddatA = address(cc,'ddat')  % Read the address of global: ddat
dec2hex(ddatA)     % in hexadecimal (address and page)

echo off    

catch
echo off    
    disp('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    disp(lasterr);
    disp('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    disp(sprintf(['\n',...
            '!!!!! Another problem is encountered while building/loading ''%s'' \n',...
            'on the target.\n\n',...
            'It could be that the target you are using needs a different linker command \n',...
            'file (*.cmd) and vector table source file (*.asm). \n\n',...
            'Please attempt to rebuild the program file with the appropriate files \n',...
            'and the manually load it from Code Composer Studio.\n'],board.ccstut.loadfile));
    contFlag = 'dummy';
    while ~isempty(contFlag) && ~strcmpi(contFlag,'exit')
        contFlag = input('After loading, hit <enter> to proceed with the demo or type ''exit'' to exit the demo: ','s');
    end
    if ~isempty(contFlag),
        % Clear all variables created by the tutorial
        visible(cc,0);
		ccstutorialVars1 = whos;
		ccstutorialVars1 = setdiff({ccstutorialVars1.name},existingVars);
        len1 = length(ccstutorialVars1);
        for varid1=1:len1
            clear (ccstutorialVars1{varid1});
        end
        clear ccstutorialVars1 len1 varid1
		disp(sprintf('\nExiting CCSTUTORIAL demo...'))
        return
    end
            
echo on

% Assume that the target execution file has been loaded by the user
ddatA = address(cc,'ddat')  % Read the address of global: ddat
dec2hex(ddatA)     % in hexadecimal (address and page)

echo off    
end
end

% Insert Breakpoint
disp(sprintf(['=================================================================\n'...
        ' After the target code loaded, it is possible to examine and modify \n'...
        '  data values in the DSP target from MATLAB.\n'...
        '  For static data values, it is possible to read them immediately after\n'...
        '  loading a program file.  However, the more interesting case is to \n'...
        '  manipulate data values at intermediate points during program execution.\n'...
        '  To facilitate this operation, there are methods to insert (and delete) \n'...
        '  breakpoints in the DSP program.  The method ''insert'' creates a new \n'...
        '  breakpoint, which can be specified by either a source file location or\n'...
        '  a physical memory address.\n'...
        '  For this tutorial, we need to insert a breakpoint at line 64 of the \n'...
        '  ''ccstut.c'' source file.\n'...
        '  To assist your visibility of this action, the method ''open'' is used to\n'...
        '  display the source file in Code Composer.  Furthermore, the ''activate'' \n'...
        '  method will force this file to the front.\n'...
        '  (Although it is not demonstrated here, ''delete'' can be used to remove \n'...
        '  a breakpoint.)\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue:  activate, insert and open ---');
pause;
echo on

cd(cc,projpath);   % Restore back working directory for Code Composer
brkpt = 64;

echo off
if strcmp(board.name,'c24x') && isC2401(linkinfo)
echo on

open(cc,'ccstut_2401.c','text')      % Be sure this file is open for viewing in CCS
activate(cc,'ccstut_2401.c','text')  % Bring the source file forward
insert(cc,'ccstut_2401.c',brkpt)    % Insert breakpoint at line 64

echo off
elseif strcmp(board.name,'c28x') || strcmp(board.name,'c27x') || strcmp(board.name,'c24x') 
echo on

open(cc,'ccstut_2xx.c','text')     % Be sure this file is open for viewing in CCS
activate(cc,'ccstut_2xx.c','text') % Bring the source file forward
insert(cc,'ccstut_2xx.c',brkpt)    % Insert breakpoint at line 64

echo off
else
echo on

open(cc,'ccstut.c','text')     % Be sure this file is open for viewing in CCS
activate(cc,'ccstut.c','text') % Bring the source file forward
insert(cc,'ccstut.c',brkpt)    % Insert breakpoint at line 64

echo off
end

%========================================================================
% Halt, run, read
disp(sprintf(['=================================================================\n'...
        ' Examine the source file ''ccstut.c'' in the Code Composer Studio \n'...
        '  source editor area.  There should be a breakpoint on line 64\n'...
        '  (indicated by a red dot).  Next, locate the two global data\n'.... 
        '  arrays: ''ddat'' and ''idat'', which are located at lines 44\n'...
        '  and 45 in this file. \n'...
        '  These DSP memory arrays can be accessed directly from\n'...
        '  MATLAB command line using the ''read'' and ''write'' methods.\n'...
        '  To control target execution, use the ''run'',''halt'' and ''restart'' \n'...
        '  methods.  The following section will demonstrate these methods.\n'...
        ' Note: This approach to access DSP memory is powerful but rudimentary. \n'...
        '  Later in the tutorial, we''ll introduce an easier method based on\n'...
        '  C variables (supports C6x, C54x, C55x, R2x, R1x, OMAP ). \n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue:  halt,restart,read ---');
pause;
try
if ~isempty(strmatch(board.name,{'c28x','c27x','c24x','c54x','c55x'}))
echo on

halt(cc)                    % halt the CPU (if necessary)

echo off

% reset bug on the C54x simulator
if ~(strcmp(board.name,'c54x') && any((findstr(linkinfo.boardname,'Simulator'))))
echo on

reset(cc);               % reset the CPU (if necessary)

echo off
end

echo off
pause(1)
echo on

restart(cc)                 % reset the PC to start of program

run(cc,'runtohalt',30);     % wait for program execution to stop at breakpoint! (timeout = 20 seconds)
      
ddatV = read(cc,address(cc,'ddat'),'single',4)   % Should equal initialized value from C-Code
idatV = read(cc,address(cc,'idat'),'int16',4)

echo off
disp('--- Compare Data: idat, ddat with Code Composer, then press return ---');
pause;
echo on

write(cc,address(cc,'ddat'),single([pi 12.3 exp(-1) sin(pi/4)]))   % Modify memory values
write(cc,address(cc,'idat'),int16([1:4]))

run(cc,'runtohalt',20);     % Resume execution from breakpoint, then modify 
  
ddatV = read(cc,address(cc,'ddat'),'single',4)
idatV = read(cc,address(cc,'idat'),'int16',4)
        
restart(cc);

echo off
else % C6xx,Rxx Family
echo on

halt(cc)                    % halt the CPU (if necessary)
restart(cc)                 % reset the PC to start of program
run(cc,'runtohalt',20);     % wait for program execution to stop at breakpoint! (timeout = 20 seconds)
        
ddatV = read(cc,address(cc,'ddat'),'double',4)   % Should equal initialized value from C-Code
idatV = read(cc,address(cc,'idat'),'int16',4)

echo off
disp('--- Compare Data: idat, ddat with Code Composer, then press return ---');
pause;
echo on       

write(cc,address(cc,'ddat'),double([pi 12.3 exp(-1) sin(pi/4)]))   % Modify memory values
write(cc,address(cc,'idat'),int16([1:4]))
        
run(cc,'runtohalt',20); % Resume execution from breakpoint, then modify
        
ddatV = read(cc,address(cc,'ddat'),'double',4)
idatV = read(cc,address(cc,'idat'),'int16',4)
        
restart(cc);

echo off
end
catch
echo off
disp(lasterr);
    disp(sprintf(['!!!! The program execution failed - Generally this is because the\n'....
            'breakpoint was not included in the source file.  This caused the\n'...
            'CPU to continue execution without halting.  Try re-running the\n'...
            'tutorial and be sure to insert the breakpoint when it is requested.\n'...
            'In some cases, resetting the board before running the tutorial may be\n'...
            'necessary.  It is often helpful to verify the Target code in Code\n'...
            'Composer before executing the tutorial.\n']));
    error('CCSTUTORIAL failure');
end

%========================================================================
% regread/regwrite
disp(sprintf(['=================================================================\n'...
        ' For Assembly language programmers, there are also methods\n'...
        ' to access CPU registers: ''regread'' and ''regwrite''.\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue: regread,regwrite ---');
pause;
if ~isempty(strmatch(board.name,{'c28x','c54x','c55x'}))
echo on

tReg = regread(cc,'AL','2scomp')    % 2's complement version of AL
regread(cc,'PC','binary')           % Unsigned version of the PC register
regwrite(cc,'AH','FFFF','binary')   
regread(cc,'AH','binary')           % verify the value previously written

echo off
elseif ~isempty(strmatch(board.name,{'c24x','c27x'}))
echo on

tReg = regread(cc,'AR0','2scomp')   % 2's complement version of AL
regread(cc,'PC','binary')           % unsigned version of the PC register.
regwrite(cc,'AR2','FFFF','binary')
regread(cc,'AR2','binary')          % verify the value previously written

echo off

elseif ~isempty(strmatch(board.name,{'r2x','r1x'}))
echo on

tReg = regread(cc,'R0','2scomp')    % 2's complement version of R0
regread(cc,'PC','binary')           % unsigned version of PC
regwrite(cc,'R2',tReg,'2scomp')
regread(cc,'R2','2scomp')           % verify the value previously written

echo off   
else
echo on

tReg = regread(cc,'A0','2scomp')    % 2's complement version of A0
regread(cc,'B2','binary')           % unsigned version of B2
regwrite(cc,'A2',tReg,'2scomp')
regread(cc,'A2','2scomp')           % verify the value previously written

echo off
end

if ~isempty(strmatch(board.name,{'c54x','c64x','c67x','r1x','r2x','c55x','c28x'})) % HIL support
    %========================================================================
    % List, Goto
    
    disp(sprintf(['=================================================================\n'...
            ' Direct access to DSP memory is powerful, but for C programmers it is \n'...
            '  more convenient to manipulate memory in ways consistent with the\n'...
            '  defined C variables.  This type of access is implemented using MATLAB\n'...
            '  objects as representations of embedded entities. \n'...
            '  First, let''s take a look at the same data values that we explored \n'...
            '  above but now we''ll manipulate them using objects. First, we''ll restart\n'...
            '  the program and apply the ''list'' method, which queries Code Composer\n'...
            '  for information, on ''idat'', i.e. the global C variable of interest.\n'...
            '=================================================================\n\n']));
    disp('--- Press any key to continue: list, goto, run ---');
    pause;
    echo on
    
restart(cc)   % Restart program
goto(cc,'main') % Open file where 'main' is found and set the CCS cursor to the start of 'main'
run(cc,'main')  % Run to start of 'main' - ensured Embedded C variables get initialized
listI = list(cc,'variable','idat')  % Returns structure of information about global variable: 'idat'
listI.idat

echo off
disp('--- Press any key to continue ---');
    
%========================================================================
% Createobj, Read, Write
disp(sprintf(['=================================================================\n'...
        ' ''List'' generates lots of information about the embedded ''idat'' variable.\n'...
        '  However, an even more useful method is ''createobj'', which generates \n'...
        '  a MATLAB object to represent the C variable.  This object acquires the \n'...
        '  properties of the C variable.  Applying the object returned by ''createobj'',\n'...
        '  you can directly read the entire variable or access individual elements of \n',...
        '  an array.\n'...
        '  Note: Up to this point all methods were applied to the original ''cc'' object\n'...
        '  that was created with ''ccsdsp''.  The ''cc'' object represents communication \n'...
        '  with a particular embedded processor in Code Composer Studio.\n'...
        '  However, for the remainder of this tutorial, methods are applied to many \n'...
        '  different objects.  In typical object-oriented fashion, the action\n'...
        '  performed by a method will depend on it''s object.  The relevant object\n'...
        '  is always the first parameter passed to the method. For example, in the\n'...
        '  following section, ''cvar'' is an object representing the embedded \n'...
        '  ''idat''  variable.\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue: createobj, read, write ---');
pause;
echo on

cvar = createobj(cc,'idat')  % Creates a MATLAB object 'cvar' to manipulate embedded 'idat'
read(cvar)  % Reads the entire embedded array into the MATLAB workspace

read(cvar,2)  % Reads only the second element

write(cvar,4,7001)  % Modifies the fourth element to 7001

read(cvar)  % See changes

read(cvar,[1 cvar.size])  % Read only first and last elements

echo off
    
    %========================================================================
    % Cast, Convert, Size
    disp(sprintf(['=================================================================\n'...
            ' The previous ''read'' takes the raw memory values and converts them\n'...
            '  into equivalent MATLAB numeric values.  The conversion that gets \n'...
            '  applied is controlled by the properties of the object, which were\n'...
            '  initially configured in ''createobj'' to settings appropriate for \n'...
            '  your DSP architecture and C representation.  In some cases, it is\n'...
            '  useful to alter these default conversion properties.  Several\n'...
            '  properties such as ''endianness'', ''arrayorder'' and ''size'' can\n'...
            '  be directly modified using ''set''.  More complex changes are possible\n'...
            '  using methods such as ''convert'' and ''cast'', which adjust multiple \n'...
            '  properties simultaneously.\n'...
            '=================================================================\n\n']));
    disp('--- Press any key to continue: cast, convert, size ---');
    
pause;
echo on

set(cvar,'size',[2])   % Reduce size of 'idat' to first 2 elements

read(cvar)

uicvar = cast(cvar,'unsigned short')   % Creates new object with specified data type (but otherwise identical)

read(uicvar)   % Note - first value is no longer -1, but unsigned equivalent

convert(cvar,'unsigned short')  % Same as Cast, but alters properties of existing class 

read(cvar)    % Remember - the size of cvar was set to 2!

echo off
    
    %========================================================================
    % getmember
    
    disp(sprintf(['=================================================================\n'...
            ' DSP variables such as strings, structures, bitfields, enumerated types\n'...
            '  and pointers can be manipulated just as easily.   The following \n'...
            '  demonstrates some common manipulations on structures, strings\n'...
            '  and enumerated types.  In particular, note the ''getmember'' method,\n'...
            '  which extracts a single field from a structure as a new MATLAB\n'...
            '  object. \n'...
            '=================================================================\n\n']));
disp('--- Press any key to continue: getmember ---');
pause;
echo on

cvar = createobj(cc,'myStruct')   % Object that represents an embedded C structure
read(cvar)

write(cvar,'iz', 'Simulink')   % Modify 'iz' field using actual enumerated name 

cfield = getmember(cvar,'iz')  % Extract object from structure
write(cfield,4)   % Write to same enumerated variable by value

read(cvar)

echo off
disp('--- Press any key to continue ---');
pause;
echo on

cstring = createobj(cc,'myString')   % Object that represents an embedded C structure
read(cstring)

write(cstring,7,'ME')

read(cstring)

write(cstring,1,127)  % Set first location to numeric value 127 (a non-printable ASCII character)

readnumeric(cstring)  % Read equivalent numeric values

echo off
disp(sprintf([...
    '=================================================================\n'...
    ' To learn more about data manipulation and function calls, namely \n'...
    '  the hardware-in-the-loop feature, please run ''HILTUTORIAL''.\n'...
    '=================================================================\n\n']));
disp('--- Press any key to continue ---');
pause;
end
%========================================================================
% Deleting the link: clear
disp(sprintf(['\n',...
    '=================================================================\n'...
    ' Finally, the objects created during this tutorial have COM handles\n'...
    '  to Code Composer Studio.  Until these handles are deleted, the\n'...
    '  Code Composer Studio process will remain in memory.  Exiting\n'...
    '  MATLAB will automatically remove these handles, but in some\n'...
    '  cases it might be useful to manually delete them.  Use ''clear''\n'...
    '  to remove objects from the MATLAB workspace and delete any handles\n'...
    '  they contain.  ''Clear all'' will delete everything.\n'...
    '  Alternatively, to retain your MATLAB data use ''clear'' on the\n'...
    '  objects derived from ''ccsdsp'' (including all objects returned\n'...
    '  by ''createobj''). \n'...
    '  In addition, ''close'' is performed on the tutorial project to remove\n'...
    '  it from Code Composer.\n'...
    '=================================================================\n\n']));
disp('--- Press any key to continue:  close, clear ---');
pause;
warning off
echo on

% Clean-up Code Composer
close(cc,projfile,'project')   % close the project file
visible(cc,0);
echo off
% Delete breakpoint introduced earlier
if strcmp(board.name,'c24x') && isC2401(linkinfo)
echo on
% Delete breakpoint introduced earlier
delete(cc,'ccstut_2401.c',brkpt)  % Remove breakpoint at line 64
close(cc,'ccstut_2401.c','text')  % Close source file
echo off
elseif strcmp(board.name,'c28x') || strcmp(board.name,'c27x') || strcmp(board.name,'c24x')
echo on
% Delete breakpoint introduced earlier
delete(cc,'ccstut_2xx.c',brkpt)  % Remove breakpoint at line 64
close(cc,'ccstut_2xx.c','text')  % Close source file
echo off
else
echo on
% Delete breakpoint introduced earlier
delete(cc,'ccstut.c',brkpt) % Remove breakpoint at line 64
close(cc,'ccstut.c','text')  % Close source file
echo off
end
echo on
% Clear data objects
clear cc cvar cfield uicvar cstring

echo off
warning on

%==========================================================================
% Clear all variables created by the tutorial
ccstutorialVars1 = whos;
ccstutorialVars1 = setdiff({ccstutorialVars1.name},existingVars);
len1 = length(ccstutorialVars1);
for varid1=1:len1
    clear (ccstutorialVars1{varid1});
end
clear ccstutorialVars1 len1 varid1

fprintf('\n**************** Demo complete. ****************\n\n');

catch
echo off
disp('------------------------------------------');
    errMsg = lasterr;
	if ~isempty(findstr(errMsg,'Timeout waiting for CCS to confirm completion'))
        idx = findstr(errMsg,'???');
        idx2 = findstr(errMsg,': Timeout');
        if ~isempty(idx) && ~isempty(idx2), 
            method_name = upper([ ' ' errMsg(idx(1)+4:idx2(1)-1)]);
        elseif ~isempty(idx2),
            method_name = upper([ ' ' errMsg(1:idx2(1)-1)]);
        else
            method_name = '';
        end
		disp(sprintf(['\n%s\n\n!!! Timeout = %g seconds might not be enough time to run the method%s.\n'...
            'Type ''edit ccstutorial'' at the MATLAB command prompt. At the beginning \n',...
            'of the CCSTUTORIAL script, increase the value of variable ''timeoutValue''.\n'],...
            errMsg,timeoutValue,method_name));
    elseif ~isempty(findstr(errMsg,'Demo aborted by user...'))
		close(cc,projfile,'project');
		visible(cc,0);
		disp('Demo aborted by user...');
    else
        disp(errMsg);
	end
	% Delete breakpoint introduced earlier
    if board_variable == 1, % execute only if 'board' variable exists
        if strcmp(board.name,'c24x') && isC2401(cc)
            % Delete breakpoint introduced earlier
            delete(cc,'ccstut_2401.c',brkpt)  % Remove breakpoint at line 64
        elseif ~isempty(strmatch(board.name,{'c28x','c27x','c24x'},'exact'))
            % Delete breakpoint introduced earlier
            delete(cc,'ccstut_2xx.c',brkpt)  % Remove breakpoint at line 64
        else
            % Delete breakpoint introduced earlier
            delete(cc,'ccstut.c',brkpt)  % Remove breakpoint at line 64
        end
    end
    % Clear all variables created by the tutorial
	ccstutorialVars = whos;
	ccstutorialVars = setdiff({ccstutorialVars.name},existingVars);
    len = length(ccstutorialVars);
    for varid=1:len
        clear (ccstutorialVars{varid});
    end
    clear ccstutorialVars len varid
	disp(sprintf('\nExiting CCSTUTORIAL demo...'))
end
