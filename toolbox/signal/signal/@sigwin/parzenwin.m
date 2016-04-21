function h = parzenwin(varargin)
%PARZENWIN Construct a Parzen window object
%   H = SIGWIN.PARZENWIN(N) constructs a Parzen window object with length
%   N.  If N is not specified, it defaults to 64.
%
%   See also SIGWIN, SIGWIN/BARTHANNWIN, SIGWIN/BARTLETT, SIGWIN/RECTWIN,
%   SIGWIN/BLACKMANHARRIS, SIGWIN/BOHMANWIN, SIGWIN/NUTTALLWIN, SIGWIN/TRIANG.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:13 $

h = sigwin.parzenwin(varargin{:});

% [EOF]
