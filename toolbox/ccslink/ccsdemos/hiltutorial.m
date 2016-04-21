% HILTUTORIAL Hardware-in-the-loop tutorial.
%   HILTUTORIAL is an example script intended to get the user familiar with
%   the Hardware-In-the-Loop (HIL) component of the 'Link for Code Composer
%   Studio®'.  
%
%   A simple target DSP application is loaded and run on the target DSP.
%   MATLAB objects to DSP functions and variables are created. The tutorial
%   shows how to get the function signature (argument names & types,
%   function return type, starting address, etc.), set the data for each 
%   input argument, run the function and read the returned value(s) all
%   from MATLAB. 
%
%   Methods that are demonstrated include
%   Global Functions:
%     ccsboardinfo, boardprocsel, ccsdsp
%   CCSDSP object methods:
%     createobj
%   Memory and Register object methods:
%     read        (for numeric, pointer, string, enum, struct data)
%     write       (for numeric, pointer, string, enum, struct data)
%     cast        (for numeric, pointer, string, enum, struct data)
%     deref       (for pointer data)
%     getmember   (for struct data)
%     readnumeric (for enum data)
%   Function object methods -
%     declare, run, goto, execute, copy, read, write
%
%   To run the HILTUTORIAL from MATLAB, type 'hiltutorial' at the command
%   prompt.
%
%   See also CCSTUTORIAL, RTDXTUTORIAL, CCSFIRDEMO, RTDXLMSDEMO,
%            CCSINSPECT, CCSDSP 

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.18.4.3 $  $Date: 2004/04/01 16:01:04 $

echo off
existingVars = whos;
existingVars = {existingVars.name};
errormsgforsupportedplatforms = '';
warning off MATLAB:integerConversionNowRoundsInsteadOfTruncating
warning backtrace off

timeoutValue = 100;  % Value (in seconds) to set default CCSDSP and OBJECT timeout to

try
% ========================================================================
% Introduction:
disp(sprintf(['=================================================================\n'...
        ' The ''Link for Code Composer Studio'' has a Function Call \n'...
        '  component that enables you to perform Hardware-in-the-loop (HIL)\n'...
        '  from MATLAB.\n'...
        ' The HIL capability enables you to verify DSP implementation, within\n'...
        '  the context of an entire system design, by simulating in MATLAB the\n'...
        '  components not implemented on the DSP.\n'...
        '  You may want to verify your implementation of an FIR filter, for\n'...
        '  example, on your DSP while simulating your input and output data\n'...
        '  in MATLAB. The performance of your closed-loop system design\n'...
        '  may be assessed with the real-world constraints of hardware (DSP)\n'...
        '  and software (DSP implementation). In this tutorial, you call DSP \n'...
        '  functions, get the function signature (argument names & types, \n'...
        '  function return type, starting address, etc.), set the data for \n'...
        '  each input argument, run the function and read the returned value(s)\n'...
        '  all from MATLAB.\n'...
        '  This tutorial assumes that you are relatively familiar with\n'...
        '  ''Link for Code Composer Studio''. If not, we suggest that\n'...
        '  you run CCSTUTORIAL first to give you a better understanding\n'...
        '  of what the ''Link for Code Composer Studio'' does.\n'...
        '  Run the CCSTUTORIAL by typing ''ccstutorial'' at the command prompt \n'...
        '  in MATLAB.\n'...
        '=================================================================\n\n']));

disp('---  Press any key to continue ---');
pause;

% ========================================================================
% GUI board/processor selection tool and establish link:
% boardprocsel, ccsdsp
disp(sprintf(['=================================================================\n'...
        '  Start by selecting a DSP using a GUI tool called ''boardprocsel'',\n'...
        '  and then we will create a link between MATLAB and Code Composer.\n'...
        '  The link is represented by a MATLAB object, which for this session \n'...
        '  will be saved in variable ''cc''.\n'...
        '  Please note - the CPU that you select in the GUI is used\n'...
        '  for the rest of this tutorial.  For single processor installations,\n'...
        '  of CCS, simply select ''OK'' from the dialogue to continue.\n'...
        '=================================================================\n\n']));

disp('---  Press any key to select a DSP from the GUI and create link:  boardprocsel,ccsdsp ---');

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
    fprintf(1,['=================================================================\n'...
            'The goal of this selection process is a board number\n'...
            ' and processor number that uniquely identify a particular\n'...
            ' target DSP.  These values are applied during the link creation.\n\n'...
            'You selected board number = %d, and processor number = %d\n',...
            '=================================================================\n'],boardNum,procNum);
    disp('---  Press any key to continue --- '); pause;
end

echo on

cc = ccsdsp('boardnum',boardNum,'procnum',procNum)

timeoutValue
set(cc,'timeout',timeoutValue); % Set CCSDSP default timeout value

echo off


%========================================================================
% The Code Composer Files: open

disp(sprintf(['=================================================================\n'...
        ' Now that a connection has been established, the target CPU needs\n'...
        '  something to do!  Therefore, the next step is to create executable \n'...
        '  code for the target DSP with CCS. For this tutorial, a\n'...
        '  CCS project file and a board specific executable were \n'...
        '  created and included with MATLAB. We will attempt to load\n'...
        '  the included executable directly, and if the load fails (could be\n'...
        '  because it is a different board or processor), we will build the\n'...
        '  included project. The following set of commands locate the\n'...
        '  tutorial project and load it into CCS.  This will use the\n'...
        '  ''open'' method, and can direct CCS to load a project\n'...
        '  file or a program file. \n'...
        '=================================================================\n\n']));
disp('--- Press any key to continue:  open,cd ---');
pause;
echo on

board = GetDemoProp(cc,'hiltutorial');

echo off
if isempty(strmatch(board.name,{'c28x','c54x','c64x','c67x','c6x0x','c6x11'})) % HIL support
    errormsgforsupportedplatforms = 'HILTUTORIAL only supports processors C28x, C54x and C6x.';
    error(errormsgforsupportedplatforms);
end
echo on

projfile = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','hiltutorial',board.hiltut.projname)  
projpath = fileparts(projfile)

% Resetting the target DSP ...
echo off
%reset bug on the C54x simulator
ccInfo = info(cc);
if ~(strcmp(board.name,'c54x') && any((findstr(lower(ccInfo.boardname),'sim'))))
echo on
reset(cc,100);               % reset the CPU (if necessary)
pause(2);
echo off
end
echo on
open(cc,projfile)     % Open project file
cd(cc,projpath)       % Change working directory of Code Composer(only)
visible(cc,1)

echo off
if ~isempty(strmatch(board.name,'c54x'))
open(cc,'hiltut_54x.c','text');
activate(cc,'hiltut_54x.c','text');
else
open(cc,'hiltut.c','text');
activate(cc,'hiltut.c','text');
end    

%========================================================================
% The Code Composer program file: Load

disp(sprintf(['\n',...
	'=================================================================\n'...
	' You should notice the tutorial''s project loaded in CCS.\n'...
	'  Examine the files in CCS that compose this project - the \n'...  
	'  main source file used by this tutorial is ''hiltut.c'', a linker\n'... 
	'  command file (*.cmd) and vector table source file (*.asm), which\n'...
	'  will be different, depending on the DSP family you are using. \n'...
	'  Also examine the variables and functions in the source file\n'...
	'  ''hiltut.c'', as we will manipulate them from MATLAB later in the tutorial.\n'...
	'  Before building this project, we will attempt to load the included\n'...
	'  executable. This will use the ''load'' method, which should only\n'...
	'  be used for program files.\n'...
	'=================================================================\n\n']));

disp('--- Press any key to continue:  load ---');
pause;
try
warnState = warning('on');   % Enable warnings to demonstrate the next command
warning(warnState);  % Reinstate warning state
echo on

load(cc,board.hiltut.loadfile)    % Load the target execution file

echo off    
catch % if error occurs while loading
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
        'is supplied with the ''build'' method. \n'],board.hiltut.loadfile));
        
disp('--- Press any key to continue:  build,load ---');
pause;
% Setting the right build options:
setbuildopt(cc,'Compiler',board.hiltut.Cbuildopt);
% Directing output program file to a temporary directory on your system
setbuildopt(cc,'Linker',['-c -o"' tempdir board.hiltut.loadfile '" -x']);
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
load(cc,[tempdir board.hiltut.loadfile]);

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
            'and the manually load it from Code Composer Studio.\n'],board.hiltut.loadfile));
    contFlag = 'dummy';
    while ~isempty(contFlag) && ~strcmpi(contFlag,'exit')
        contFlag = input('After loading, hit <enter> to proceed with the demo or type ''exit'' to exit the demo: ','s');
    end

    if ~isempty(contFlag),
        % Clear all variables created by the tutorial
		hiltutorialVars1 = whos;
		hiltutorialVars1 = setdiff({hiltutorialVars1.name},existingVars);
        len1 = length(hiltutorialVars1);
        for varid1=1:len1
            clear (hiltutorialVars1{varid1});
        end
        clear hiltutorialVars1 len1 varid1
		disp(sprintf('\nExiting HILTUTORIAL demo...'))
        return
    end
end
end

echo on
cd(cc,projpath); % Restore back working directory for Code Composer Studio

echo off

    %========================================================================
    % List, Goto
    
    disp(sprintf(['=================================================================\n'...
            ' Direct access to DSP memory is powerful, but for C programmers it is \n'...
            '  more convenient to manipulate memory in ways consistent with the\n'...
            '  defined C variables.  This type of access is implemented using MATLAB\n'...
            '  objects as representations of embedded entities. \n'...
            '  First, let''s take a look at the data values in the program and\n'...
            '  manipulate them using objects. For that we will apply the ''list'' method,\n'...
            '  which queries CCS for information, on ''idat'', i.e. the global C\n'...
            '  variable of interest.\n'...
            '=================================================================\n\n']));
    disp('--- Press any key to continue: list ---');
    
pause;
echo on
run(cc,'main')   % Ensured embedded C variables are initialized

list(cc,'function')  % Returns a structure of the available functions in the program

list(cc,'variable') % Returns a structure of the defined variables in the program

echo off
disp('--- Press any key to continue ---');
pause;
echo on

list(cc,'type') % Returns a structure of the defined data types in the program

listI = list(cc,'variable','idat')  % Returns structure of information about global variable: 'idat'

listI.idat

echo off
disp('--- Press any key to continue ---');
pause;
%========================================================================
% Createobj, Read, Write
    
    disp(sprintf(['=================================================================\n'...
            ' ''List'' generates lots of information about the embedded ''idat'' variable.\n'...
            '  However, an even more useful method is ''createobj'', which generates \n'...
            '  a MATLAB object to represent the C variable.  This object \n'...
            '  acquires the properties of the C variable.  Applying the object\n'...
            '  returned by ''createobj'', you can directly read the entire \n'...
            '  variable or access individual elements of an array.\n'...
            '  Note: Up to this point all methods were applied to the original ''cc''\n'...
            '  object that was created with ''ccsdsp''.  The ''cc'' object represents \n'...
            '  communication with a particular embedded processor in Code Composer Studio.\n'...
            '  However, for the remainder of this tutorial, methods are applied to many \n'...
            '  different objects.  In typical object-oriented fashion, the action\n'...
            '  performed by a method depends on its object.  The relevant object\n'...
            '  is always the first parameter passed to the method. For example, in the\n'...
            '  following section, ''cvar'' is an object representing the embedded \n'...
            '  ''idat'' variable.\n'...
            '=================================================================\n\n']));
    disp('--- Press any key to continue: createobj, read, write ---');
    
pause;
echo on
cvar = createobj(cc,'idat')   % Creates MATLAB object 'cvar' to manipulate embedded 'idat'
get(cvar,'size')              % Size of cvar should be 2x3 as defined in our DSP Code

read(cvar)       % Reads the entire embedded matrix into the MATLAB workspace

readhex(cvar)    % Reads cvar in hex

readbin(cvar)    % Reads cvar in binary 

echo off


    disp(sprintf(['=================================================================\n'...
            ' The previous ''read''s'' will read the entire matrix into MATLAB workspace. \n'...
            ' We can also read/write selective elements of that matrix, just by indexing \n'...
            ' the specified matrix. This capability in ''read/write'' for objects is much\n'...
            ' easier and more powerful than reading from and writing to raw memory, and \n'...            
            ' manually figuring out the right address offsets for our array. \n'...
            '=================================================================\n\n']));
    disp('--- Press any key to continue: read, write (indexing)---');
    
pause;
echo on;

read(cvar,[2 1])     % Reads the element specified by column 2, row 1

write(cvar,[2 1], -7000)    % Modifies 7000 to -7000

read(cvar)      % See changes

echo off


    %========================================================================
    % Cast, Convert, Size
    disp(sprintf(['=================================================================\n'...
            ' The previous ''read'' takes the raw memory values and converts them\n'...
            '  into equivalent MATLAB numeric values.  The conversion that gets \n'...
            '  applied is controlled by the properties of the object, which were\n'...
            '  initially configured in ''createobj'' to settings appropriate for \n'...
            '  your DSP architecture and C representation. In some cases, it is\n'...
            '  useful to alter these default conversion properties.  Several\n'...
            '  properties such as ''endianness'', ''arrayorder'', and ''size'' can\n'...
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
read(uicvar)   % Note - first value is no longer read as -1, but as unsigned equivalent

convert(cvar,'unsigned short')  % Same as cast, but alters properties of existing class 
read(cvar)    % Remember - the size of cvar was set to 2!

echo off
    
    %========================================================================
    % getmember
    
    disp(sprintf(['=================================================================\n'...
            ' DSP variables such as strings, structures, bit fields, enumerated types\n'...
            '  and pointers can be manipulated just as easily.   The following operations\n'...
            '  demonstrate some common manipulations on structures, strings\n'...
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

cstring = createobj(cc,'myString')   %  Object that represents an embedded C structure
read(cstring)

write(cstring,7,'ME')

read(cstring)

write(cstring,1,127)  % Set first location to numeric value 127 (a non-printable ASCII character)

readnumeric(cstring)  % Read equivalent numeric values

echo off;
disp(sprintf(['=================================================================\n'...
              ' Manipulation of embedded data is useful, but eventually developers\n'...
              '  must contend with embedded functions. To facilitate debugging and \n'...
              '  verification, the ''Link for Code Composer Studio'' \n'...
              '  provides objects for accessing embedded functions directly \n'...
              '  from MATLAB.  This permits any C-callable function to be\n'...
              '  executed in MATLAB for ''hardware-in-the-loop'' functionality.\n'...
              ' The first step is to make the necessary function object by applying the\n'...
              '  (now familiar) ''createobj'' method on ''cc''.  Just like variables,\n'...
              '  the ''list'' method is also available to retrieve information \n'...
              '  about functions. The following will create an object for the embedded\n'...
              '  function ''sin_taylor''.                                            \n'...
              '=================================================================\n\n']));
disp('--- Press any key to continue: list, createobj (for functions) ---');
pause;
echo on

listI = list(cc,'function','sin_taylor')     % Information about embedded function sin_taylor

listI.sin_taylor

cfunc = createobj(cc,'sin_taylor')   % create function object

echo off

%========================================================================
% run (for functions) 
disp(sprintf(['=================================================================\n'...
              ' At this point, the function object is fully ready to run. \n'... 
              '  The embedded function ''sin_taylor'' computes a fixed-point \n'... 
              '  sine function with 4 terms of a Taylor series. Let''s apply \n'... 
              '  our new object to verify the embedded function!  The input\n'...
              '  type is Q2.13 and output Q1.14. \n'... 
              '=================================================================\n\n']));
disp(sprintf('--- Press any key to continue: run (for functions) ---\n'));
pause;

userval = input('Enter a number between -pi and pi (input to the DSP sine implementation): ');
sprintf('\n');
while (isempty(userval) || ~isnumeric(userval) || abs(userval) > pi)
    userval = input('Data entered is not a numeric value between -pi and pi, try again: ');
end
echo on

sintf = run(cfunc,'x',int16(userval*2^13))/2^14   % execute: sin_taylor(1);  // Scaling for binary point applied

echo off

disp(sprintf('\nRESULT:'))
disp(sprintf(' Embedded sin_taylor(): sin(%g) = %g',userval,sintf))
disp(sprintf(' MATLAB Function sin(): sin(%g) = %g\n',userval,sin(userval))) % should be the same

disp(sprintf('\n--- Press any key to continue ---\n'));
pause;
%==========================================================================
disp(sprintf(['=================================================================\n'...
              ' In some cases, it is useful to alter the function object properties,\n'... 
              '  which were initialized to reflect your DSP source code. Several properties\n'... 
              '  like ''return type'', ''savedregs'', ''timeout'' can be set using ''set''.\n'... 
              '  Sometimes, we would like to keep the original properties of the object,\n'... 
              '  and maybe apply the new properties on a copy of that function. The method\n'... 
              '  ''copy'' does just that. In the following section, we will create a copy of \n'... 
              '  ''cfunc'' and use the copy for debugging purposes. \n'... 
              '=================================================================\n\n']));

disp('--- Press any key to continue: copy,convert,run (for functions) ---');
pause;
echo on

cfunc_copy = copy(cfunc)  % creates a copy of cfunc
get(cfunc_copy,'outputvar')  % get the function return type

echo off
disp('Notice the difference in the ''Word size'' field:');
echo on
convert(cfunc_copy.outputvar, 'int8')  % convert the output data type to be of type 'int8'

int8_OUT = run(cfunc_copy,'x',userval*2^13)/2^14   % execute the copy function, with output data type 'int8'

echo off
%==========================================================================
disp(sprintf(['=================================================================\n'...
              ' Function calls support different types of DSP variables, such as \n'... 
              '  strings, structures, bit fields, enumerated types and pointers.\n'...
              '  In the following example, we will create an object for ''sin_taylor_vect'',\n'... 
              '  a vectorized version of ''sin_taylor''. We will create input/output buffers\n'... 
              '  each of size 10, supply the start addresses of both buffers to our function\n'... 
              '  object and run it.\n'... 
              '=================================================================\n\n']));

disp('--- Press any key to continue: run,createobj,write,read (for functions) ---');
pause;

echo on

cfunc_vec = createobj(cc,'sin_taylor_vect') % create function object
ibufobj = createobj(cc,'ibuf');             % create an object for the input buffer
obufobj = createobj(cc,'obuf');             % create an object for the output buffer

echo off
disp(sprintf('--- Press any key to continue ---\n'));
pause;
echo on

inputdata = [-pi:0.1:pi];  % input data to be written to the DSP target

write(ibufobj,int16(inputdata*2^13));      % write data to input buffer // scaling for binary point
write(obufobj,int16(zeros(1,63)));         % initialize output buffer to zeros

read(ibufobj) % verify  data initialization

read(obufobj) % should be zeros

echo off

disp('--- Press any key to continue and run the sin_taylor_vect function ---');
pause;

echo on

% Run sin_taylor_vect: notice how input/output parameters correspond to the signature 
% of the function, and how input parameters are supplied in pairs (parameter,value)

outputAddress = run(cfunc_vec,'x',ibufobj.address(1),'y',obufobj.address(1),'npts',63);

% OR

outputdataAddress = deref(cfunc_vec.outputvar); % dereference the output data
outputdataAddress.size = 63;                    % we need to read the next 63 addresses (obuf)
outputdata = read(outputdataAddress)/2^14;      % get output & scale

echo off

h = figure;
subplot(2,1,1)
plot(inputdata,outputdata)
title('Result of sin(inputdata) on the DSP')
a = gca;
set(get(a,'title'),'fontsize',10);
set(a,'fontsize',8);
set(a,'fontweight','light');
axis tight; grid on;

subplot(2,1,2)
plot(inputdata,sin(inputdata))
title('Result of sin(inputdata) in MATLAB')
b = gca;
set(get(b,'title'),'fontsize',10);
set(b,'fontsize',8);
set(b,'fontweight','light') ;
axis tight; grid on;

echo off
%==========================================================================

disp(sprintf(['=================================================================\n'...
              ' Calling library functions is also supported. Its only difference with\n'... 
              '  non-library functions is that the function declaration has to be\n'...
              '  always provided manually - because Code Composer is unable to provide \n'...
              '  sufficient information for functions that reside in a pre-compiled library.\n'...
              '  The C declaration is manually provided through the ''declare'' method.\n'...
              '  In the following example, we will create an object for the library function\n'...
              '  ''fir_filter'' and use the method ''declare'' to supply the declaration, \n'...
              '  and then run the function. Since the ''fir_filter'' declaration contains a\n'...
              '  typedef, we will also add a typedef to the cc object using the method ''add''.\n'...
              '  Any added typedef will be available as long as the cc object exists.\n'...
              '=================================================================\n\n']));

disp('--- Press any key to continue: declare, goto, execute, typedef (for functions) ---');
pause;
if ishandle(h)
close(h);
end

echo on

% Compute the low pass filter response using MATLAB functions

% Plot (blue) shows the filter response generated from MATLAB
n = 10; wb1 = 0.3; bcoeff = fir1(n,wb1);
[sco sw] = freqz(bcoeff,1); scodb = 20*log10(abs(sco));
swdb = sw./pi;
h = figure;
plot(swdb,scodb); hold on; grid on; 
title('MATLAB (blue)  vs. Target Response (red)');
xlabel('Normalized Frequency');
nfrm = 128; cscaling = 2^15;
ncoeff = length(bcoeff);

% Next, show the filter response generated from the target DSP

% create handles to filter parameters in CCS
coeff = createobj(cc,'coeff');
din   = createobj(cc,'din');
dout  = createobj(cc,'dout');

% scale input data, coeff, and load these values to the target
datain = randn(nfrm,1); glim = max([abs(max(datain)) abs(min(datain))]);
dscale = 2^15/(glim*0.99); idin = int16(dscale*datain);
write(coeff,int16(cscaling.*bcoeff));
write(din,idin);

echo off

disp(sprintf(['=================================================================\n'...
              ' After our input data has been initialized and written to the target,\n'...
              '  we are now ready to run the ''fir_filter'' function. We first create an \n'...
              '  object to it. Note: Since it is a library function, a warning will be \n',...
              '  thrown, so we need to manually supply its C function declaration.\n'...
              '  Also, since the function declaration uses typedefs, we must add ''INT16''\n'...
              '  and ''INT32'' types and their corresponding equivalent types to the \n'...
              '  TYPE class (cc.type) prior to calling ''declare''.\n'...
              '=================================================================\n\n']));

disp('--- Press any key to continue: declare, goto, execute, typedef (for functions) ---');
pause;
echo on

% Create an object for the 'fir_filter' library function in CCS

% first, add typedef information on cc's Type object (cc.type)

echo off
switch getprop(cfunc,'procsubfamily')
case 'C6x'    
echo on
add(cc.type,'INT16','short'); % add INT16 to the cc typedef list
add(cc.type,'INT32','int');   % add INT32 to the cc typedef list
echo off
case 'C54x'    
echo on
add(cc.type,'INT16','short'); % add INT16 to the cc typedef list
add(cc.type,'INT32','long');  % add INT32 to the cc typedef list
echo off
case 'C28x'
echo on
add(cc.type,'INT16','short'); % add INT16 to the cc typedef list
add(cc.type,'INT32','long');  % add INT32 to the cc typedef list
echo off
end
echo on

% display defined types
cc.type       

% create 'fir_filter' object
ff = createobj(cc,'fir_filter')  % warning is thrown because function declaration cannot be located

% supply function declaration through 'declare'
declare(ff,'decl','void fir_filter(INT16 *din, INT16 *coeff, INT16 *dout, INT32 ncoeff, INT32 nbuf )');

% 'goto','execute' <=> same as 'run'
goto(ff,'din',din.address(1), 'coeff',coeff.address(1),'dout',dout.address(1),'ncoeff',n,'nbuf',nfrm);
execute(ff);  % continue with running function, after input parameters have already been written
              % and context switching are performed using 'goto'

% read function's output data & plot
idout = read(dout);
[sout wsd]= pwelch(double(idout)); 
Sin = pwelch(double(idin));
runningsum = (sout./Sin); wplotdb = 10*log10(runningsum/1);
wsdn = wsd/pi;

% second plot (in red) shows the filter response by running the target function 'fir_filter'
plot(wsdn,wplotdb,'r');

echo off
%========================================================================
% Deleting the link: clear
disp(sprintf(['\n\n',...
	'=================================================================\n'...
	' Finally, the objects created during this tutorial have COM handles\n'...
	'  to Code Composer Studio.  Until these handles are deleted, the\n'...
	'  Code Composer Studio process remains in memory.  Exiting\n'...
	'  MATLAB will automatically remove these handles, but in some\n'...
	'  cases it is useful to manually delete them.  Use ''clear''\n'...
	'  to remove objects from the MATLAB workspace and delete any handles\n'...
	'  they contain.  ''Clear all'' will delete everything.\n'...
	'  Alternatively, to retain your MATLAB data use ''clear'' on the\n'...
	'  objects derived from ''ccsdsp'' (including all objects returned\n'...
	'  by ''createobj''). \n'...
	'  In addition, ''close'' is performed on the tutorial project to remove\n'...
	'  it from Code Composer Studio.\n'...
	'=================================================================\n\n']));

disp('--- Press any key to continue:  close, clear ---');
pause;
echo on
close(cc,projfile,'project')   % Let's clean-up Code Composer by closing the project file
echo off

if ishandle(h)
close(h);
end

% Clear all variables created by the tutorial
hiltutorialVars1 = whos;
hiltutorialVars1 = setdiff({hiltutorialVars1.name},existingVars);
len1 = length(hiltutorialVars1);
for varid1=1:len1
    clear (hiltutorialVars1{varid1});
end
clear hiltutorialVars1 len1 varid1

fprintf('\n**************** Demo complete. ****************\n\n');

catch
echo off
disp('------------------------------------------------------');

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
            'Type ''edit hiltutorial'' at the MATLAB command prompt. At the beginning \n',...
            'of the HILTUTORIAL script, increase the value of variable ''timeoutValue''.\n'],...
            errMsg,timeoutValue,method_name));
    elseif ~isempty(findstr(errMsg,errormsgforsupportedplatforms))
        disp(sprintf('\nCannot proceed with the demo, HILTUTORIAL only supports C2800, C5400 and C6000 processors.'));
    else
        disp(errMsg);
	end
    % Clear all variables created by the tutorial
	hiltutorialVars = whos;
	hiltutorialVars = setdiff({hiltutorialVars.name},existingVars);
    len = length(hiltutorialVars);
    for varid=1:len
        clear (hiltutorialVars{varid});
    end
    clear hiltutorialVars len varid
    disp(sprintf('\nExiting HILTUTORIAL demo...'))

end

warning backtrace on
warning on MATLAB:integerConversionNowRoundsInsteadOfTruncating

%==========================================================================
