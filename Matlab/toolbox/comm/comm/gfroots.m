function [rt, rt_tp, alph] = gfroots(f, ord, p)
%GFROOTS Find roots of a polynomial over a prime Galois field.
%   For all syntaxes, F is a row vector that gives the coefficients,
%   in order of ascending exponents, of a degree-D polynomial.
%
%   Note: GFROOTS lists each root exactly once, ignoring multiplicities.
%
%   RT = GFROOTS(F) finds roots in GF(2^D) of the polynomial that F
%   represents.  RT is a column vector, each of whose entries is the
%   exponential format of a root.  The exponential format is relative
%   to a root of the default primitive polynomial for GF(2^D).
%
%   RT = GFROOTS(F, M) finds roots in GF(2^M) of the polynomial that F
%   represents. RT has the format listed above.  The exponential format is
%   relative to a root of the default primitive polynomial for GF(2^M).
%
%   RT = GFROOTS(F, PRIM_POLY) is the same as the syntax above, except
%   that PRIM_POLY is a row vector that lists the coefficients of a
%   degree-M primitive polynomial for GF(2^M) in order of ascending
%   exponents.
%
%   RT = GFROOTS(F, M, P) is the same as RT = GFROOTS(F, M) except that
%   2 is replaced by a prime number P.
%
%   RT = GFROOTS(F, PRIM_POLY, P) is the same as RT = GFROOTS(F, PRIM_POLY)
%   except that 2 is replaced by a prime number P.
%
%   [RT, RT_TUPLE] = GFROOTS(...) returns an additional matrix RT_TUPLE,
%   whose kth row is the polynomial format of the root RT(k).
%
%   [RT, RT_TUPLE, FIELD] = GFROOTS(...) returns an additional matrix
%   FIELD, which gives the list of elements of the extension field.
%
%   See also GFPRIMDF, GFLINEQ.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $ $ Date: $

% Error checking.
error(nargchk(1,3,nargin));

if nargin < 3
    p = 2;
end;

if nargin < 2 % Syntax doesn't specify the extension field.
    ord = length(f) - 1;
    if ord==0 % Polynomial is a constant and syntax does not specify the field.
       error('For zero-degree polynomials, use the second input to specify the field.')
    end    
end;

% Error checking - f.
if ( isempty(f) | ndims(f)>2 | any(any( abs(f)~=f | floor(f)~=f | f>=p )) )
    if (p == 2)
        error('Polynomial coefficients must be either 0 or 1 for P=2.');
    else
        error('Polynomial coefficients must be real integers between 0 and P-1.');
    end
end

if length(ord) > 1
    dim = length(ord) - 1;
else
    dim = ord;
    ord = gfprimdf(dim, p);
end;
length_alph = p^dim;

% List of all elements in GF(P^DIM)
alph = gftuple([-1 : length_alph - 2]', ord, p);

if f==0 % All field elements are roots.
   rt_tp=alph;
   rt=[-Inf 0:length_alph-2]';
   return
end

length_f = length(f);

% All conjugates of a root are roots themselves.
cs = gfcosets(dim, p);
[n_cs, m_cs] = size(cs);

if f(1) == 0 % Is zero a root?
   rt = -Inf; % Exponential format
   rt_tp = alph(1,:); % Polynomial format
	nz = find(f~=0); % Find lowest order term with nonzero coeff.
	if ~isempty(nz) 
	   f=f(min(nz):end); % Divide out powers of x in the polynomial.
	else % f is the zero polynomial, so nothing left to do.
	   return;
	end
   length_f=length(f); % Recalculate, since old value is now false.
else
    rt = [];
    rt_tp = [];
end;

if rem(sum(f), p) == 0
    rt = [rt; 0];
    rt_tp = [rt_tp; alph(2,:)];
end;

i = 2;
while ((i <= n_cs) & (length(rt) < length_f - 1))
    tmp = [f(1) zeros(1, dim - 1)];
    for j = 2 : length_f
        if f(j) ~= 0
            k = cs(i, 1) * (j - 1) + 2;
            if k > length_alph
                k = rem(k - 2, length_alph - 1) + 2;
            end;
            tmp = rem(tmp + alph(k, :) * f(j), p);
        end;
    end;
    if max(tmp) == 0
        inx = cs(i, :);
        inx(isnan(inx)) = [];
        rt = [rt; inx'];
        rt_tp = [rt_tp; alph(inx+2, :)];
    end;
    i = i + 1;
end;

%--end of GFROOTS--
