% function out = cos_tr(freq,mag,tinc,lastt)
%
%   Generates a VARYING matrix containing a cosine signal:
%     FREQ  - frequency (radians/second)
%     MAG   - magnitude of cosine signal
%     TINC  - time increment
%     LASTT - final time (note the signal starts at time t=0)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = cos_tr(freq,mag,tinc,lastt)

 if nargin < 4
   disp('usage: out = cos_tr(freq,mag,tinc,lastt)')
   return
 end

 tvec = 0:tinc:lastt;
 y = mag*cos(freq*tvec);
%out = [ [y.' tvec.'] ; max(size(y)) inf];
 out = vpck(y.',tvec.');
%
%