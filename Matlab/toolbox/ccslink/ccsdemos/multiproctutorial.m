% MULTIPROCTUTORIAL Multi-processor tutorial.
%   MULTIPROCTUTORIAL is an example script intended to get the user started
%   with the Multi-Processor component of the Link for Code Composer
%   Studio®.
%
%   The demo shows how to use Link for CCS methods to connect to and
%   control multiple processors simultaneously.  And, using the same
%   connection, it also shows how to maintain full control of each
%   individual target. 
%
%   To run the MULTIPROCTUTORIAL from MATLAB, type 'multiproctutorial' at
%   the command prompt.
%
%   See also CCSTUTORIAL, HILTUTORIAL, RTDXTUTORIAL, CCSFIRDEMO,
%            RTDXLMSDEMO, CCSINSPECT, CCSDSP 

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/01 16:01:16 $

echo off
existingVars = whos;
existingVars = {existingVars.name};

try
% ========================================================================
% Intro
disp(sprintf(['=================================================================\n'...
        ' The ''Link for Code Composer Studio'' provides a direct\n'...
        '  connection between MATLAB and a target in Code Composer. The target\n'...
        '  could be a single DSP or multiple DSPs. This provides a mechanism for\n'...
        '  controlling and manipulating an embedded application using the full\n'...
        '  computational power of MATLAB. This can be used to assist DSP debugging\n'...
        '  and development. Another possible use is for creation of MATLAB scripts\n'...
        '  for verification and testing of algorithms that exist in their final\n'... 
        '  implementation on an actual DSP target. This particular tutorial shows\n'...
        '  how the ''Link for Code Composer Studio'' can be used to connect\n'...
        '  to and control multiple processors simultaneously.  Also, with the same\n'...
        '  connection, full control of each individual DSP is still available.\n\n'...
        ' Before discussing the methods available with the multi-processor link \n'...
        '  object, it is necessary to first select a target.  When the link is \n'...
        '  created, it can either be specific to a particular CPU, (i.e. a DSP\n'...
        '  processor) or to a target with multiple processors, so selection is\n'...
        '  required before proceeding. In general, the selection process is only\n'...
        '  necessary for multi-processor or multi-target configurations of Code\n'...
        '  Composer Studio.\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue ---');
pause;

% ========================================================================
% command line board/processor selection command: ccsboardinfo
disp(sprintf(['=================================================================\n'...
        ' The ''Link for Code Composer Studio'' provides a tool\n'...
        '  for selecting a DSP Board in multi-processor configurations.\n'...
        '  ''ccsboardinfo'' is a command line tool which generates a list\n'...
        '  of the available boards and processors.\n'...
        '  For scripting, this command can return a structure, which\n'...
        '  can be applied programmatically to select a particular DSP chip.\n'...
        '  For multi-processor configuration, ''ccsboardinfo'' returns an array\n'...
        '  of structures corresponding to the available processors on the target.\n'...
        '  Please note - this tutorial shows how you can use the Link with a \n'...
        '  multi-processor board.  Therefore, you must select a multi-processor\n'...
        '  board to run the rest of the tutorial.\n'...
        '  If you only have a single processor target, or if you want a tutorial\n'...
        '  on how to use the Link on a specific processor type, please run the \n'...
        '  CCSTUTORIAL instead, by typing ''ccstutorial'' at the MATLAB command prompt.\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue:  ccsboardinfo ---');
pause;
echo on

ccsboardinfo

echo off;

brdInfo = ccsboardinfo;
% Check for a multi-processor board
[mpboards,mpprocs,brdnum] = checkForMultiProc(brdInfo);

%========================================================================
% Object Constructor: ccsdsp
disp(sprintf(['=================================================================\n'...
        ' Next, the actual connection between the MATLAB command line and Code \n'...
        '  Composer will be established.  This link is represented by a MATLAB\n'...
        '  object, which for this session will be saved in variable ''cc''.  The \n'...  
        '  link object is created with the ''ccsdsp'' command. For single processor\n'...
        '  configurations, ''ccsdsp'' accepts a board  number and a processor number\n'...
        '  as input parameters. For multi-processor configurations, ''ccsdsp'' accepts\n'...
        '  a board number and an array of processor numbers, and ''cc'' would then be\n'...
        '  an array of CCSDSP objects. For a multi-processor board, if the processor \n'...
        '  numbers are not provided, ''cc'' will contain CCSDSP objects that represents\n'...
        '  all the processors on the board. Other properties can also be defined during the\n'...
        '  object creation; refer to the ''ccsdsp'' documentation for more information on\n'...
        '  these properties. The generated array of ''cc'' objects will be used to\n'...
        '  broadcast commands and direct actions to multiple designated DSP chips.\n'...
        '  Therefore, it will appear in all commands that follow the object creation.\n'...
        '  Obviously, not all CCSDSP commands that can be applied on a single processor\n'...
        '  would make sense to be applied on multiple processors at the same time.\n'...
        '  Later, we will list the multi-processor supported commands, and how they\n'...
        '  are broadcasted. Next, we will create an array of CCSDSP objects for the\n'...
        '  first 2 processors of a selected board which is assumed to be configured\n'...
        '  in Code Composer Studio. If not, please configure it before proceeding.\n'...
        '  NOTE: Before proceeding, your DSP hardware should be reset and \n'...
        '  configured as needed for operation by Code Composer.\n'...
        '=================================================================\n\n']));

disp('--- Press any key to continue:  ccsdsp ---');
pause;

brdIdx = min(find(brdnum==[brdInfo.number]));
% Display board name
disp(sprintf('\nThe tutorial will run on the following board:\n ''%s''',brdInfo(brdIdx).name));
% Display board number
disp(sprintf('\nbrdnum = %d',brdnum));
% Display proc numbers
prcnum = mpprocs{brdIdx};
disp(sprintf('\nprcnum = %s',['[ ' num2str(prcnum) ' ]']));
echo on

cc = ccsdsp('boardnum',brdnum,'procnum',prcnum)

echo off

%========================================================================
% Array of CCSDSP Objects illustrated
disp(sprintf(['=================================================================\n'...
        '  Note how the processors numbers, names, and status are listed when ''cc'' \n'...
        '  is displayed. Since ''cc'' is an array of CCSDSP objects, it is necessary\n'...
        '  to know what element of that array correspond to each processor.\n'...
        '  The ''element #'' displayed next to each processor gives us that information.\n'...
        '  ''cc(#)'' is the corresponding object for the given processor as illustrated next.\n'...
        '=================================================================\n']));

disp('--- Press any key to continue: cc(#) ---');
pause;
echo on

% Object handle for the first processor 
cc(1)    


% Object handle for the second processor 
cc(2)    

echo off

%========================================================================
% Visibility of Code Composer
disp(sprintf(['=================================================================\n'...
        ' You may have noticed Code Composer appeared briefly when ''ccsdsp''\n'...
        '  was called.  If Code Composer was not running before the link\n'...
        '  is established, it is started and then placed in the background.\n'...
        '  In most cases, you will need to interact with Code Composer,\n'...
        '  so the first method that will be introduced (''visible'')\n'...
        '  controls the state of Code Composer on the desktop. This accepts\n'...
        '  a boolean input that makes Code Composer visible (1) or \n'...
        '  invisible (0) on the desktop.  For the rest of this tutorial, \n'...
        '  we will need to interact with Code Composer, so we will use \n'...
        '  ''visible'' to bring CCS up to the desktop. Since ''cc'' is a\n'...
        '  1x2 array of CCSDSP objects, 2 CCS windows will open up after\n'...
        '  the command ''visible(cc,1)'' is executed.\n'...
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
        '  query Code Composer for status on the specified target.\n'...
        '  Four methods are available to get status information:  \n'...
        '  ''info''          - returns an array of structures of testable Target conditions.\n'...
        '  ''display''       - prints a list of information about the target.\n'...
        '  ''isrunning''     - returns the state (running or halted) of each CPU on the target.\n'...
        '  ''isrtdxcapable'' - reports each CPUs ability to perform RTDX(tm) transfers.\n'...
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

linkinfo = info(cc);  % 1x2 array of structures

% Information on the first processor 
linkinfo(1)

% Information on the second processor 
linkinfo(2)

cpurunstatus = isrunning(cc)

isrtdxcapable(cc)

echo off

%========================================================================
% Determine family variants (28x or 54x or 55x or 6x11 or 6x0x?)
CPU1 = GetDemoProp(cc(1),'ccstutorial');
CPU2 = GetDemoProp(cc(2),'ccstutorial');
 
%========================================================================
% The Code Composer Files: open

disp(sprintf(['=================================================================\n'...
        ' Now that a connection has been established, the target CPUs need\n'...
        '  something to do!  Therefore, the next step is to create executable \n'...
        '  code for each target DSP with Code Composer. For this tutorial, \n'...
        '  Code Composer project files and processor specific executables were \n'...
        '  created and included with MATLAB. We will first attempt to load\n'...
        '  the included executables directly, and if the load fails (due to\n'...
        '  a different board or processor you are using), you will be prompted\n'...
        '  to build and load the executables. \n'...
        '=================================================================\n']));
disp('--- Press any key to continue:  open,cd ---');
pause;
warning off
echo on

projfile1 = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','ccstutorial',CPU1.ccstut.projname)  

projfile2 = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','ccstutorial',CPU2.ccstut.projname)  

projpath1 = fileparts(projfile1)

projpath2 = fileparts(projfile2)

open(cc(1),projfile1)     % Open project file for the first processor

open(cc(2),projfile2)     % Open project file for the second processor

cd(cc,projpath1)           % Change working directory of Code Composer(only)


echo off
warning on
%========================================================================
% The Code Composer program file: Load
disp(sprintf(['=================================================================\n'...
        '  Note how we indexed ''cc'' to use the DSP processor we wish to target.\n'...
        '  You should notice the tutorial''s projects loaded in Code Composer.\n'...
        '  Examine the files in Code Composer that comprise this project -\n'...  
        '  the main source file used by this tutorial is ''ccstut.c'', a linker\n'... 
        '  command file (*.cmd) and vector table source file (*.asm), which\n'...
        '  will vary depending on the DSP family you are using.  Now, we will \n'...
        '  attempt to load the executables on each CPU. This will use the ''load''\n'...
        '  method, which should only be used for program files.\n'...
        '=================================================================\n']));
disp('--- Press any key to continue:  load ---');
pause;
try
echo on

% Load the execution file on the first CPU
load(cc(1),CPU1.ccstut.loadfile,30)    

echo off    
catch
echo off    
    disp(sprintf(['!!!!! The load of ''%s'' failed on the first CPU. It could be\n',...
            'that DSP family you are using needs a different linker command file (*.cmd)\n'...
            'and vector table source file (*.asm). Please attempt to rebuild the executable\n'...
            'with the appropriate files and then manually load it from Code Composer.'],CPU1.ccstut.loadfile));
	proceed = input('Then enter 1 to proceed with the demo, or 0 to exit: ');
	if (proceed==0)
		close(cc,projfile,'project');   
		visible(cc,0);
		clear cc
		error('Demo aborted by user...');
	end
            
end

try
echo on

% Load the execution file on the second CPU
load(cc(2),CPU2.ccstut.loadfile,30)    

echo off    
catch
echo off    
    disp(sprintf(['  !!!!! The load of ''%s'' failed on the second CPU. It could be\n',...
            '  that DSP family you are using needs a different linker command file (*.cmd)\n'...
            '  and vector table source file (*.asm). Please attempt to rebuild the executable\n'...
            '  with the appropriate files and then manually load it from Code Composer.'],CPU2.ccstut.loadfile));
	proceed = input('Then enter 1 and press return to proceed with the demo, or 0 to exit: ');
	if (proceed==0)
		close(cc,projfile,'project');   
		visible(cc,0);
		clear cc
		error('Demo aborted by user...');
	end
             
end


disp(sprintf(['=================================================================\n'...
        '  After the target code are loaded, it is possible now to broadcast commands to \n'... 
        '  both CPUs to do something! Below is a list of methods that are available to any \n'...
        '  multi-processor system. \n'...
        '    a. run     : sequentially initiates execution of both DSP processors.  \n'...
        '    b. halt    : sequentially terminates execution of both DSP processors.\n'...
        '    c. reset   : sequentially performs a software reset of both DSP processors. \n'...
        '    d. restart : sequentially restores each processor to the program entry point.\n'...
        '    e. reload  : sequentially loads the most recently used program file into each target.\n'...
        '  Next, we will run both processors, then halt them, and then reload, reset, and\n'...
        '  finally restart again.\n'...
        '=================================================================\n\n']));
    
disp('--- Press any key to continue:  run, isrunning, halt ---');
pause;
echo on

run(cc)             % run both processors
isrunning(cc)       % verify both processors are running

% notice how the status of each processor is now updated
cc                  

echo off
disp('--- Press any key to continue:  halt, isrunning ---');
pause;
echo on

halt(cc)            % halt both processors

isrunning(cc)       % verify both processors are not running

% notice how the status of each processor is now updated
cc                  

echo off
disp('--- Press any key to continue:  reset, reload, restart ---');
pause;
echo on

reset(cc)           % software reset on both processors

pause(1)            % wait until reset is completed

outfiles = reload(cc);          % reload program files on both processors
echo off

outfiles{1}
outfiles{2}

echo on

restart(cc)         % restart on both processors
echo off

% Insert Breakpoint
disp(sprintf(['=================================================================\n'...
        ' Next we will interact with the first processor only using single-processor\n'...
        '  methods. On all commands, note how we index ''cc'', i.e. cc(1), to refer \n'...
        '  refer to the first processor.\n'...
        ' After the target code is loaded, it is possible to examine and modify \n'...
        '  data values in the target processor from MATLAB.\n'...
        '  For static data values, it is possible to read them immediately after\n'...
        '  loading a program file.  However, the more interesting case is to \n'...
        '  manipulate data values at intermediate points during program execution.\n'...
        '  To facilitate this operation, there are methods to insert (and delete) \n'...
        '  breakpoints in the DSP program.  The method ''insert'' creates a new \n'...
        '  breakpoint, which can be specified either through a source file location \n'...
        '  or through a physical memory address.\n'...
        ' For this tutorial, we need to insert a breakpoint at line 64 of the \n'...
        '  ''ccstut.c'' source file.\n'...
        '  To assist your visibility of this action, the method ''open'' is used to\n'...
        '  display the source file in Code Composer.  Furthermore, the ''activate'' \n'...
        '  method is used to force this file to the front.\n'...
        '  Towards the end of the tutorial, the ''delete'' method will be used to \n'...
        '  remove the breakpoint we introduced.\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue:  activate, insert and open ---');
pause;
echo on


echo off
if strcmp(CPU1.name,'c28x')
echo on

open(cc(1),'ccstut_28xx.c','text')     % Be sure this file is open for viewing in CCS
activate(cc(1),'ccstut_28xx.c','text') % Bring the source file forward
insert(cc(1),'ccstut_28xx.c',64)       % Insert breakpoint at line 64

echo off
else
open(cc(2),'ccstut.c','text')     % Be sure this file is open for viewing in CCS
echo on

open(cc(1),'ccstut.c','text')     % Be sure this file is open for viewing in CCS
activate(cc(1),'ccstut.c','text') % Bring the source file forward
insert(cc(1),'ccstut.c',64)       % Insert breakpoint at line 64

echo off
end
echo off

%========================================================================
% Halt, run, read
disp(sprintf(['=================================================================\n'...
        ' Examine the source file ''ccstut.c'' in the Code Composer Studio \n'...
        '  source editor area.  There should be a breakpoint on line 64\n'...
        '  (indicated by a red dot).  Next, locate the two global data\n'.... 
        '  arrays: ''ddat'' and ''idat'', which are located at lines 44\n'...
        '  and 45 in this file. \n'...
        '  These memory arrays can be accessed directly from the MATLAB\n'...
        '  command line using the ''read'' and ''write'' methods.\n'...
        '  To control target execution, use the ''run'', ''halt'' and ''restart'' \n'...
        '  methods.  The following section will demonstrate these methods.\n'...
        ' Note: This approach to access processor memory is powerful but rudimentary. \n'...
        '  Later in the tutorial, we''ll introduce an easier method based on\n'...
        '  C variables (supports C6x, C54x, C55x, R2x, R1x, OMAP).\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue:  halt,restart,read ---');
pause;
try

if ~isempty(strmatch(CPU1.name,{'c28x','c54x','c55x'}))

echo on

run(cc(1),'runtohalt',45);     % Run and wait for program execution to stop at breakpoint! (timeout = 45 seconds)
      
ddatV = read(cc(1),address(cc(1),'ddat'),'single',4)   % Should equal initialized value from C code
idatV = read(cc(1),address(cc(1),'idat'),'int16',4)    % Read using a different numeric representation

echo off
disp('--- Compare Data: idat, ddat with Code Composer, then press return ---');
pause;
echo on

% Modify memory values
write(cc(1),address(cc(1),'ddat'),single([pi 12.3 exp(-1) sin(pi/4)]))   
write(cc(1),address(cc(1),'idat'),int16([1:4]))

run(cc(1),'run',20);     % Resume execution from breakpoint
  
ddatV = read(cc(1),address(cc(1),'ddat'),'single',4)
idatV = read(cc(1),address(cc(1),'idat'),'int16',4)
        
restart(cc(1));

echo off
else % C6xx,Rxx Family
echo on

run(cc(1),'runtohalt',45);     % Run and wait for program execution to stop at breakpoint! (timeout = 45 seconds)
        
ddatV = read(cc(1),address(cc(1),'ddat'),'double',4)   % Should equal initialized value from C-Code
idatV = read(cc(1),address(cc(1),'idat'),'int16',4)

echo off
disp('--- Compare Data: idat, ddat with Code Composer, then press return ---');
pause;
echo on       

write(cc(1),address(cc(1),'ddat'),double([pi 12.3 exp(-1) sin(pi/4)]))   % Modify memory values
write(cc(1),address(cc(1),'idat'),int16([1:4]))
        
run(cc(1),'runtohalt',45); % Resume execution from breakpoint, then modify
        
ddatV = read(cc(1),address(cc(1),'ddat'),'double',4)
idatV = read(cc(1),address(cc(1),'idat'),'int16',4)
        
restart(cc(1));

echo off
end
catch
echo off
disp(lasterr);
    disp(sprintf(['!!!! The program execution failed.  In general, this is because the\n'....
            'breakpoint was not included in the source file.  This caused the\n'...
            'CPU to continue execution without halting.  Try re-running the\n'...
            'tutorial and be sure to insert the breakpoint when it is requested.\n'...
            'In some cases, resetting the board before running the tutorial may be\n'...
            'necessary.  It is often helpful to verify the Target code in Code\n'...
            'Composer before executing the tutorial.\n']));
    error('MULTIPROCTUTORIAL failure');
end

%========================================================================
% regread/regwrite
disp(sprintf(['=================================================================\n'...
        ' For Assembly language programmers, there are also methods\n'...
        ' to access CPU registers: ''regread'' and ''regwrite''.\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue: regread,regwrite ---');
pause;
if ~isempty(strmatch(CPU1.name,{'c28x','c54x','c55x'}))
echo on

tReg = regread(cc(1),'AL','2scomp')    % 2's complement version of AL
regread(cc(1),'PC','binary')           % Unsigned version of the PC register.
regwrite(cc(1),'AH','FFFF','binary')

echo off
elseif ~isempty(strmatch(CPU1.name,{'r2x','r1x'}))
echo on

tReg = regread(cc(1),'R0','2scomp')    % 2's complement version of R0
regread(cc(1),'PC','binary')           % Unsigned version of PC
regwrite(cc(1),'R2',tReg,'2scomp')

echo off   
else
echo on

tReg = regread(cc(1),'A0','2scomp')    % 2's complement version of A0
regread(cc(1),'B2','binary')           % Unsigned version of B2
regwrite(cc(1),'A2',tReg,'2scomp')

echo off
end

if ~isempty(strmatch(CPU1.name,{'c54x','c6x0x','c6x11','r1x','r2x','c55x'})) % HIL support
    %========================================================================
    % List, Goto
    
    disp(sprintf(['=================================================================\n'...
            ' Direct access to a processor''s memory is powerful, but for C programmers it is \n'...
            '  more convenient to manipulate memory in ways consistent with the\n'...
            '  defined C variables.  This type of access is implemented using MATLAB\n'...
            '  objects as representations of embedded entities. \n'...
            '  First, let''s take a look at the same data values that we explored \n'...
            '  above but now we''ll manipulate them using objects. \n'...
            '=================================================================\n\n']));
    disp('--- Press any key to continue: run ---');
    pause;
    echo on
    
restart(cc(1))     % Restart program
pause(1)

run(cc(1),'main')  % Run to start of 'main' - ensured Embedded C variables get initialized

echo off
disp('--- Press any key to continue ---');
    
%========================================================================
% Createobj, Read, Write
disp(sprintf(['=================================================================\n'...
        '  Up to this point all methods were applied to the  ''cc'' objects\n'...
        '   that were created with ''ccsdsp''.  The ''cc'' object represents communication \n'...
        '   with a particular embedded processor in Code Composer Studio.\n'...
        '  However, methods can be applied to many different objects.  In typical \n'...
        '   object-oriented fashion, the action performed by a method will depend on it''s \n'...
        '   object.  The relevant object is always the first parameter passed to the method.\n'...
        '   For example, ''cvar'' is an object representing the embedded ''idat'' variable.\n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue: createobj, read, write ---');
pause;
echo on

cvar = createobj(cc(1),'idat')  % Creates a MATLAB object 'cvar' to manipulate embedded 'idat'

read(cvar)  % Reads the entire embedded array into the MATLAB workspace

read(cvar,2)  % Reads only the second element

write(cvar,4,7001)  % Modifies the fourth element to 7001

read(cvar)  % See changes

read(cvar,[1 cvar.size])  % Read only first and last elements

echo off
    
echo off
disp(sprintf([...
    '=================================================================\n'...
    ' To learn more about the Link for Code Composer Studio, run the following tutorials:\n'...
    '  a. ''CCSTUTORIAL''  - illustrates the debug and data manipulation features\n'...
    '  b. ''HILTUTORIAL''  - illustrates the hardware-in-the-loop feature        \n'...
    '  c. ''RDTXTUTORIAL'' - illustrates the real-time data exchange feature support\n'...
    '  See also CCSFIRDEMO, RTDXLMSDEMO, CCSINSPECT                              \n'...
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
close(cc(1),projfile1,'project')   % close the project file
close(cc(2),projfile2,'project')   % close the project file
visible(cc,0);
echo off
% Delete breakpoint introduced earlier
if strcmp(CPU1.name,'c28x')
echo on

% Delete breakpoint introduced earlier
delete(cc(1),'ccstut_28xx.c',64)  % Remove breakpoint at line 64
echo off
else
echo on

% Delete breakpoint introduced earlier
delete(cc(1),'ccstut.c',64) % Remove breakpoint at line 64
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
    [errMsg,errId] = lasterr;
    chkFlag = 1;

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
		disp(sprintf([ ...
        '\n%s\n\n!!! Timeout = %g seconds might not be enough time to run the method%s.\n'...
        'Type ''edit ccstutorial'' at the MATLAB command prompt. At the beginning \n',...
        'of the MULTIPROCTUTORIAL script, increase the value of variable ''timeoutValue''.\n'],...
        errMsg,timeoutValue,method_name));
    elseif ~isempty(findstr(errMsg,'Demo aborted by user...'))
		close(cc,projfile,'project');
		visible(cc,0);
		disp('Demo aborted by user...');
    elseif ~isempty(findstr(errId,'MULTIPROCTUTORIAL:MultiprocBoardNotFound'))
		disp(sprintf([ ...
        'Cannot proceed with the demo, no multi-processor board is found.\n',...
        'Please include a multi-processor target in your CCS setup.']));
        chkFlag = 0;
    else
        disp(errMsg);
	end
    
    % Delete breakpoint introduced earlier    
    if chkFlag,
		if strcmp(CPU1.name,'c28x')
            % Delete breakpoint introduced earlier
		    delete(cc(1),'ccstut_28xx.c',64)  % Remove breakpoint at line 64
        else
            % Delete breakpoint introduced earlier
        	delete(cc(1),'ccstut.c',64)  % Remove breakpoint at line 64
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
	disp(sprintf('\nExiting MULTIPROCTUTORIAL demo...'))
end

% [EOF] multiproctutorial.m