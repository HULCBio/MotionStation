% add_disk
%
%   Plots the unit disk (in the complex plane) on top
%   of any existing plot. This is useful when looking
%   at Nyquist plots. Currently, after running ADD_DISK
%   the graphics window status is HOLD OFF.
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

  hold
  plot(exp(sqrt(-1)*linspace(0,2*pi,400)))
  hold off
%
%