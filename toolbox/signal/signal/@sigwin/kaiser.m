function h = kaiser(varargin)
%KAISER Construct a Kaiser object
%   H = SIGWIN.KAISER(N, B) constructs a Kaiser window object with length N
%   and Beta B.  If N or B is not specified, they default to 64 and .5
%   respectively.
%
%   See also SIGWIN, SIGWIN/CHEBWIN, SIGWIN/GAUSSWIN, SIGWIN/TUKEYWIN.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:11 $

h = sigwin.kaiser(varargin{:});

% [EOF]
