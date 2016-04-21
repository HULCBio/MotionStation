function [z,p,k] = buttap(n)
%BUTTAP Butterworth analog lowpass filter prototype.
%   [Z,P,K] = BUTTAP(N) returns the zeros, poles, and gain
%   for an N-th order normalized prototype Butterworth analog
%   lowpass filter.  The resulting filter has N poles around
%   the unit circle in the left half plane, and no zeros.
%
%   See also BUTTER, CHEB1AP, CHEB2AP, ELLIPAP.

%   Author(s): J.N. Little and J.O. Smith, 1-14-87
%   	   L. Shure, 1-13-88, revised
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 01:09:52 $

% Poles are on the unit circle in the left-half plane.
z = [];
p = exp(i*(pi*(1:2:n-1)/(2*n) + pi/2));
p = [p; conj(p)];
p = p(:);
if rem(n,2)==1   % n is odd
    p = [p; -1];
end
k = real(prod(-p));

