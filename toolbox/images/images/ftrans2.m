function h = ftrans2(b,t)
%FTRANS2 Design 2-D FIR filter using frequency transformation.
%   H = FTRANS2(B,T) produces the 2-D FIR filter H that
%   corresponds to the 1-D FIR filter B using the transform
%   T. (FTRANS2 returns H as a computational molecule, which is
%   the appropriate form to use with FILTER2.) B must be a 1-D
%   odd-length (type I) filter such as can be returned by FIR1,
%   FIR2, or REMEZ in the Signal Processing Toolbox.  The
%   transform matrix T contains coefficients that define the
%   frequency transformation to use.  If T is M-by-N and B has
%   length Q, then H is size ((M-1)*(Q-1)/2+1)-by-((N-1)*(Q-1)/2+1).
%
%   H = FTRANS2(B) uses the McClellan transformation
%
%        T = [ 1   2   1  ;
%              2  -4   2  ;
%              1   2   1  ] / 8
%
%   which produces filters that are approximately circularly
%   symmetric.
%
%   Class Support
%   -------------
%   All inputs and outputs should be of class double.
%
%   Example
%   -------
%   Use FTRANS2 to design an approximately circularly symmetric
%   2-D bandpass filter with passband between 0.1 and 0.6
%   (normalized frequency).
%
%       b = remez(10,[0 0.05 0.15 0.55 0.65 1],[0 0 1 1 0 0]);
%       h = ftrans2(b);
%       freqz2(h)
%
%   See also CONV2, FILTER2, FSAMP2, FWIND1, FWIND2.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.14.4.1 $  $Date: 2003/01/26 05:55:25 $

% Reference: Jae S. Lim, "Two Dimensional Signal and Image Processing",
%            Prentice Hall, 1990, pages 213-217.

% I/O Spec
% ========
% IN
%    B should be double and it should not be zero everywhere
%    T should be double and it should not be zero everywhere
% OUT
%    H is of class double

checknargin(1,2,nargin,mfilename);
checkinput(b,{'double'},{'nonsparse','nonzero'},mfilename,'B',1);

if nargin < 2,
    t = [1 2 1;2 -4 2;1 2 1]/8;
else
    checkinput(t,{'double'},{'nonsparse','nonzero'},mfilename,'T',2);
end % McClellan transformation

% Convert the 1-D filter b to SUM_n a(n) cos(wn) form
n = (length(b)-1)/2;
if floor(n)~=n,
    msg = 'b must be an odd-length (type I) filter.';
    eid = sprintf('Images:%s:bMustBeOddLength',mfilename);
    error(eid,msg);
end
if any(abs(b-rot90(b,2))>sqrt(eps)) | min(size(b))~=1,
    msg = 'b must be a zero phase (symmetric) filter.';
    eid = sprintf('Images:%s:bMustBeSymmetric',mfilename);
    error(eid,msg);    
end
b = rot90(fftshift(rot90(b,2)),2); % Inverse fftshift
a = [b(1) 2*b(2:n+1)];

inset = floor((size(t)-1)/2);

% Use Chebyshev polynomials to compute h
P0 = 1; P1 = t;
h = a(2)*P1; 
rows = inset(1)+1; cols = inset(2)+1;
h(rows,cols) = h(rows,cols)+a(1)*P0;
for i=3:n+1,
  P2 = 2*conv2(t,P1);
  rows = rows + inset(1); cols = cols + inset(2);
  P2(rows,cols) = P2(rows,cols) - P0;
  rows = inset(1) + [1:size(P1,1)];
  cols = inset(2) + [1:size(P1,2)];
  hh = h;
  h = a(i)*P2; h(rows,cols) = h(rows,cols) + hh;
  P0 = P1;
  P1 = P2;
end
h = rot90(h,2); % Rotate for use with filter2
