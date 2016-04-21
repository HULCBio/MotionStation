%RTDXTUTORIAL Link for RTDX(tm) tutorial.
%   RTDXTUTORIAL is an example script intended to get the user started with
%   the RTDX component of the Link for Code Composer Studio®.  
%
%   A simple target DSP application is loaded and run on the target DSP,
%   and data messages are transferred via RTDX between the host application
%   (MATLAB) and the target DSP.  
%
%   The tutorial writes integers 1:10 to the target DSP.  The target DSP
%   takes the array of integers and increments it by one and writes the
%   resultant array to the host.  This action is performed 20 successive
%   times, with each iteration incrementing the previous array result by
%   one.  The 20 messages are read by the script using READMSG and READMAT,
%   employing various output formats. 
%
%   To run the RTDXTUTORIAL from MATLAB, type 'rtdxtutorial' at the command
%   prompt.
%
%   See also CCSTUTORIAL, RTDXTUTORIAL, CCSFIRDEMO, RTDXLMSDEMO, CCSINSPECT,
%            CCSDSP 

%   Copyright 2000-2004 The MathWorks, Inc.
%   $Revision: 1.28.4.4 $  $Date: 2004/04/08 20:45:34 $

echo off
existingVars = whos;
existingVars = {existingVars.name};

timeoutValue = 100;  % Value to set default CCSDSP & RTDX timeout values to - 100s

% Board and processor selection
disp(sprintf(['=================================================================\n',...
        '  The RTDXTUTORIAL is an example script intended to get the user started with the \n',...
        '  Link for RTDX.  A simple target DSP application is loaded and run on the \n',...
        '  target DSP, and data messages are transfered via RTDX between the host  \n',...
        '  application (MATLAB) and the target DSP.  The tutorial writes integers 1:10  \n',...
        '  to the target DSP.  The target DSP takes the array of integers and  \n',...
        '  increments it by 1 and writes the resultant array to the host.  This action  \n',...
        '  is performed 20 successive times, with each iteration incrementing the  \n',...
        '  previous array result by one.  The 20 messages are read using  \n',...
        '  various output formats.\n',...
        '=================================================================\n']));

disp(sprintf(['You will need to select a board and processor using the '...
    'BOARD SELECTION TOOL.\nHit any key to bring up the selection tool...']));
pause;
try
[boardNum,procNum] = boardprocsel;
drawnow;
echo on

cc = ccsdsp('boardnum',boardNum,'procnum',procNum)

timeoutValue
set(cc,'timeout',timeoutValue); % Set the CCSDSP timeout to 100s

%===========================================================================
echo off
disp('Hit any key to continue...');
pause

% Make sure selected processor is RTDX-compatible
% ========================================================================
dspinfo = info(cc);
% Processor specific files needed to run the demo
board = GetDemoProp(cc,'rtdxtutorial');

if (isempty(board.rtdxtutsim) && isempty(board.rtdxtut)) || ~isrtdxcapable(cc)
    clear cc;
    error(sprintf(['RTDXTUTORIAL does not run on the selected target.\n',...
        'Please select another processor, and re-run the tutorial.\n']));
    
elseif strcmp(dspinfo.targettype,'simulator') % simulator only
    projname = board.rtdxtutsim.projname;
    outFile = board.rtdxtutsim.loadfile;
    target_subdir = board.rtdxtutsim.dir; 
else
    projname = board.rtdxtut.projname;
    outFile = board.rtdxtut.loadfile;
    % API does not distinguish between c5402 & c5416 processors, 
    % so in order let's look at the boardname string - this workaround may not
    % work since boardname can be modified
    if any(findstr('5416',dspinfo.boardname))
        outFile = 'rtdxtutorial_5416.out';
    end
    target_subdir = board.rtdxtut.dir;
end

% GEL reset
uiwait(msgbox({'You may need to manually load the appropriate GEL file ';...
    'in CCS (e.g. c5416_dsk.gel) before continuing with the demo.'}, ...
    'Warning: Reset GEL','modal'));
drawnow;


%===========================================================================


% ======================== START OF TUTORIAL ===============================
echo on;

% Specify target directory where target files reside
% target_subdir is dependent on processor type
target_dir = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','rtdxtutorial',target_subdir)

% Go to target directory
cd(cc,target_dir);

% Display contents of target directory
dir(cc);

% make Code Composer IDE visible
visible(cc,1);

% LOAD .out file to target
outFile
echo off;
try
echo on

load(cc,outFile);

%===========================================================================
echo off
catch
echo off

    disp(sprintf(['\n-------------------------------------------------\n',...
        'Failed during loading of program file: ' outFile '\n',...
        'Error thrown: \n', regexprep([' ' lasterr], char(10), [char(10) ' ']), '\n',...
        'We will now rebuild the program file and try to load it again.\n',...
        'Hit any key to continue...\n']));
	pause
    open(cc,projname);
    setbuildopt(cc,'Compiler',board.rtdxtutsim.Cbuildopt);
    % Directing output program file to a temporary directory on your system
    setbuildopt(cc,'Linker',['-c -o"' tempdir outFile '" -x']);
    disp('Building CCS project...');
    build(cc,'all',60);
    disp('Build done.');
    try
        disp('Loading CCS program...');
        load(cc,[tempdir outFile],40);
        disp('Load done.');
    catch
        disp(sprintf(['Failed during loading of program file: ' outFile '\n',...
                'Try to build the program file and load manually, then hit any key from MATLAB to procceed ...\n']));
        pause;
    end       
end    


%===========================================================================
echo off
disp('Hit any key to continue...');
pause
echo on

% CONFIGURE channel buffers, 4 buffers of 1024 bytes each
configure(cc.rtdx,1024,4);

% OPEN write channel
open(cc.rtdx,'ichan','w');

% OPEN read channel
open(cc.rtdx,'ochan','r');

% ENABLE RTDX, and verify, for C54x 
enable(cc.rtdx);
isenabled(cc.rtdx)

%===========================================================================
echo off
disp('Hit any key to continue...');
pause
echo on

% SET global timeout value, and verify
timeout = get(cc.rtdx,'timeout')
set(cc.rtdx,'timeout', timeoutValue) % set RTDX timeout value
timeout = get(cc.rtdx,'timeout')

% test DISPLAY and DISP
cc.rtdx

% RUN target
run(cc);

%===========================================================================
echo off
pause(3)
disp('Hit any key to continue...');
pause
echo on

% ENABLE write channel
enable(cc.rtdx,'ichan');
isenabled(cc.rtdx,'ichan')

% write to target DSP
if iswritable(cc.rtdx,'ichan'),
	% writing to target...
	indata=1:10
	writemsg(cc.rtdx,'ichan', int16(indata))    
end

%===========================================================================
echo off
disp('Hit any key to continue...');
pause
echo on

% Check enable status of read channel
isenabled(cc.rtdx,'ochan')

% Query for number of available messages -- should be 0
num_of_msgs = msgcount(cc.rtdx,'ochan')

% ENABLE read channel, and verify
enable(cc.rtdx,'ochan');
isenabled(cc.rtdx,'ochan')

% give time for target DSP to process data,
% and write results to channel buffer
pause(4);

%===========================================================================
echo off
disp('Hit any key to continue...');
pause
echo on

% Query for number of available messages -- should be 20
num_of_msgs = msgcount(cc.rtdx,'ochan')

% Read one message:
outdata = readmsg(cc.rtdx,'ochan', 'int16')

% Read three messages into a cell array of three 1x10 vectors:
outdata = readmsg(cc.rtdx,'ochan', 'int16', 3)
% Look at second matrix--de-reference cell array:
outdata{1,2}

%===========================================================================
echo off
disp('Hit any key to continue...');
pause
echo on


% Read two messages into two 2x5 matrices:
outdata = readmsg(cc.rtdx,'ochan', 'int16', [2 5], 2)

% Look at both matrices by de-referencing cell array:
outdata{1,:}

% Read one message into one 10x1 column vector:
outdata = readmsg(cc.rtdx,'ochan', 'int16', [10 1])

%===========================================================================
echo off
disp('Hit any key to continue...');
pause
echo on

% READMAT
% Read into a 5x2 matrix:
outdata = readmat(cc.rtdx,'ochan','int16', [5 2])

% Query for remaining number of available messages in read channel queue...
num_of_msgs = msgcount(cc.rtdx,'ochan')

% Read into a 4x5 matrix (= two messages):
outdata = readmat(cc.rtdx,'ochan','int16', [4 5])

% Check the remaining number of available messages in read channel queue.
% Note: Count has been decremented by two.
num_of_msgs = msgcount(cc.rtdx,'ochan')

%===========================================================================
echo off
disp('Hit any key to continue...');
pause
echo on

% Read into a 10x5 matrix (= five messages):
outdata = readmat(cc.rtdx,'ochan','int16', [10 5])

% Check the remaining number of available messages in read channel queue.
% Note: Count has been decremented by five.
num_of_msgs = msgcount(cc.rtdx,'ochan')

%===========================================================================
echo off
disp('Hit any key to continue...');
pause
echo on

% FLUSH one message:
flush(cc.rtdx,'ochan',1)

% Check the remaining number of available messages in read channel queue.
% Note: Count has been decremented by one.
num_of_msgs = msgcount(cc.rtdx,'ochan')

% FLUSH all remaining messages:
flush(cc.rtdx,'ochan','all')

% Check the remaining number of available messages in read channel queue.
% Note: COUNT has been reset to zero.
num_of_msgs = msgcount(cc.rtdx,'ochan')

%===========================================================================
echo off
disp('Hit any key to continue...');
pause
echo on

% DISABLE all open channels
disable(cc.rtdx,'ALL');

if isrunning(cc),       % if the target DSP is running
    halt(cc);           %    halt the processor
end

% DISABLE RTDX
disable(cc.rtdx);

% CLOSE channels
close(cc.rtdx,'ichan');       
close(cc.rtdx,'ochan');
% or use: close(cc.rtdx,'all');

if isvisible(cc),
    visible(cc,0);
end

clear cc;   % Call destructor
echo off

% Clear all variables created by the tutorial
rtdxtutorialVars = whos;
rtdxtutorialVars = setdiff({rtdxtutorialVars.name},existingVars);
len = length(rtdxtutorialVars);
for varid=1:len
    clear (rtdxtutorialVars{varid});
end
clear rtdxtutorialVars len varid
fprintf('\n**************** Demo complete. ****************\n\n');

catch
echo off

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
		disp(sprintf(['\n%s\n\n!!! Timeout=%g seconds might not be enough time to run the method%s.\n'...
            'Type ''edit rtdxtutorial'' at the MATLAB command prompt. At the beginning \n',...
            'of the RTDXTUTORIAL script, increase the value of variable ''timeoutValue''.\n'],...
            errMsg,timeoutValue,method_name));
    elseif ~isempty(findstr(errMsg,'RTDXTUTORIAL does not run on the selected target.'))
        disp(sprintf('\nCannot proceed with the demo, the processor you selected is not RTDX-capable.'));
	else
        disp(errMsg);
	end
    % Clear all variables created by the tutorial
	rtdxtutorialVars = whos;
	rtdxtutorialVars = setdiff({rtdxtutorialVars.name},existingVars);
    len = length(rtdxtutorialVars);
    for varid=1:len
        clear (rtdxtutorialVars{varid});
    end
    clear rtdxtutorialVars len varid
    
	disp(sprintf('Exiting RTDXTUTORIAL demo...'))
    
end

% =========================== END OF TUTORIAL ================================

% [EOF] rtdxtutorial.m
