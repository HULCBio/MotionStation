function varargout=ls(varargin)
%LS List directory.
%   LS displays the results of the 'ls' command on UNIX.  You can
%   pass any flags to LS as well that your operating system supports.
%   On UNIX, ls returns a \n delimited string of file names.
%
%   On all other platforms, LS executes DIR and takes at most one input
%   argument. 
%
%   See also DIR, MKDIR, RMDIR, FILEATTRIB, COPYFILE, MOVEFILE, DELETE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.17.4.3 $  $Date: 2003/11/06 15:41:53 $
%=============================================================================
% validate input parameters
if iscellstr(varargin)
    args = strcat({' '},varargin);
else
    error('Inputs must be strings.');
end

% check output arguments
if nargout > 1
    error('MATLAB:LS:TooManyOutputArguments','Too many output arguments.')
end

% perform platform specific directory listing
if isunix
    if nargin == 0
        [s,listing] = unix('ls');
    else
        [s,listing] = unix(['ls ', args{:}]);
    end
    
    if s~=0
        error('MATLAB:ls:OSError',listing);
    end
else
    if nargin == 0
        %hack to display output of dir in wide format.  dir; prints out
        %info.  d=dir does not!
        if nargout == 0
            dir;
        else
            d = dir;
            listing = char(d.name);
        end
    elseif nargin == 1
        if nargout == 0
            dir(varargin{1});
        else
            d = dir(varargin{1});
            listing = char(d.name);
        end
    else
        error('Too many input arguments.')
    end
end

% determine output mode, depending on presence of output arguments
if nargout == 0 && isunix
    disp(listing)
elseif nargout > 0
    varargout{1} = listing;
end
%=============================================================================