function h = chebwin(varargin)
%CHEBWIN Construct a Chebyshev object
%   H = SIGWIN.CHEBWIN(N, S) constructs a Chebyshev window object with
%   length N and sidelobe attenuation S.  If N or S is not specified, they
%   default to 64 and 100 respectively.
%
%   See also SIGWIN, SIGWIN/GAUSSWIN, SIGWIN/KAISER, SIGWIN/TUKEYWIN.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:05 $

h = sigwin.chebwin(varargin{:});

% [EOF]
