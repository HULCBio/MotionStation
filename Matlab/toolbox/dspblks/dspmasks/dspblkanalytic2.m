function b = dspblkanalytic2(action,N)
% DSPBLKANALYTIC2 Signal Processing Blockset Analytic Signal block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:06:00 $

switch action
case 'design'
 if isnan(N) | isinf(N),
   error('NaN or Inf not allowed for filter order.');
 end
 if ~isequal(floor(N), N),
   error('Filter order must be an integer value.');
 end
 if N < 1,
   error('Filter order must be positive.');
 end
 b=remez(N, [0.05 0.95], [1 1], 1, 'Hilbert');
end
