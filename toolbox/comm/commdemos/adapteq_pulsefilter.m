function [y, f] = adapteq_pulsefilter(x, f);
% Pulse shaping filter with state handling.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/20 23:15:07 $

y = upfirdn([f.State x], f.Coeff, f.UpsampleFactor, f.DownsampleFactor);
y = y((length(f.Coeff)-1)/f.DownsampleFactor+1:end);
f.State = x(end-length(f.State)+1:end);
