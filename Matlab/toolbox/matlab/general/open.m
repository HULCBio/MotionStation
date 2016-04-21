function out = open(name)
%OPEN	 Open files by extension.
%   OPEN NAME where NAME must contain a string, does different things
%   depending on the type of the object named by that string:
%
%   Type         Action
%   ----         ------
%   variable      open named array in Array Editor
%   .mat  file    open MAT file; store variables in a structure in the workspace
%   .fig  file    open figure in Handle Graphics
%   .m    file    open M-file in M-file Editor
%   .mdl  file    open model in Simulink
%   .html file    open HTML document in Help Browser
%   .p    file    if NAME resolves to a P-file and NAME did not end with a .p
%                 extension, attempts to open matching M-file; if NAME did end
%                 with a .p extension displays an error 
%                   
%   OPEN works similar to LOAD in the way it searches for files.
%
%     If NAME exists on MATLAB path, open file returned by WHICH.
%
%     If NAME exists on file system, open file named NAME.
%
%   Examples:
%
%     open('f2')                First looks for a variable named f2, and then 
%                               looks on the path for a file named f2.mdl or 
%                               f2.m.  Error if it can't find any of these.
%
%     open('f2.mat')            Error if f2.mat is not on path.
%
%     open('d:\temp\data.mat')  Error if data.mat is not in d:\temp.
%
%
%   OPEN is user-extensible.  To open a file with the extension ".XXX",
%   OPEN calls the helper function OPENXXX, that is, a function
%   named 'OPEN', with the file extension appended.
%
%   For example,
%      open('foo.m')       calls openm('foo.m')
%      open foo.m          calls openm('foo.m')
%      open myfigure.fig   calls openfig('myfigure.fig')
%
%   You can create your own OPENXXX functions to set up handlers 
%   for new file types.  OPEN will call whatever OPENXXX function 
%   it finds on the path.
%
%   See also SAVEAS, WHICH, LOAD, UIOPEN, UILOAD, FILEFORMATS, PATH.
%

%   Chris Portal 1-23-98
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.35.4.4 $  $Date: 2004/04/10 23:26:06 $

error(nargchk(1,1,nargin));

[m n]=size(name);

if iscell(name) | ~ischar(name) | m~=1,
    error('NAME must contain a single string.');
end

% In WHICH, files take precedence over variables, but we want
% variables to take precedence in OPEN.  This forces an EXIST
% check on the variable name before we do anything else.
exist_var = evalin('caller', ...
                        ['exist(''' strrep(name, '''','''''') ''', ''var'')']);

% If we found a variable that matches, use that.  Open the variable, and
% get out.
if exist_var == 1
    evalin('caller', ['openvar(''' name ''', ' name ');']);
    return;
end

% We did not find a variable match.  Use files.
fullpath = which(name);
% Find fully qualified paths or files without extensions.
if isempty(fullpath) & exist(name) == 2
  fullpath = name;
end

if isempty(fullpath)
    % which did not find it and exist didn't find it either
    error('File ''%s'' not found.',name)
end

% get the path and ext
path=fileparts(fullpath);

%check if user specified extension
if isempty(findstr(name, '.'))
    % if file and file.m both exist, use file instead of file.m.
    dir_result = feval('dir', name);
    % If we found a file, edit it
    if ~isempty(dir_result)
      fullpath = fullfile(path, dir_result.name);
    end;
end;


if isempty(path)
    % handle special cases for variables and built-ins
    switch fullpath
     case xlate('built-in')
      error('Can''t open the built-in function ''%s''.',name);
     otherwise
      error(['Internal error: unrecognized result from WHICH: ' fullpath])
    end
else
    % let finfo decide the filetype
    [fileType, openAction] = finfo(fullpath);
    if isempty(openAction)
        openAction = 'openother';
     % edit.m no longer opens p files, so we want to check
     % if the user specified the .p or if it was added through which.
     % If the user did not specify .p, strip it off before calling openp.
     elseif strcmp(openAction, 'openp')
        [dummypath,dummyname,ext,dummyver] = fileparts(name);
        if strcmp(ext, '.p') == 0
           fullpath = fullpath(1:end-2);
        end
    end
    
    try
        % if opening a mat file be sure to fetch output args
        if isequal(openAction, 'openmat') | nargout
            out = feval(openAction,fullpath);
        else
            feval(openAction,fullpath);
        end
    catch
        % we only want the message from lasterr, not the stack trace
        le = lasterr;
        euIndex = findstr(le, sprintf('Error using ==>'));
        if ~isempty(euIndex)
            le = le(euIndex(end):end);
            nlIndex = findstr(le,sprintf('\n'));
            if ~isempty(nlIndex)
                le = le(nlIndex(1) + 1 : end);
                while ~isempty(le) & length(le) > 1 & strcmp(le(end), sprintf('\n'))
                    le = le(1:end - 1);
                end
            end
        end
        error(le);
    end
end 
