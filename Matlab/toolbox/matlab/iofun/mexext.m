function [varargout] = mexext(varargin)
%MEXEXT MEX filename extension for this platform. 
%   EXT = MEXEXT returns the file name extension for the current
%   PLATFORM. 
%
%   The following table shows the MEX filename extensions for 
%   all supported platforms:
%
%       solaris         - .mexsol
%       hpux            - .mexhpux
%       glnx86          - .mexglx
%       glnxi64         - .mexi64
%       Mac OS X        - .mexmac
%       Windows         - .dll
%
%   See also MEX, MEXDEBUG.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.3 $  $Date: 2004/03/26 13:26:31 $
%   Built-in function.

if nargout == 0
  builtin('mexext', varargin{:});
else
  [varargout{1:nargout}] = builtin('mexext', varargin{:});
end
