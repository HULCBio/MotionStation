function [t,f,w,F] = tffunc(amp,freq)
%TFFUNC time and frequency domain versions of a cosine modulated Gaussian pulse.
%   For use in Signal demo 2.

%   Author: L. Shure
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:18:20 $

sigma = 1;
t = -1:.01:1;
f = amp*cos(2*pi*freq*t).*exp(-pi*(sigma*t).^2);
w = -8:.1:8;
F = 2*sigma*amp*(exp(-pi*((w-freq)/sigma).^2)+exp(-pi*((w+freq)/sigma).^2));
