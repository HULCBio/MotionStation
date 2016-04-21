function h = tukeywin(varargin)
%TUKEYWIN Construct a Tukey object
%   H = SIGWIN.TUKEYWIN(N, A) constructs a Tukey window object with length
%   N and Alpha A.  If N or A is not specified, they default to 64 and .5
%   respectively.
%
%   See also SIGWIN, SIGWIN/CHEBWIN, SIGWIN/GAUSSWIN, SIGWIN/KAISER.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:16 $

h = sigwin.tukeywin(varargin{:});

% [EOF]
