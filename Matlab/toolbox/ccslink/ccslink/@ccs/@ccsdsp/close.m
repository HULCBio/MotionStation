function close(cc,filename,filetype)
%CLOSE  Close file(s) in Code Composer Studio(R)
%   CLOSE(CC,FILENAME,FILETYPE) closes the specified file
%   in Code Composer.  FILETYPE defines the type of file
%   to close. FILENAME must match the name of the file that
%   is to be closed.  If the FILENAME is parameter is 
%   specified as 'all', every open file of the defined type
%   is closed.  A null filename input (i.e. []) will close the
%   currently active (or in focus) file.
%
%   CLOSE(CC,'all','project')  - Closes all project files
%   CLOSE(CC,'my.pjt','project') - Closes the project: my.pjt
%   CLOSE(CC,[],'project')  - Closes the active project
%
%   CLOSE(CC,'all','text')  - Close all text files.
%   CLOSE(CC,'text.cpp','text') - Closes the text file: text.cpp
%   CLOSE(CC,[],'text')  - Closes the active project
%
%   Note - by default, CLOSE does not save the file before
%   closing it.  Thus, any changes since the save operation 
%   will be lost.  Use SAVE to ensure changes are preserved.
%
%   See also ADD, OPEN, CD, SAVE. 

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.7.4.3 $ $Date: 2004/04/01 16:02:12 $

error(nargchk(2,3,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a CCSDSP Handle');
end

[fpath,fname,fext] = fileparts(filename);
if nargin <= 2,
    if strcmpi(fext,'.pjt')
        filetype = 'project';
    elseif strcmpi(fext,'.wks')
        filetype = 'workspace'; % not supported
    else
        filetype = 'text';       % Default
    end
end

if ~isempty(filename) & ~strcmpi(filename,'all'),
    try 
       filename = cc.fileparamparser(filename);
    catch
        if strcmpi(filetype,'unloadgel')
            error(generateccsmsgid('FileNotFound'),lasterr);
        % else, try anyway
        end
     end
end

if strcmpi(filetype,'project'),
    IsPrjOpen = IsOpen(cc,fname);
    if IsPrjOpen
        callSwitchyard(cc.ccsversion,[41,cc.boardnum,cc.procnum,0,0],filename);
    else
        warning(generateccsmsgid('ProjectNotOpen'),['The specified project is not open, no action taken.']);
    end
elseif strcmpi(filetype,'text'),
    callSwitchyard(cc.ccsversion,[42,cc.boardnum,cc.procnum,0,0],filename);
elseif strcmpi(filetype,'unloadgel'),
    if strcmpi(filename,'all') || isempty(filename)
        error(generateccsmsgid('OptionNotSupported'),'You must specify the GEL file to unload.');
    end    
    % Gel function only accepts // or \\ file separation string
    filename = strrep(filename,'/','//');
    filename = strrep(filename,'\','\\');
    % Load GEL file
    try
        cexpr(cc,['GEL_UnloadGel("' filename '")']);
    catch
        error(generateccsmsgid('LoadGelProblem'),sprintf('Problem removing GEL file ''%s'':\n%s',filename,lasterr));
    end
else
    error(generateccsmsgid('InvalidInput'),'The only supported FILETYPE options are ''project'' and ''text''');
end

%____________________________________________________
function res = IsOpen(cc,filename)
if isempty(filename) || strcmpi(filename,'all')
    res = 1; % taken care of in the switchyard
    return
end
% otherwise
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

% [EOF] close.m