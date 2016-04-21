function [b,a,q]=ca2tf(d1,d2,beta)
%CA2TF Coupled allpass to transfer function conversion.
%   [B,A] = CA2TF(D1,D2) where D1 and D2 are real vectors corresponding
%   to the denominators of the allpass filters H1(z) and H2(z), returns
%   the vector of coefficients B and the vector of coefficients A
%   corresponding to the numerator and the denominator of the transfer
%   function
%
%           B(z)   1
%   H(z) = ----- = - [H1(z) + H2(z)].
%           A(z)   2
%
%   [B,A] = CA2TF(D1,D2,BETA) where D1, D2 and BETA are complex, returns
%   the vector of coefficients B and the vector of coefficients A
%   corresponding to the numerator and the denominator of the transfer
%   function
%
%           B(z)   1
%   H(z) = ----- = - [conj(BETA)*H1(z) + BETA*H2(z)].
%           A(z)   2
%
%   [B,A,Bp] = CA2TF(D1,D2) where D1 and D2 are real, returns the vector
%   Bp of real coefficients corresponding to the numerator of the power 
%   complementary filter G(z),
%
%          Bp(z)   1
%   G(z) = ----- = - [H1(z) - H2(z)].
%           A(z)   2
%
%   [B,A,Bp] = CA2TF(D1,D2,BETA) where D1, D2 and BETA are complex, returns
%   the vector of coefficients Bp of possibly complex coefficients
%   corresponding to the numerator of the power complementary filter G(z),
%
%          Bp(z)    1
%   G(z) = ----- = ---- [-conj(BETA)*H1(z) + BETA*H2(z)].
%           A(z)    2j
%
%   EXAMPLE:
%      [b,a]=cheby1(10,.5,.4);
%      [d1,d2,beta]=tf2ca(b,a);           %TF2CA returns the denominators 
%      [num,den,numpc]=ca2tf(d1,d2,beta); %Reconstruct the original filter
%                                         %plus the power complementary one.
%      fvtool(num,den,numpc,den);         %Plot the mag response of the original 
%                                         %filter and the power complementary one.
%                                         %Choose magnitude-squared in FVTOOL
%
%   See also TF2CA, TF2CL, CL2TF, IIRPOWCOMP, FVTOOL.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.18.4.2 $  $Date: 2004/04/12 23:25:19 $

error(nargchk(2,3,nargin));

if nargin == 2,
   beta = 1; % Assume beta equal to one if not specified.
end

% Make sure D1 and D2 are rows
d1 = d1(:).';
d2 = d2(:).';

% Compute the numerators and denominator
[b,a,q] = computenumNden(d1,d2,beta);


%---------------------------------------------------------------------------
function [b,a,q] = computenumNden(d1,d2,beta)
%COMPUTENUMNDEN  Compute the numerator, denominator and power complementary
%                numerator coefficients, given allpass denominators.


% Form the coupled-allpass filter
h = cascade(dfilt.scalar(1/2),...
    parallel(dfilt.df2(conj(beta)*conj(fliplr(d1)),d1),...
    dfilt.df2(beta*conj(fliplr(d2)),d2)));

% norm(beta-1,inf) < eps^(2/3) is a better check for beta == 1
if isreal(d1) && isreal(d2) && (norm(beta-1,inf) < eps^(2/3)),
    g = cascade(dfilt.scalar(1/(2)),...
        parallel(dfilt.df2(conj(fliplr(d1)),d1),...
        cascade(dfilt.scalar(-1),dfilt.df2(conj(fliplr(d2)),d2))));
else
    % Form power complementary filter
    g = cascade(dfilt.scalar(1/(2*j)),...
        parallel(dfilt.df2(-conj(beta)*conj(fliplr(d1)),d1),...
        dfilt.df2(beta*conj(fliplr(d2)),d2)));
end

[b,a] = tf(h);

[q,anotused] = tf(g);    
    
% Get rid of roundoff imaginary parts
a = signalpolyutils('imagprune',a);
b = signalpolyutils('imagprune',b);
q = signalpolyutils('imagprune',q);
  
% [EOF] - ca2tf.m

