function cs = gfcosets(m, p);
%GFCOSETS Produce cyclotomic cosets for a Galois field.
%   CS = GFCOSETS(M) produces cyclotomic cosets mod(2^M - 1). Each row of the
%   output CS contains one cyclotomic coset.
%
%   CS = GFCOSETS(M, P) produces cyclotomic cosets mod(P^M - 1), where 
%   P is a prime number.
%       
%   Because the length of the cosets varies in the complete set, NaN is used to
%   fill out the extra space in order to make all variables have the same
%   length in the output matrix CS.
%
%   See also GFMINPOL, GFPRIMDF, GFROOTS.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.14 $   $Date: 2002/03/27 00:07:23 $                

% Error checking.
error(nargchk(1,2,nargin));

% Error checking - P.
if nargin < 2
    p = 2;
elseif ( isempty(p) | prod(size(p))~=1 | abs(p)~=p | floor(p)~=p | ~isprime(p) )
    error('P must be a real prime scalar.');
end

% Error checking - M.
if ( isempty(m) | prod(size(m))~=1 | ~isreal(m) | floor(m)~=m | m<1 )
    error('M must be a real positive integer.');
end

% The cyclotomic coset containing s is 
% {s, s^p, s^(p^2),...,s^(p^(k-1))}, where
% k is the smallest positive integer such that s^(p^k) = s.

% Special case, P=2 & M=1.
if ( ( p == 2 ) & ( m == 1 ) )
    i = [];
else
    i = 1;
end

n = p^m - 1;
cs = [];                   % used for the output
ind = ones(1, n - 1);      % used to register unprocessed numbers.

while ~isempty(i)

   % to process numbers that have not been done before.
   ind(i) = 0;             % mark the register
   s = i;
   v = s;
   pk = rem(p*s, n);       % the next candidate

   % build cyclotomic coset containing s=i
   while (pk > s)
          ind(pk) = 0;    % mark the register
          v = [v pk];     % recruit the number
          pk = rem(pk * p, n);    % the next candidate
   end;

   % append the coset to cs
   [m_cs, n_cs] = size(cs);
   [m_v, n_v ]  = size(v);
   if (n_cs == n_v) | (m_cs == 0)
          cs = [cs; v];
   elseif (n_cs > n_v)
          cs = [cs; [v, ones(1, n_cs - n_v) * NaN]];
   else
          % this case should not happen, in general.
          cs = [[cs, ones(m_cs, n_v - n_cs) * NaN]; v];
   end;
   i = min(find(ind == 1));        % the next number.

end;

% add the number "0" to the first coset
[m_cs, n_cs] = size(cs);
cs = [[0, ones(1, n_cs - 1) * NaN]; cs];

%--end of GFCOSETS--


