function h = bohmanwin(varargin)
%BOHMANWIN Construct a Bohman window object
%   H = SIGWIN.BOHMANWIN(N) constructs a Bohman window object with length
%   N. If N is not specified, it defaults to 64.
%
%   See also SIGWIN, SIGWIN/BARTHANNWIN, SIGWIN/BARTLETT, SIGWIN/RECTWIN,
%   SIGWIN/BLACKMANHARRIS, SIGWIN/NUTTALLWIN, SIGWIN/PARZENWIN, SIGWIN/TRIANG.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:04 $

h = sigwin.bohmanwin(varargin{:});

% [EOF]
