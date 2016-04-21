function a = lsf2poly(lsf)
%LSF2POLY  Line spectral frequencies to prediction polynomial.
%   A = LSF2POLY(L) returns the prediction polynomial, A, based on the line
%   spectral frequencies, L. 
%
%   See also POLY2LSF, RC2POLY, AC2POLY, RC2IS.

%   Author(s): A.Ramasubramanian
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2002/04/15 01:15:46 $
%
%   Reference:
%   A.M. Kondoz, "Digital Speech: Coding for Low Bit Rate Communications
%   Systems" John Wiley & Sons 1994 ,Chapter 4 

if (~isreal(lsf)),
    error ('Line spectral frequencies must be real.');
end

if (max(lsf) > pi | min(lsf) < 0),
    error ('Line spectral frequencies must be between 0 and pi.');
end

lsf = lsf(:);
p = length(lsf); % This is the model order

% Form zeros using the LSFs and unit amplitudes
z  = exp(j*lsf);

% Separate the zeros to those belonging to P and Q
rQ = z(1:2:end);
rP = z(2:2:end);

% Include the conjugates as well
rQ = [rQ;conj(rQ)];
rP = [rP;conj(rP)];

% Form the polynomials P and Q, note that these should be real
Q  = poly(rQ);
P  = poly(rP);

% Form the sum and difference filters by including known roots at z = 1 and
% z = -1 

if rem(p,2),
   % Odd order: z = +1 and z = -1 are roots of the difference filter, P1(z)
   P1 = conv(P,[1 0 -1]);
   Q1 = Q;
else
    % Even order: z = -1 is a root of the sum filter, Q1(z) and z = 1 is a
    % root of the difference filter, P1(z)
   P1 = conv(P,[1 -1]);
   Q1 = conv(Q,[1  1]);
end


% Prediction polynomial is formed by averaging P1 and Q1

a = .5*(P1+Q1);
a(end) = []; % The last coefficient is zero and is not returned

% [EOF] lsf2poly.m