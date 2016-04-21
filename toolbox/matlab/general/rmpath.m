function oldpath = rmpath(varargin)
%RMPATH Remove directory from search path.
%   RMPATH DIRNAME  removes the specified directory from the current
%   matlabpath.  Surround the DIRNAME in quotes if the name contains a
%   space.  If DIRNAME is a set of multiple directories separated by path
%   separators, then each of the specified directories will be removed.
%
%   RMPATH DIR1 DIR2 DIR3  removes all the specified directories from the
%   path.
%
%   Use the functional form of RMPATH, such as RMPATH('dir1','dir2',...),
%   when the directory specification is stored in a string.
%
%   P = RMPATH(...) returns the path prior to removing the specified paths.
%
%   Examples
%       rmpath c:\matlab\work
%       rmpath /home/user/matlab
%       rmpath /home/user/matlab:/home/user/matlab/test:
%       rmpath /home/user/matlab /home/user/matlab/test
%
%   See also ADDPATH, PATHTOOL, PATH, SAVEPATH, GENPATH, REHASH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.23.4.5 $  $Date: 2004/02/07 19:12:26 $

if ~all(cellfun('isclass',varargin,'char')), error('MATLAB:rmpath:ArgNotString','Arguments must be strings.'); end
fs = filesep;
ps = pathsep;

if nargout>0
    oldpath = path;
end

% Make cell array of MATLABPATH directories
cmdirs = regexp([matlabpath ps],['.[^' ps ']*' ps],'match')';

% Make inputs into one long string for ease of processing
args = regexprep(varargin, '(.)$',['$1' ps]);
dirs = [args{:}];

% Convert to clean cells
cdirs = parsedirs(dirs);

% Only do case sensitive search on UNIX
if ispc
    cdirsCased = lower(cdirs);
    cmdirsCased = lower(cmdirs);
else
    cdirsCased = cdirs;
    cmdirsCased = cmdirs;
end

% Loop through directories to find out where to remove them
pmatch = false(size(cmdirs));
for n=1:length(cdirsCased)
	pTemp = strcmp(cdirsCased{n},cmdirsCased);
    if ~any(pTemp)
        warning('MATLAB:rmpath:DirNotFound','"%s" not found in path.',cdirs{n});
	end
	pmatch = pmatch | pTemp;
end

% Remove the directories from the MATLABPATH string, and update the path
if any(pmatch)
	cmdirs(pmatch) = [];
	matlabpath([cmdirs{:}])
end



