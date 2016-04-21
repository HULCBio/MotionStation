function [absolutepath]=validpath(partialpath,quoted)
%VALIDPATH: builds a full path from a partial path specification
%   [absolutepath] = VALIDPATH(partialpath,'quoted')
%
%    Input:
%       partialpath: string vector containing at least a file or directory name
%                    or a partial path ending in a file or directory name.
%                    May contain ..\  or ../ or \\ character sets.
%                    If partial path contains more than a filename or directory name
%                    it is assumed that the partial path is the full path and
%                    the current directory will not be prepended to creat a full path.
%                    Otherwise, the current directory (pwd) is prepended to create a
%                    full path. An exception is on UNIX, when the path starts in
%                    the '~' character, then the currently directory is not
%                    prepended.
%       'quoted':    string vector to indicate that we want the path double
%                    quoted
%    Return:
%       absolutepath: string vector containing full path to partial path specified.
%

%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.5 $ $Date: 2004/01/13 16:42:12 $

if ~ischar(partialpath)
   error('MATLAB:NotAString','Directory path must be a string')
end

%
% initialise variables
%
if nargin < 2
    isquoted = false; 
else
    isquoted = strcmp(quoted,'quoted');
end

%
% ensure that file separator is correct for current file system
%
if isunix
   partialpath = regexprep(partialpath,'\\',filesep);
else 
   partialpath = regexprep(partialpath,'\/',filesep);
end

%
% parse partial path into path parts
%
[pathname filename ext] = fileparts(partialpath);

%
% no path qualification is present in partial path; assume parent is pwd, except
% when path string starts with '~' or is identical to '~'.
%
if isempty(pathname) && isempty(regexp(partialpath,'^~','once'))
   ParentDir = pwd;
elseif isempty(regexp(partialpath,'(.:|\\\\)','once')) && ...
       isempty(regexp(partialpath,'^\/','once')) && ...
       isempty(regexp(partialpath,'^~','once'));
   % path did not start with any of drive name, UNC path or '~'.
   ParentDir = [pwd,filesep,pathname];
else
   % path content present in partial path; assume relative to current directory,
   % or absolute.
   ParentDir = pathname;
end

%
% wrap path in text delimiters to ensure valid path when containing space
% characters
%
if isquoted
   % unix does not handle wild card inside a quoted string
   if isunix
      % move wildcard outside quoted string
      absolutepath = ['"',fullfile(ParentDir,[strrep(filename,'*','"*"'),...
                                              strrep(ext,'*','"*"')]),'"'];
   else
      absolutepath = ['"',fullfile(ParentDir,[filename,ext]),'"'];
   end

   % place ~ outside quoted path, otherwise UNIX would not translate ~
   if strncmp(absolutepath,'"~',2)
      if length(absolutepath)>4
         [firstPathPart,remainder] = strtok(absolutepath,filesep);
         if ~isempty(remainder)
            absolutepath = [firstPathPart(2:end),'/"',remainder(2:end)];
         else
            % create unquoted path as ~username
            absolutepath = partialpath;
         end
      else
         % create unquoted path as ~ only or ~/
         absolutepath = partialpath;
      end
   end
else
    % construct absolute filename
    absolutepath = fullfile(ParentDir,[filename,ext]);
end
