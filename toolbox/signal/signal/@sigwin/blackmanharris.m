function h = blackmanharris(varargin)
%BLACKMANHARRIS Construct a Blackman-Harris window object
%   H = SIGWIN.BLACKMANHARRIS(N) constructs a Blackman-Harris window object
%   with length N.  If N is not specified, it defaults to 64.
%
%   See also SIGWIN, SIGWIN/BARTHANNWIN, SIGWIN/BARTLETT, SIGWIN/PARZENWIN,
%   SIGWIN/RECTWIN, SIGWIN/BOHMANWIN, SIGWIN/NUTTALLWIN, SIGWIN/TRIANG.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:03 $

h = sigwin.blackmanharris(varargin{:});

% [EOF]
