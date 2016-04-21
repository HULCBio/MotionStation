function h = triang(varargin)
%TRIANG Construct a Triangular window object
%   H = SIGWIN.TRIANG(N) constructs a Triangular window object with length
%   N.  If N is not specified, it defaults to 64.
%
%   See also SIGWIN, SIGWIN/BARTHANNWIN, SIGWIN/BARTLETT, SIGWIN/PARZENWIN,
%   SIGWIN/BLACKMANHARRIS, SIGWIN/BOHMANWIN, SIGWIN/NUTTALLWIN, SIGWIN/RECTWIN.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:15 $

h = sigwin.triang(varargin{:});

% [EOF]
