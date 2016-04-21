function oldpath = addpath(varargin)
%ADDPATH Add directory to search path.
%   ADDPATH DIRNAME prepends the specified directory to the current
%   matlabpath.  Surround the DIRNAME in quotes if the name contains a
%   space.  If DIRNAME is a set of multiple directories separated by path
%   separators, then each of the specified directories will be added.
%
%   ADDPATH DIR1 DIR2 DIR3 ...  prepends all the specified directories to
%   the path.
%
%   ADDPATH ... -END    appends the specified directories.
%   ADDPATH ... -BEGIN  prepends the specified directories.
%   ADDPATH ... -FROZEN disables directory change detection for directories
%                       being added and thereby conserves Windows change
%                       notification resources (Windows only).
%
%   Use the functional form of ADDPATH, such as ADDPATH('dir1','dir2',...),
%   when the directory specification is stored in a string.
%
%   P = ADDPATH(...) returns the path prior to adding the specified paths.
%
%   Examples
%       addpath c:\matlab\work
%       addpath /home/user/matlab
%       addpath /home/user/matlab:/home/user/matlab/test:
%       addpath /home/user/matlab /home/user/matlab/test
%
%   See also RMPATH, PATHTOOL, PATH, SAVEPATH, GENPATH, REHASH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.29.4.3 $  $Date: 2004/01/19 02:56:18 $

% Number of  input arguments
n = nargin;
args = varargin;

if nargout>0
    oldpath = path;
end

error(nargchk(1,n,n,'struct'));

% Last input argument
last = args{end};

append = 0;
freeze = 0;

% Append or prepend to the existing path
if isequal(last,1) || strcmpi(last,'-end')
    append = 1; n = n - 1;
elseif isequal(last,0) || strcmpi(last,'-begin')
    append = 0; n = n - 1;
elseif strcmpi(last,'-frozen') && ispc
    freeze = 1; n = n - 1;
end

% Concatenate the path string
p = [];
for i=1:n
    next = varargin{i};
    if ~ischar(next)
        error('MATLAB:addpath:ArgNotString', ...
            'All arguments except the last must be strings');
    end
    % Remove leading and trailing whitespace
	next = strtrim(next);
    if ~isempty(next)
        p = [p next pathsep];
    end
end

% If p is empty then return
if isempty(p)
    return;
end

unfreeze = 0;

% See whether frozen is desired, where the state is not already set frozen
if freeze
    oldfreeze = system_dependent('DirsAddedFreeze');
    % Check whether old unfrozen state needs to be restored
    if ~isempty(strfind(oldfreeze,'unfrozen'))
        unfreeze = 1;
    end
end

% Append or prepend the new path
try
		mp = matlabpath;
    if append
        path(mp, p);
    else
        path(p, mp);
    end
catch
end

if unfreeze
    system_dependent('DirsAddedUnfreeze');
end
