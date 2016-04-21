function b = lowpasslband(N,L,Win)
%LOWPASSLBAND  Design an L-th band N-th order windowed FIR lowpass filter.

%   Author(s): R. Losada
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:25:40 $


% Check for even order
if rem(N,2),
	error('Order must be even.');
end

% Make sure window is a row
Win = Win(:).';

% Generate a discrete-time vector
n = [-N/2:N/2];

% Change variable, m = n/L, to be able to use sinc function
m = n./L;

% Generate the sinc function and window it
b = 1./L.*Win.*sinc(m);

% Make sure zeros are exact
b(N/2+1+L:L:end) = 0;
b(N/2+1-L:-L:1) = 0;

% EOF

