function h = flattopwin(varargin)
%FLATTOPWIN Construct a Flat Top window object
%   H = SIGWIN.FLATTOPWIN(N, S) constructs a Flat Top window object with length N
%   and sampling flag S.  If N or S is not specified, they default to 64 and
%   'symmetric' respectively.  The sampling flag can also be 'periodic'.
%
%   See also SIGWIN, SIGWIN/BLACKMAN, SIGWIN/HAMMING, SIGWIN/HANN.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:06 $

h = sigwin.flattopwin(varargin{:});

% [EOF]
