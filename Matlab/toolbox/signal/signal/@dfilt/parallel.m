function h = parallel(varargin)
%PARALLEL Create a parallel system of discrete-time filter objects.
%   Hd = PARALLEL(Hd1, Hd2, etc) constructs a parallel system of the filter
%   objects Hd1, Hd2, etc.  The block diagram looks like:
%
%           |->  Hd1 ->|
%           |          |
%      x ---|->  Hd2 ->|--> y
%           |          |
%           |-> etc. ->|
%
%   See also DFILT.

% Copyright 1988-2002 The MathWorks, Inc.

h = dfilt.parallel(varargin{:});

% [EOF]
