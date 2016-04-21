function x = ecg(L)
%ECG Electrocardiogram (ECG) signal generator.
%   ECG(L) generates a piecewise linear ECG signal of length L.
%   The ECG signal must be filtered (smoothed) with an N-point 
%   smoother e.g., Savitzky-Golay FIR filter. 
%
%   EXAMPLE:
%   x = ecg(500).';
%   y = sgolayfilt(x,0,3); % Typical values are: d=0 and F=3,5,9, etc. 
%   y5 = sgolayfilt(x,0,5); 
%   y15 = sgolayfilt(x,0,15); 
%   plot(1:length(x),[x y y5 y15]);
%
%   See also SGOLAYFILT, SGOLAYDEMO, ADAPTNCDEMO.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/27 19:09:30 $

a0 = [0,1,40,1,0,-34,118,-99,0,2,21,2,0,0,0]; % Template
d0 = [0,27,59,91,131,141,163,185,195,275,307,339,357,390,440];
a = a0 / max(a0);
d = round(d0 * L / d0(15)); % Scale them to fit in length L
d(15)=L;

for i=1:14,
       m = d(i) : d(i+1) - 1;
       slope = (a(i+1) - a(i)) / (d(i+1) - d(i));
       x(m+1) = a(i) + slope * (m - d(i));
end

% [EOF]
