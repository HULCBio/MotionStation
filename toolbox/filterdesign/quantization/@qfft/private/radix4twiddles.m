function w = radix4twiddles(n)
%RADIX4TWIDDLES  Radix-4 FFT twiddle factors.
%   RADIX4TWIDDLES(N) returns twiddle factors for a radix-4 FFT of length N. 

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:25:26 $

%%%%%%%%%%%%%%%%%%%%%
% Charles Van Loan, Computational Frameworks for the Fast Fourier Transform,
% SIAM, 1992, ISBN 0-89871-285-8
% Algorithm 2.4.1, p. 104
% Non-vectorized
% k=1;
% for q = 1:t
%   L = 4^q;
%   L4 = L/4;
%   for j=0:L4-1
%     w(k,1) = cos(2*pi*j/L) - i*sin(2*pi*j/L);
%     w(k,2) = w(k,1)*w(k,1);
%     w(k,3) = w(k,1)*w(k,2);
%     k = k+1;
%   end
% end
%%%%%%%%%%%%%%%%%%%%%

t = log2(n)/2;
m = (n-1)/3;
w = zeros(m,3);

% Vectorized the inner loop
k=1;
for q = 1:t
  L = 4^q;
  L4 = L/4;
  j=(0:L4-1)';
  kk = k+j;
  w(kk,1) = cos(2*pi*j/L) - i*sin(2*pi*j/L);
  w(kk,2) = w(kk,1).*w(kk,1);
  w(kk,3) = w(kk,1).*w(kk,2);
  k = max(kk)+1;
end

w = w.';
w = w(:);
