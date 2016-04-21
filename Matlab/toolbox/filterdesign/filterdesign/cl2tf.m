function [b,a,q]=cl2tf(K1,K2,beta)
%CL2TF Coupled allpass lattice to transfer function conversion.
%   [B,A] = CL2TF(K1,K2) where K1 and K2 are real vectors of reflection
%   coefficients corresponding to allpass lattice structures, returns the
%   numerator and denominator vectors of coefficients B and A
%   corresponding to the transfer function
%
%           B(z)   1
%   H(z) = ----- = - [H1(z) + H2(z)].
%           A(z)   2
%
%   where H1(z) and H2(z) are the transfer functions of the allpass
%   filters determined by K1 and K2.
%
%   [B,A] = CL2TF(K1,K2,BETA) where K1, K2 and BETA are complex, returns
%   the numerator and denominator vectors of coefficients B and A
%   corresponding to the transfer function
%
%           B(z)   1
%   H(z) = ----- = - [conj(BETA)*H1(z) + BETA*H2(z)].
%           A(z)   2
%
%   [B,A,Bp] = CA2TF(K1,K2) where K1 and K2 are real, returns the vector
%   Bp of real coefficients corresponding to the numerator of the power 
%   complementary filter G(z),
%
%          Bp(z)   1
%   G(z) = ----- = - [H1(z) - H2(z)].
%           A(z)   2
%
%   [B,A,Bp] = CA2TF(K1,K2,BETA) where K1, K2 and BETA are complex, returns
%   the vector of coefficients Bp of possibly complex coefficients
%   corresponding to the numerator of the power complementary filter G(z),
%
%          Bp(z)    1
%   G(z) = ----- = ---- [-conj(BETA)*H1(z) + BETA*H2(z)].
%           A(z)    2j
%
%   EXAMPLE:
%      [b,a]=cheby1(10,.5,.4);
%      [k1,k2,beta]=tf2cl(b,a); %TF2CL returns the reflection coeffs
%      [num,den,numpc]=cl2tf(k1,k2,beta); %Reconstruct the original filter
%                                    %plus the power complementary one.
%      [H,w,s]=freqz(num,den);Hpc = freqz(numpc,den);
%      s.plot = 'mag'; s.yunits = 'sq';
%      freqzplot([H Hpc],w,s); %Plot the mag response of the original filter
%                              %and the power complementary one.
%
%   See also TF2CL, TF2CA, CA2TF, TF2LATC, LATC2TF, IIRPOWCOMP.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/14 15:40:17 $

error(nargchk(2,3,nargin));

if nargin == 2,
   beta = 1; % Assume beta equal to one if not specified.
end

[num1,den1] = latc2tf(K1,'allpass');
[num2,den2] = latc2tf(K2,'allpass');

try,
    [b,a,q] = ca2tf(den1,den2,beta);
catch
    error(lasterr);
end

% [EOF] - cl2tf.m

