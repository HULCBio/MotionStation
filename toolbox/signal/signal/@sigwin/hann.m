function h = hann(varargin)
%HANN Construct a Hann window object
%   H = SIGWIN.HANN(N, S) constructs a Hann window object with length N and
%   sampling flag S.  If N or S is not specified, they default to 64 and
%   'symmetric' respectively.  The sampling flag can also be 'periodic'.
%
%   See also SIGWIN, SIGWIN/BLACKMAN, SIGWIN/FLATTOPWIN, SIGWIN/HAMMING.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:10 $

h = sigwin.hann(varargin{:});

% [EOF]
