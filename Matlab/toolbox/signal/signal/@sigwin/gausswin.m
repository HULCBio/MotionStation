function h = gausswin(varargin)
%GAUSSWIN Construct a Gaussian object
%   H = SIGWIN.GAUSSWIN(N, A) constructs a Gaussian window object with
%   length N and Alpha A.  If N or A is not specified, they default to 64
%   and 2.5 respectively.
%
%   See also SIGWIN, SIGWIN/CHEBWIN, SIGWIN/KAISER, SIGWIN/TUKEYWIN.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:07 $

h = sigwin.gausswin(varargin{:});

% [EOF]
