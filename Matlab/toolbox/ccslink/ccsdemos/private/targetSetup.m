function [cc,dspname,bkPts] = targetSetup(exname,cc)
% This function sets up the link to Code Composer Studio for CCSDEBUGDEMO.
% It loads the appropriate CCS project, downloads program to the DSP
% target, and sets breakpoints. 

%   Copyright 2004 The MathWorks, Inc.

error(nargchk(2,2,nargin));

disp('Setting up CCS and target DSP...');

if isempty(cc)
    
    % Choose DSP target
    [bdnum,pcnum] = boardprocsel;
    drawnow;
    if isempty(bdnum) || isempty(pcnum)
        disp('You did not choose a valid target. Exiting demo...');
        return;
    end
    
    % Create CCSDSP handle
    cc = ccsdsp('boardnum',bdnum,'procnum',pcnum);  % Check boardnum via ccsboardinfo
    
end

% Reset DSP

reset(cc);

% Set cc time out

cc.timeout = 60;

% Make CCS visible

visible(cc,1);

% Get/set other demo info

ccinfo = info(cc);
origdir = cd;
[demopath,srcpath] = ccsdebugdemo_getpath(cc,exname); 
cd(cc,demopath);
dspname = ccinfo.boardname;

p_RemoveFilterPjtInCCS(cc);

% Open appropriate CCS files

open (cc,'FilterFFT.pjt', 'project');
disp('Downloading application to target...')
load(cc,'FilterFFT.out',30);
activate(cc,'FilterFFT.pjt', 'project');        
cd(cc,srcpath);
open(cc,'FilterFFT.c', 'text');
activate(cc,'FilterFFT.c', 'text');
cd(cc,demopath);

% Set breakpoints

if nargout==3,
    % Set breakpoints after signal generation, after filter call
    % and after spectrum computation
    bkPts = [48 50 52];
    for k = 1:length(bkPts),
        insert(cc,'FilterFFT.c',bkPts(k),'break');
    end
end

%-----------------------------------
function p_RemoveFilterPjtInCCS(cc)
% Close FilterFFT.pjt if it exists in CCS 
% - CCS does not close project if a similarly named project is in the IDE
warnstate = warning('off');
pjtlist = list(cc,'project');
for i=1:length(pjtlist)
    if ~isempty( findstr(pjtlist(i).name,'\FilterFFT.pjt') )
        close(cc,pjtlist(i).name,'project');
    end
end
warning(warnstate);

% [eof] targetSetup.m
