function nnpause(delay)
%NNPAUSE A Neural Network Design utility function.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

drawnow
start = clock;
while etime(clock,start) < delay,end
