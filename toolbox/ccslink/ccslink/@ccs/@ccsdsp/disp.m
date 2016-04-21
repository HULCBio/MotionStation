function disp(cc)
%DISP Display properties of Link to Code Composer Studio(R) IDE.
%   DISPLAY(CC) displays a formatted list of values that describe 
%   the CC object.  
%   Note: CC can be a single CCSDSP handle or vector of CCSDSP handles.
%
%   Example 1: disp output if CC is a single CCSDSP handle
% 	CCSDSP Object:
%       API version      : 1.2
%       Processor type   : TMS320C5500
%       Processor name   : CPU
%       Running?         : No
%       Board number     : 0
%       Processor number : 0
%       Default timeout  : 10.00 secs
% 	
%       RTDX channels    : 0
%    
%   Example 2: disp output if CC is an array of CCSDSP handles
%
% 	Array of CCSDSP Objects:
%       API version              : 1.2
%       Board name               : OMAP 3.0 Platform Simulator [Texas Instruments]
%       Board number             : 3
%       Processor 0  (element 1) : TMS470R2127 (MPU, Not Running)
%       Processor 1  (element 2) : TMS320C5500 (DSP, Not Running)
%
%   See also DISPLAY.

% Copyright 2000-2003 The MathWorks, Inc.
% $Revision: 1.12.4.3 $ $Date: 2004/04/08 20:45:45 $

try
    icc = cc.info;
catch
    error('DISP - API Failure, unable to query Code Composer(R) state');
end

if length(cc) == 1
    displayOneProc(cc,icc);
else
    displayMultiProc(cc,icc);
end

%--------------------------------------------------------------------------
function displayMultiProc(cc,icc)

for k = 1:length(cc)
    if cc(k).isrunning,
        statestr{k} = 'Running';
    else
        statestr{k} = 'Not Running';
    end
            
    if icc(k).family == 470 %OMAP ARM Rxx
        ProcFormat = 'TMS%03dR%1s';
    else 
        ProcFormat = 'TMS%03dC%2s'; 
    end
    ProcType{k} = getproctype(ProcFormat,icc(k));
end

fprintf('Array of CCSDSP Objects:\n');
fprintf('  API version              : %d.%d\n',cc(1).apiversion(1),cc(1).apiversion(2));
fprintf('  Board name               : %s\n',icc(1).boardname);
fprintf('  Board number             : %d\n',double(cc(1).boardnum));
for k = 1:length(cc)
    fprintf(['  Processor ' num2str(cc(k).procnum) '  (element %s) : %s (%s, %s)\n'],...
        num2str(k),ProcType{k},icc(k).procname,statestr{k});
end
fprintf('\n');

%--------------------------------------------------------------------------
function displayOneProc(cc,icc)
if cc.isrunning,
    statestr = 'Yes';
else
    statestr = 'No';
end

if icc.family == 470 %OMAP ARM Rxx
    ProcFormat = 'TMS%03dR%1s';
else
    ProcFormat = 'TMS%03dC%2s'; 
end
ProcType = getproctype(ProcFormat,icc);

fprintf('CCSDSP Object:\n');
fprintf('  API version      : %d.%d\n',cc.apiversion(1),cc.apiversion(2));
fprintf('  Processor type   : %s\n',ProcType);
fprintf('  Processor name   : %s\n',icc.procname);
fprintf('  Running?         : %s\n',statestr);
fprintf('  Board number     : %d\n',double(cc.boardnum));
fprintf('  Processor number : %d\n',double(cc.procnum));
fprintf('  Default timeout  : %.2f secs\n',cc.timeout);
fprintf('\n');
if cc.isrtdxcapable,
    disp(cc.rtdx)
end 

%-------------------------------------
function ProcType = getproctype(ProcType,icc) 

ProcType = sprintf(ProcType,icc.family,dec2hex(icc.subfamily));
try
    if icc.revfamily>=0 && icc.revfamily<=99 
        ProcType = sprintf('%s%02d', ProcType,icc.revfamily); 
    elseif icc.revfamily>=100 && icc.revfamily<=109 
        ProcType = [ProcType dec2hex(icc.revfamily-100) 'x']; 
    elseif icc.revfamily>=110 && icc.revfamily<=119 
        ProcType = [ProcType 'x' dec2hex(icc.revfamily-110)]; 
    elseif icc.revfamily==127
        ProcType = [ProcType 'xx']; 
    else
        % If a fluke occurs and refamuly is not in the above range, we
        % default to the old implementation
        ProcType = sprintf('%s%02d', ProcType,icc.revfamily); 
    end
catch
    % If a problem occurs in the above implementation, we default to the
    % old implementation
    ProcType = sprintf('%s%02d', ProcType,icc.revfamily); 
end

% [EOF] disp.m