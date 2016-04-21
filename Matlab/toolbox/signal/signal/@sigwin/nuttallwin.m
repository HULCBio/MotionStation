function h = nuttallwin(varargin)
%NUTTALLWIN Construct a Nuttall defined minimum 4-term Blackman-Harris window object
%   H = SIGWIN.NUTTALLWIN(N) constructs a Nuttall defined minimum 4-term
%   Blackman-Harris window object with length N.  If N is not specified, it
%   defaults to 64.
%
%   See also SIGWIN, SIGWIN/BARTHANNWIN, SIGWIN/BARTLETT, SIGWIN/RECTWIN,
%   SIGWIN/BLACKMANHARRIS, SIGWIN/BOHMANWIN, SIGWIN/PARZENWIN, SIGWIN/TRIANG.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:12 $

h = sigwin.nuttallwin(varargin{:});

% [EOF]
