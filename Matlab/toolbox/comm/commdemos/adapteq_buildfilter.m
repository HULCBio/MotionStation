function f = adapteq_buildfilter(h, P, Q);
%ADAPTEQ_BUILDFILTER  Construct pulse shaping filter (structure).
%   F = ADAPTEQ_BUILDFILTER(H, P, Q) returns a structure conatining pulse
%   shaping filter information.  H is a vector containing filter
%   coefficients, P is the upsample factor at the input (used for transmit
%   filters) and Q is the downsample factor at the output (used for receive
%   filters).

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/20 23:15:02 $

f.Coeff = h;
f.UpsampleFactor = P;
f.DownsampleFactor = Q;
f.State = zeros(1, (length(h)-1)/P);