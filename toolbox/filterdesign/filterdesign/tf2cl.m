function [k1,k2,beta]=tf2cl(b,a)
%TF2CL Transfer function to coupled allpass lattice conversion.
%   [K1,K2] = TF2CL(B,A) where B is a real, symmetric vector of
%   numerator coefficients and A is a real vector of denominator
%   coefficients, corresponding to a stable digital filter, will
%   perform the coupled allpass decomposition
%
%           B(z)   1
%   H(z) = ----- = - [H1(z) + H2(z)] (coupled allpass decomposition)
%           A(z)   2
%
%   of a stable IIR filter H(z) and convert the allpass transfer
%   functions H1(z) and H2(z) to a coupled lattice allpass structure
%   with coefficients given in vectors K1 and K2 respectively.
%
%   [K1,K2] = TF2CL(B,A) where B is a real, antisymmetric vector of
%   numerator coefficients and A is a real vector of denominator
%   coefficients, corresponding to a stable digital filter, will 
%   perform the coupled allpass decomposition
%
%           B(z)   1
%   H(z) = ----- = - [H1(z) - H2(z)]
%           A(z)   2
%
%   of a stable IIR filter H(z) and convert the allpass transfer
%   functions H1(z) and H2(z) to a coupled lattice allpass structure
%   with coefficients given in vectors K1 and K2 respectively.
%
%   In some cases, the decomposition is not possible with real H1(z) and
%   H2(z), in those cases a generalized coupled allpass decomposition
%   may be possible, the syntax is:
%
%   [K1,K2,BETA] = TF2CL(B,A) will perform the generalized  allpass
%   decomposition
%
%           B(z)   1                                  (generalized
%   H(z) = ----- = - [conj(BETA)*H1(z) + BETA*H2(z)]  coupled allpass 
%           A(z)   2                                  decomposition).
%
%   of a stable IIR filter H(z) and convert the complex allpass transfer
%   functions H1(z) and H2(z) to corresponding lattice allpass filters.
%   BETA is a complex scalar of magnitude 1.
%
%   Note: A coupled allpass decomposition is not always possible. 
%         Nevertheless, Butterworth, Chebyshev, and Elliptic IIR 
%         filters, among others, can be factored in this manner.
%         For details, refer to the Filter Design Toolbox User's Guide.
%
%   EXAMPLE:
%      [b,a]=cheby1(9,.5,.4);
%      [k1,k2]=tf2cl(b,a); % Get the reflection coeffs. for the lattices
%      [num1,den1]=latc2tf(k1,'allpass'); % Convert each allpass lattice
%      [num2,den2]=latc2tf(k2,'allpass'); % back to transfer function.
%      num = 0.5*conv(num1,den2)+0.5*conv(num2,den1);
%      den = conv(den1,den2); % Reconstruct numerator and denonimator
%      max([max(b-num),max(a-den)]) % Compare original and reconstructed
%
%   See also CL2TF, TF2CA, IIRPOWCOMP, CA2TF, TF2LATC, LATC2TF.

% Reference:[1] P.P. Vaidyanathan, ROBUST DIGITAL FILTER STRUCTURES, in
%               HANDBOOK FOR DIGITAL SIGNAL PROCESSING. S.K. Mitra and J.F.            
%               Kaiser Eds. Wiley-Interscience, N.Y., 1993, Chapter 7.
%           [2] S. K. Mitra, DIGITAL SIGNAL PROCESSING, A Computer
%               Based Approach, McGraw-Hill, N.Y., 1998, Chapter 6.
%
%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/14 15:40:11 $

error(nargchk(2,2,nargin));

try,
    [d1,d2,beta] = tf2ca(b,a);
catch
    error(lasterr);
end

% We obtain the K's as if the filters were all-pole filters
k1 = tf2latc(1,d1);
k2 = tf2latc(1,d2);

% [EOF] - tf2cl.m

