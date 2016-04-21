function h = blackman(varargin)
%BLACKMAN Construct a Blackmman window object
%   H = SIGWIN.BLACKMAN(N, S) constructs a Blackman window object with
%   length N and sampling flag S.  If N or S is not specified, they default
%   to 64 and 'symmetric' respectively.  The sampling flag can also be
%   'periodic'.
%
%   See also SIGWIN, SIGWIN/FLATTOPWIN, SIGWIN/HAMMING, SIGWIN/HANN.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:17:02 $

h = sigwin.blackman(varargin{:});

% [EOF]
