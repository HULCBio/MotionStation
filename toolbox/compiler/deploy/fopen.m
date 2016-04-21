function [varargout] = fopen(varargin)
%FOPEN Compiler-only verison, which looks in the CTF archive first
%  If a file has been added to the CTF archive using -a, and a 
%  file of the same name exists in the current directory, open the
%  one in the CTF archive.

% If there was at least one argument, assume it was the filename to open,
% and look (using WHICH, which ignores the current directory) for the 
% file on the application's path. If WHICH finds the file, it must be in
% the CTF archive, because the path is restricted to the CTF archive.
% (Users who use addpath do so at their own risk.)

if (nargin > 0 && ischar(varargin{1}) && ~strcmp(varargin{1}, 'all'))
    fname = which(varargin{1});
    if (~isempty(fname))
        varargin{1} = fname;
    end
end

% Call the FOPEN builtin function
if nargout == 0
    builtin('fopen', varargin{:});
else
    [varargout{1:nargout}] = builtin('fopen', varargin{:});
end

