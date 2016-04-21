function lsf = poly2lsf(a)
%POLY2LSF Prediction polynomial to line spectral frequencies.
%   LSF = POLY2LSF(A) converts the prediction polynomial specified by A,
%   into the corresponding line spectral frequencies, LSF. 
%
%   POLY2LSF normalizes the prediction polynomial by A(1).
%
%   See also LSF2POLY, POLY2RC, POLY2AC, RC2IS. 

%   Author(s): A.Ramasubramanian
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2002/04/15 01:15:43 $
%
%   Reference:
%   A.M. Kondoz, "Digital Speech: Coding for Low Bit Rate Communications
%   Systems" John Wiley & Sons 1994, Chapter 4. 

a  = a(:);
if ~isreal(a),
    error('Line spectral frequencies are not defined for complex polynomials.');
end

% Normalize the polynomial if a(1) is not unity

if a(1) ~= 1.0,
    a = a./a(1);
end

if (max(abs(roots(a))) >= 1.0),
    error('The polynomial must have all roots inside of the unit circle.');
end

% Form the sum and differnce filters

p  = length(a)-1;  % The leading one in the polynomial is not used
a1 = [a;0];        
a2 = a1(end:-1:1);
P1 = a1-a2;        % Difference filter
Q1 = a1+a2;        % Sum Filter 

% If order is even, remove the known root at z = 1 for P1 and z = -1 for Q1
% If odd, remove both the roots from P1

if rem(p,2),  % Odd order
    P = deconv(P1,[1 0 -1]);
    Q = Q1;
else          % Even order 
    P = deconv(P1,[1 -1]);
    Q = deconv(Q1,[1  1]);
end

rP  = roots(P);
rQ  = roots(Q);

aP  = angle(rP(1:2:end));
aQ  = angle(rQ(1:2:end));

lsf = sort([aP;aQ]);

% [EOF] poly2lsf.m