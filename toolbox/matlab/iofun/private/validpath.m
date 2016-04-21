function [filename, isExcelFile]=validpath(filename,ext0)
% VALIDPATH: builds a full path from a partial path specification
% [filename] = VALIDPATH(filename,ext0)
% [filename, isExcelFile] = VALIDPATH(filename,ext0)
%
% INPUT PARAMETERS:
% filename: string vector containing a partial path ending in a file or
%           directory name. May contain ..\  or ../ or \\ character sets. If
%           FILENAME contains more than a file name or directory name the
%           current directory will not be prepended to creat a full path.
%           Otherwise, the current directory (pwd) is prepended to create a 
%           full path. An exception is on UNIX, when the path starts in the '~'
%           character, then the currently directory is not prepended.
% ext0:     string vector specifying the default extention to be used.
%
% RETURN PARAMETERS:
% filename: string vector containing full path to a file.
% isExcelFile: Boolean set to true if file is in Excel file format.

%  JP Barnard
%  Copyright 1984-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ 
%==============================================================================

% break partial path in to file path parts.
[Directory,file,ext]=fileparts(filename);

% add default extension
if isempty(ext) && ~isempty(ext0) 
    ext = ext0;
end
% rebuild partial path
file = fullfile(Directory,[file ext]);
% search source file on M path
FileOnPath = which(file);              
if isempty(FileOnPath)
    % construct full path to source file
    filename = abspath(file);
    if isempty(dir(filename)) && ~isdir(filename)
        % file does not exist. Terminate importation of file.
        error('MATLAB:xlsread:FileNotFound','File %s not found.',filename);
    end
else filename = FileOnPath;
end 

isExcelFile = true;
% check that it is in excel format
try
    biffvector = biffread(filename);
catch
     % find out which m file called vaildpath
     st = dbstack;
     % do not want xlsfinfo to error
     if ~strcmpi(st(2).name, 'xlsfinfo')
        % generate error based on calling file (xlsread or xlswrite) and file name
     error(sprintf('MATLAB:%s:FileFormat', name), 'File %s not in Microsoft Excel Format.', filename);
     end
     isExcelFile = false;
end

%==============================================================================
function absolutepath=abspath(partialpath)

% parse partial path into path parts
[pathname filename ext] = fileparts(partialpath); 
% no path qualification is present in partial path; assume parent is pwd, except
% when path string starts with '~' or is identical to '~'.
if isempty(pathname) && isempty(strmatch('~',partialpath))
   Directory = pwd;
elseif isempty(regexp(partialpath,'(.:|\\\\)')) && ...
       isempty(strmatch('/',partialpath)) && ...
       isempty(strmatch('~',partialpath));
   % path did not start with any of drive name, UNC path or '~'.
   Directory = [pwd,filesep,pathname];
else
   % path content present in partial path; assume relative to current directory,
   % or absolute.
   Directory = pathname;
end

% construct absulute filename
absolutepath = fullfile(Directory,[filename,ext]);
%--------------------------------------------------------------------------
