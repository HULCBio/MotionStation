function w = min4termwin(N,A)
%MIN4TERMWIN Generate a minimum 4-term Blackman-Harris window.
%   MIN4TERMWIN(N,A) returns an N-point minimum 4-term Blackman-Harris 
%   window using the coefficients specified in A.    

%   Author(s): P. Costa 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 01:08:18 $

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic 
%         Analysis with the Discrete Fourier Transform, Proceedings of 
%         the IEEE, Vol. 66, No. 1, January 1978

% Equation 33 from [1]
x = (0:N-1)' * 2.0*pi/(N-1);

%w = A(1) - A(2)*cos(x) + A(3)*cos(2.0*x) - A(4)*cos(3.0*x);
B = [A(1); -A(2); A(3); -A(4)];
w = cos(x* [0 1 2 3]) * B;