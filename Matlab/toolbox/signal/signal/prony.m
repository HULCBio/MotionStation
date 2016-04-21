function [b,a] = prony(h, nb ,na)
%PRONY Prony's method for time-domain IIR filter design.
%   [B,A] = PRONY(H, NB, NA) finds a filter with numerator order
%   NB, denominator order NA, and having the impulse response in
%   vector H.   The IIR filter coefficients are returned in
%   length NB+1 and NA+1 row vectors B and A, ordered in
%   descending powers of Z.  H may be real or complex.
%
%   If the largest order specified is greater than the length of H,
%   H is padded with zeros.
%
%   See also STMCB, LPC, BUTTER, CHEBY1, CHEBY2, ELLIP, INVFREQZ.

%   Author(s): L. Shure, 5-17-88
%              L. Shure, 12-17-90, revised
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 01:13:19 $

%   References:
%     [1] T.W. Parks and C.S. Burrus, Digital Filter Design,
%         John Wiley and Sons, 1987, p226.

K = length(h) - 1;
M = nb; N = na;
if K <= max(M,N)      % zero-pad input if necessary
    K = max(M,N)+1;
    h(K+1) = 0;
end
c = h(1);
if c==0    % avoid divide by zero
    c=1;
end
H = toeplitz(h/c,[1 zeros(1,K)]);
% K+1 by N+1
if (K > N)
    H(:,(N+2):(K+1)) = [];
end
% Partition H matrix
H1 = H(1:(M+1),:);	% M+1 by N+1
h1 = H((M+2):(K+1),1);	% K-M by 1
H2 = H((M+2):(K+1),2:(N+1));	% K-M by N
a = [1; -H2\h1].';
b = c*a*H1.';

