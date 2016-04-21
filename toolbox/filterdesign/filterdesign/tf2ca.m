function [d1,d2,beta]=tf2ca(b,a)
%TF2CA Transfer function to coupled allpass conversion.
%   [D1,D2] = TF2CA(B,A) where B is a real, symmetric vector of numerator
%   coefficients and A is a real vector of denominator coefficients, 
%   corresponding to a stable digital filter, returns real vectors D1 and
%   D2 containing the denominator coefficients of the allpass filters
%   H1(z) and H2(z) such that
%
%           B(z)   1
%   H(z) = ----- = - [H1(z) + H2(z)] (coupled allpass decomposition).
%           A(z)   2
%
%   [D1,D2] = TF2CA(B,A) where B is a real, antisymmetric vector of
%   numerator coefficients and A is a real vector of denominator
%   coefficients, corresponding to a stable digital filter, returns
%   real vectors D1 and D2 containing the denominator coefficients of
%   the allpass filters H1(z) and H2(z) such that
%
%           B(z)   1
%   H(z) = ----- = - [H1(z) - H2(z)].
%           A(z)   2
%
%   In some cases, the decomposition is not possible with real H1(z) and
%   H2(z), in those cases a generalized coupled allpass decomposition
%   may be possible, the syntax is:
%
%   [D1,D2,BETA] = TF2CA(B,A) returns complex vectors D1 and D2
%   containing the denominator coefficients of the allpass filters
%   H1(z) and H2(z), and a complex scalar BETA, satisfying |BETA| = 1,
%   such that
%
%           B(z)   1                                  (generalized
%   H(z) = ----- = - [conj(BETA)*H1(z) + BETA*H2(z)]  coupled allpass 
%           A(z)   2                                  decomposition).
%
%   In the above equations, H1(z) and H2(z) are (possibly complex) 
%   allpass IIR filters given by:
%
%           fliplr(conj(D1(z)))            fliplr(conj(D2(z)))
%   H1(z) = -------------------,   H2(z) = -------------------
%                 D1(z)                            D2(z)
%
%   where D1(z) and D2(z) are polynomials whose coefficients are given
%   by D1 and D2 respectively.
%
%   Note: A coupled allpass decomposition is not always possible. 
%         Nevertheless, Butterworth, Chebyshev, and Elliptic IIR 
%         filters, among others, can be factored in this manner.
%         For details, refer to the Filter Design Toolbox User's Guide.
%
%   EXAMPLE:
%      [b,a]=cheby1(9,.5,.4);
%      [d1,d2]=tf2ca(b,a); % TF2CA returns the denominators of the allpass
%      num = 0.5*conv(fliplr(d1),d2)+0.5*conv(fliplr(d2),d1);
%      den = conv(d1,d2); % Reconstruct numerator and denonimator
%      max([max(b-num),max(a-den)]) % Compare original and reconstructed
%
%   See also CA2TF, TF2CL, CL2TF, IIRPOWCOMP, TF2LATC, LATC2TF.

% References:[1] P.P. Vaidyanathan, ROBUST DIGITAL FILTER STRUCTURES, in
%               HANDBOOK FOR DIGITAL SIGNAL PROCESSING. S.K. Mitra and J.F.            
%               Kaiser Eds. Wiley-Interscience, N.Y., 1993, Chapter 7.
%            [2] P.P. Vaidyanathan, MULTIRATE SYSTEMS AND FILTER BANKS, 
%               Prentice Hall, N.Y., Englewood Cliffs, NJ, 1993, Chapter 3.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.16 $  $Date: 2002/04/14 15:40:14 $

error(nargchk(2,2,nargin));

[b,a,msg] = parseinput(b,a);
error(msg);

% Compute the power complementary filter
try,
    [bp,a] = iirpowcomp(b,a);
catch,
    error(lasterr);
end

% Sort numerators to call allpassdecomposition
[p,q] = sortnums(b,bp);

% Once you have sorted the numerators, compute the actual decomposition
[d1,d2,beta] = allpassdecomposition(p,q,a);

%------------------------------------------------------------------------
function [b,a,msg] = parseinput(b,a)
%PARSEINPUT Make sure input args are real vectors. 
%   
%   Force them to be row vectors

msg = '';

% Check that b and a are vectors of the same length
if ~any(size(b)==1) | ~any(size(a)==1),
   msg = 'Input numerator and denominator must be vectors.';
   return
end
if length(b)~=length(a),
   msg = 'Numerator and denominator must be of the same length.';
   return
end

% Make sure b and a are rows
b = b(:).';
a = a(:).';

if ~isreal(b) | ~isreal(a),
    msg = 'Only real filters are allowed.';
    return
end

% Make sure numerator is symmetric or antisymmetric
symstr = signalpolyutils('symmetrytest',b);

if strcmpi(symstr,'none'),
    msg = 'Numerator must be symmetric or antisymmetric.';
    return
end

%------------------------------------------------------------------------
function [p,q] = sortnums(b,bp)
%SORTNUMS Sort numerators prior to calling ALLPASSDECOMPOSITION.
%   ALLPASSDECOMPOSITION always requires the first argument to
%   be symmetric.  The second argument, can be
%   symmetric, or antisymmetric.
%
%   IIRPOWCOMP can be called in some cases with antisymmetric numerator
%   and return a symmetric power complementary numerator. In this
%   case, we must sort these arguments before proceeding

% If b is real, antisymmetric, make it the second arg
if max(abs(b + b(end:-1:1))) < eps^(2/3),
    p = bp;
    q = b;    
else
    p = b;
    q = bp;
end

%------------------------------------------------------------------------
function [d1,d2,beta] = allpassdecomposition(p,q,a)
%ALLPASSDECOMPOSTION  Compute the allpass decomposition.
%   Given an IIR filter P/A and its power complementary filter Q/A
%   find the allpass decomposition for the filter:
%
%           P(z)   1                                  (generalized
%   H(z) = ----- = - [conj(BETA)*H1(z) + BETA*H2(z)]  coupled allpass 
%           A(z)   2                                  decomposition).
%
%   NOTE: In this function, if P is real it must always be symmetric.
%         Make sure you sort the args correctly prior to calling this 
%         function.


% If q is real, antisymmetric, make it imaginary
if isreal(q) & (max(abs(q + q(end:-1:1))) < eps^(2/3)),
    q = q*i;
end

z = roots(p-i*q);
   
% Initialize the allpass functions
d1 = 1;
d2 = 1;

% Separate the zeros inside the unit circle and the ones outside to form the allpass functions
for n=1:length(z),
   if abs(z(n)) < 1,
      d2 = conv(d2,[1 -z(n)]);
   else
      d1 = conv(d1,[1 -1/conj(z(n))]);
   end
end

% Remove roundoff imaginary parts
d1 = signalpolyutils('imagprune',d1);
d2 = signalpolyutils('imagprune',d2);

beta = sum(d2)*(sum(p)+i*sum(q))./sum(a)./sum(conj(d2));

% [EOF] - tf2ca.m

