function varargout = path2rc(varargin)
%PATH2RC Save the current MATLAB path in the pathdef.m file.
%   PATH2RC is deprecated and has been renamed to SAVEPATH.  PATH2RC still
%   works but may be removed in the future.  Use SAVEPATH instead.
%
%   See also SAVEPATH.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.23.4.3 $

warning('MATLAB:PATH2RC:DeprecatedFunction', ...
    ['PATH2RC is deprecated and may be removed in a future release. ' ...
     'Use SAVEPATH instead.']);

if nargout
    [varargout{1:nargout}] = feval(@savepath,varargin{:});
else
    feval(@savepath,varargin{:});
end