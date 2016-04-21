function pause2(n)
%PAUSE2 Pause procedure for specified time.
%  
%  PAUSE2(N)
%    N - number of seconds (may be fractional).
%  Stops procedure for N seconds.
%  
%  PAUSE2 differs from PAUSE in that pauses may take a fractional
%    number of seconds. PAUSE(1.2) will halt a procedure for 1 second.
%    PAUSE2(1.2) will halt a procedure for 1.2 seconds.

% Mark Beale, 1-31-92
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:17:21 $

if nargin ~= 1
  error('Wrong number of input arguments.');
end

drawnow
t1 = clock;
while etime(clock,t1) < n,end;
