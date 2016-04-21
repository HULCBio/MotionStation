function goto(cc,func,timeout)
% GOTO Places the CCS cursor at the start of the function body.
%   GOTO(CC,FUNC) Locates the file where FUNC is found, opens the file in 
%   Code Composer Studio(R) and places the CCS cursor at the start of the 
%   function body. If the file is not found, it returns a warning.
%
%   GOTO(CC,FUNC,TIMEOUT) Same as above, except it accepts a time out
%   value.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.8.2.4 $  $Date: 2004/04/08 20:45:47 $

error(nargchk(1,3,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle.');
end
if nargin==2
    dtimeout = cc.timeout;
elseif nargin==3 && ( ~isnumeric(timeout) || timeout<0 )
    error('Third parameter: Timeout must be positive numeric.');
else
    dtimeout = timeout;
end
if isempty(func) || ~ischar(func),
    error('Second parameter: Function Name must be a string.');
end

% Check if func is loaded
try
    funcinfo = list(cc,'function',func);
catch
    if ~isempty(strcmp(lasterr,'GetVariable: Variable:')),
        error(['Specified function ''' func ''' cannot be found. It may not be loaded on the DSP.']);
    else
        error(lasterr);
    end
end

% Set cursor to begining of function
lname = fieldnames(funcinfo); lname = lname{1};
if ~isfield(funcinfo.(lname),'filename')
    warning(['GOTO: Unable to locate position of ''' func ''' in any source file.']);
    return;
end
if ~isfield(funcinfo.(lname),'linepos')
    warning(['GOTO: Unable to locate line position of ''' func ''' in file ' funcinfo.(lname).filename '.']);
    return;
else
    linenum = funcinfo.(lname).linepos(1);
end

% If filename(no patch) is available
try 
    % open file and set cursor to specified line
    callSwitchyard(cc.ccsversion,[64,cc.boardnum,cc.procnum,dtimeout,cc.eventwaitms],funcinfo.(lname).filename,linenum); % call switchyard
catch
    % get full filename (with path)
    [filename,pjtnum] = GetFullFilename(cc,funcinfo.(lname).filename);
	if pjtnum==0,
        warning('No project file is open, the source file cannot be located.');
    elseif isempty(filename)
        warning('The source file cannot be located.');
    else
        % open file and set cursor to specified line
        callSwitchyard(cc.ccsversion,[64,cc.boardnum,cc.procnum,dtimeout,cc.eventwaitms],filename,linenum); % call switchyard
    end
end
%----------------------------------------------
function [fullfilename,pjtnum] = GetFullFilename(cc,filename)
% Find full filename 
fullfilename = []; % default
pjtnum = 0; % default
% Get project information
prjinfo = list(cc,'project');
pjtnum = length(prjinfo);
% If no project file open - no source of path information
if pjtnum==0, 
    return;
end
% If project file(s) is/are open, find source that match filename 
% and get path
for j=1:pjtnum
	for i=1:length(prjinfo(j).srcfiles)
        [pathstr,name,ext,ver] = fileparts(prjinfo(j).srcfiles(i).name);
        if strcmpi(filename,[name,ext])
            fullfilename = prjinfo(j).srcfiles(i).name;
            break;
        end
	end
	if ~isempty(fullfilename)
        break;
	end
end

% [EOF] goto.m
