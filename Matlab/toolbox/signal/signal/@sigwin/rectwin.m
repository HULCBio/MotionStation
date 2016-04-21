function h = rectwin(varargin)
%RECTWIN Construct a Rectangular window object
%   H = SIGWIN.RECTWIN(N) constructs a Rectangular window object with length
%   N.  If N is not specified, it defaults to 64.
%
%   See also SIGWIN, SIGWIN/BARTHANNWIN, SIGWIN/BARTLETT, SIGWIN/PARZENWIN,
%   SIGWIN/BLACKMANHARRIS, SIGWIN/BOHMANWIN, SIGWIN/NUTTALLWIN, SIGWIN/TRIANG.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:14 $

h = sigwin.rectwin(varargin{:});

% [EOF]
