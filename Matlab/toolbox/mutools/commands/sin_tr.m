% function out = sin_tr(freq,mag,tinc,lastt)
%
%   Generates a VARYING matrix containing a sine signal:
%     FREQ  - frequency (radians/second)
%     MAG   - magnitude of sine signal
%     TINC  - time increment
%     LASTT - final time (note the signal starts at time t=0)
%
%   See also: COS_TR, SIGGEN, and STEP_TR.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = sin_tr(freq,mag,tinc,lastt)

 if nargin < 4
   disp('usage: out = sin_tr(freq,mag,tinc,lastt)')
   return
 end

 tvec = 0:tinc:lastt;
 y = mag*sin(freq*tvec);
 out = vpck(y.',tvec.');
%
%