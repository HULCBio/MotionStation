function open(cc,filename,filetype,timeout)
%OPEN Loads a file into the Code Composer Studio(R) IDE.
%   OPEN(CC,FILENAME,FILETYPE,TIMEOUT) loads the specified FILENAME.
%   This file may include a full path description or just the name 
%   of the file if it resides in the Code Composer Studio working
%   directory.  Use the CC.CD method to view and modify the Code 
%   Composer working directory.  The FILETYPE parameter can override 
%   the default file extension definition. The following FILETYPE 
%   options are supported by this parameter:
%
%   'Text'      - Text file
%   'Workspace' - Code Composer workspace files
%   'Program'   - Target program file (executable)
%   'Project'   - Code Composer project files
%      
%   TIMEOUT defines an upper limit on the period this routine will wait
%   for completion of the specified file load.  If this period is 
%   exceeded, the routine will return immediately with a timeout error.
%   The action (open) may still occur for insufficient TIMEOUT values.
%   A timeout does not undo the 'open', it simply suspends waiting for
%   a confirmation.
%
%   OPEN(CC,FILENAME,FILETYPE) same as above, except the timeout is
%   replaced by the default timeout parameter from the CC object.
%
%   OPEN(CC,FILENAME)     or
%   OPEN(CC,FILENAME,[])  or
%   OPEN(CC,FILENAME,[],TIMEOUT) - same as above, except the file type
%   is derived from the file extension associated with the specified 
%   FILENAME.  File extensions are interpreted as follows:
%
%   .wks - Code Composer workspace file
%   .out - Target program file (executable)
%   .pjt - Code Composer project file
%   (default) all other file extensions will be treated as text files.
%
%   Note, the program files (.out) and project files (.pjt) are always
%   directed to the target DSP processor referenced by the CC object.  
%   However, workspace files are actively coupled to a specific target
%   DSP.  Consequently, the CC.OPEN method will load a workspace file 
%   in the Target processor that was active during the creation of the 
%   workspace file, which may NOT be the DSP processor referenced
%   by the CC object. 
%
%   See also CD, DIR, LOAD.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.20.4.5 $  $Date: 2004/04/06 01:04:50 $

try 
    error(nargchk(2,4,nargin));
    p_errorif_ccarray(cc);

	if ~ishandle(cc),
        error('First Parameter must be a CCSDSP Handle.');
	end
catch
    if strcmpi(pwd,[matlabroot '\toolbox\ccslink\ccslink\@ccs\@ccsdsp']) && ischar(cc),
        edit(cc);
        return;
    else
        error(lasterr);
    end
end

ofile = cc.fileparamparser(filename);

[fpath,fname,fext] = fileparts(filename);
if nargin <= 2,
    if strcmpi(fext,'.wks')
        filetype = 'workspace';
    elseif strcmpi(fext,'.out')
        filetype = 'program';
    elseif strcmpi(fext,'.pjt')
        filetype = 'project';
    else
        filetype = 'text';       % Default
    end
end

% hack for opening program files from BAT (where string starts with
% \\bat-toaster\...
if strcmpi(filetype,'program')
    if strcmpi(ofile(1:2),'\\') 
        ofile = ['\' ofile];
    elseif strcmpi(ofile(1:2),'//') 
        ofile = ['/' ofile];
    end
end

% Parse timeout
if( nargin >= 4) & (~isempty(timeout)),
    if ~isnumeric(timeout) | length(timeout) ~= 1,
        error(generateccsmsgid('InvalidInput'),'TIMEOUT parameter must be a single numeric value.');
    end
    dtimeout = double(timeout);
else
    dtimeout = double(get(cc,'timeout'));
end
if( dtimeout < 0)
    error(generateccsmsgid('InvalidInput'),['Negative TIMEOUT value "' num2str(dtimeout) '" not permitted.']);
end

if ~ischar(filetype),
    error(generateccsmsgid('InvalidInput'),'File type parameter should be a char array.');
end

try
    switch lower(filetype)
    case 'workspace',
        callSwitchyard(cc.ccsversion,[4 cc.boardnum cc.procnum dtimeout cc.eventwaitms],ofile);
    case 'project',
        IsPrjOpen = IsOpen(cc,fname);
        if ~(IsPrjOpen) 
            callSwitchyard(cc.ccsversion,[5 cc.boardnum cc.procnum dtimeout cc.eventwaitms],ofile);
        else 
            warning(['The specified project already exists in the collection.']);
        end
    case 'program',
        focusstate = p_getCmdWndFocus;
        callSwitchyard(cc.ccsversion,[6 cc.boardnum cc.procnum dtimeout cc.eventwaitms],ofile);
        p_grabCmdWndFocus(focusstate);
    case 'text',
        focusstate = p_getCmdWndFocus;
        try
            lasterr('');
            callSwitchyard(cc.ccsversion,[30 cc.boardnum cc.procnum dtimeout cc.eventwaitms],ofile);
        catch 
            disp(lasterr);
            if strcmpi(ofile(1:2),'\\') || strcmpi(ofile(1:2),'//')
                disp(fprintf(['unable to open file names which starts with ''//'' or ''\\'',\n'...
                        'please map to a network drive first.']));
            end
        end
        p_grabCmdWndFocus(focusstate);
    case 'loadgel',
        % Gel function only accepts // or \\ file separation string
        ofile = strrep(ofile,'/','//');
        ofile = strrep(ofile,'\','\\');
        % Load GEL file
        try
            cexpr(cc,['GEL_LoadGel("' ofile '")'],dtimeout);
        catch
            error(generateccsmsgid('LoadGelProblem'),sprintf('Problem loading GEL file ''%s'':\n%s',ofile,lasterr));
        end
    otherwise
        error(generateccsmsgid('InvalidInput'),['FILETYPE ''' filetype ''' not recognized (expecting: ''workspace'',''project'' or ''program'').']);
    end
catch
    if ~cc.isvisible,
        cc.visible(1);
    end
    error(lasterr);
end

%____________________________________________________
function res = IsOpen(cc,filename)
Isopen = 0;
projs = list(cc,'project');
for k = 1:length(projs)
    [fpathN,fnameN,fextN] = fileparts(projs(k).name);
    if strcmp(filename,fnameN)
        Isopen(k) = 1;
    else
        Isopen(k) = 0;
    end
end
res = any(Isopen);

% [EOF] open.m
