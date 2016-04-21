function w = parzenwin(n)
%PARZENWIN Parzen window.
%   PARZENWIN(N) returns the N-point Parzen (de la Valle-Poussin) window in a column vector.
% 
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, BOHMANWIN, 
%            FLATTOPWIN, NUTTALLWIN, RECTWIN, TRIANG, WINDOW.

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic 
%         Analysis with the Discrete Fourier Transform, Proceedings of 
%         the IEEE, Vol. 66, No. 1, January 1978


%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/11/21 15:46:25 $

% Check for valid window length (i.e., n < 0)
[n,w,trivialwin] = check_order(n);
if trivialwin, return, end;

% Index vectors
k = -(n-1)/2:(n-1)/2;
k1 = k(k<-(n-1)/4);
k2 = k(abs(k)<=(n-1)/4);

% Equation 37 of [1]: window defined in three sections
w1 = 2 * (1-abs(k1)/(n/2)).^3;
w2 = 1 - 6*(abs(k2)/(n/2)).^2 + 6*(abs(k2)/(n/2)).^3; 
w = [w1 w2 w1(end:-1:1)]';


% [EOF]
