function [poly_form, exp_form] = gftuple(a, prim_poly, p, prim_ck)
%GFTUPLE Simplify or convert the format of elements of a Galois field.
%   For all syntaxes, A is a matrix, each row of which represents an element
%   of a Galois field.  If A is a column of integers, then MATLAB interprets
%   each row as an exponential format of an element.  Negative integers and
%   -Inf all represent the zero element of the field.  If A has more than one
%   column MATLAB interprets each row as a polynomial format of an element.
%   In that case, each entry of A must be an integer between 0 and P-1.
%
%   All formats are relative to a root of a primitive polynomial specified by
%   the second input argument, described below.
%
%   TP = GFTUPLE(A, M) returns the simplest polynomial format of the elements
%   that A represents, where the kth row of TP corresponds to the kth row of
%   A.  Formats are relative to a root of the default primitive polynomial for
%   GF(2^M).  M is a positive integer.
%
%   TP = GFTUPLE(A, PRIM_POLY) is the same as the syntax above, except that
%   PRIM_POLY is a row vector that lists the coefficients of a degree-M
%   primitive polynomial for GF(2^M) in order of ascending exponents.
%
%   TP = GFTUPLE(A, M, P) is the same as TP = GFTUPLE(A, M) except that 2 is
%   replaced by a prime number P.
%
%   TP = GFTUPLE(A, PRIM_POLY, P) is the same as TP = GFTUPLE(A, PRIM_POLY)
%   except that 2 is replaced by a prime number P.
%
%   TP = GFTUPLE(A, PRIM_POLY, P, PRIM_CK) is the same as the syntax above
%   except that GFTUPLE checks whether PRIM_POLY represents a polynomial that
%   is indeed primitive.  If not, then GFTUPLE generates an error and does not
%   return TP.  The input argument PRIM_CK can be any number or string.
%
%   [TP, EXPFORM] = GFTUPLE(...) returns the additional matrix EXPFORM.  The
%   kth row of EXPFORM is the simplest exponential format of the element that
%   the kth row of A represents.
%
%   In exponential format, the number k represents the element alpha^k, where
%   alpha is a root of the chosen primitive polynomial.  In polynomial format,
%   the row vector k represents a list of coefficients in order of ascending
%   exponents.  For example: in GF(5), k = [4 3 0 2] represents 4 + 3x + 2x^3.
%
%   To generate a FIELD matrix over GF(P^M), as used by other GF functions
%   such as GFADD, the following command may be used:
%   FIELD = GFTUPLE([-1 : P^M-2]', M, P);
%
%   See also GFADD, GFMUL, GFCONV, GFDIV, GFDECONV, GFPRIMDF.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.18 $   $Date: 2002/03/27 00:08:26 $

% Error checking.
error(nargchk(2,4,nargin));

% Error checking - P.
if nargin < 3
    p = 2;
else
    if ( isempty(p) | ~isreal(p) | p<2 | floor(p)~=p | ~isprime(p) | prod(size(p))~=1 )
        error('P must be a real prime integer greater than one.');
    end
end;

% Error checking - A.
if ( isempty(a) | ndims(a)>2 )
    error('Form of A invalid.');
end
[m_a, n_a] = size(a);
if n_a == 1
    if any(any( real(a)~=a | floor(a)~=a ))
        error('If input A is a column vector, then its entries must be real integers.');
    end
else
    if any(any( abs(a)~=a | floor(a)~=a ))
        error('If input A is a matrix, then its entries must be real positive integers.');
    end
end;

% Error checking - PRIM_POLY.
[m_pp, n_pp] = size(prim_poly);
if ( ndims(prim_poly)>2 | (m_pp > 1) )
    error('The second input argument must be either a scalar or a row vector.');
else
    if (n_pp == 1)
        if ( isempty(prim_poly) | ~isreal(prim_poly) | floor(prim_poly)~=prim_poly | prim_poly<1 )
            error('M must be a real positive integer.');
        else
            m = prim_poly;
            prim_poly = gfprimdf(m, p);
            [m_pp, n_pp] = size(prim_poly);
        end
    else
        if ( isempty(prim_poly) | ~isreal(prim_poly) | any( floor(prim_poly)~=prim_poly ) )
            error('Entries in PRIM_POLY must be real positive integers.');
        end
        if ( prim_poly(1)==0 | prim_poly(n_pp)~=1 )
            error('PRIM_POLY must be a monic primitive polynomial, see GFPRIMDF.');
        end
        if ( any( (prim_poly >= p) | (prim_poly < 0) ) )
            if ( p == 2 )
                error('Coefficients in PRIM_POLY must be either zero or one.');
            else
                error('Coefficients in PRIM_POLY must be between 0 and P-1.');
            end
        end
        m = n_pp - 1;
        if nargin > 3
            if (gfprimck(prim_poly, p) ~= 1)
                error('PRIM_POLY is not a primitive polynomial.');
            end
        end
    end
end

q = p^m;

% The 'alpha^m' equivalence is determined from the primitive polynomial.
alpha_m = mod( -1*prim_poly(1:m) , p );

% First calculate the full 'field' matrix.  Each row of the 'field'
% matrix is the polynomial representation of one element in GF(P^M).
field = zeros(q,m);
field(2:m+1,:) = eye(m);
fvec = zeros(1,m+1);
for k = m+2:q,
    fvec = [0 field(k-1,:)];
    if (fvec(m+1)>0)
        fvec(1:m) = mod( fvec(1:m)+fvec(m+1)*alpha_m, p );
    end
    field(k,:) = fvec(1:m);
end

% Calculate the simplest polynomial form of the input 'a'.
poly_form = zeros(m_a, m);
if n_a == 1

    % Exponential input representation case.

    idx = find( a > q-2 );
    a(idx) = mod( a(idx), q-1 );

    a( find(a<0) ) = -1;
    poly_form = field( a+2 , : );

else

    % Polynomial input representation case.
    % Cycle through each input row.
    for k = 1:m_a

        at = gftrunc( a(k,:) );
        at = [at zeros(1, q-1-mod(length(at),q-1) ) ];
        at = reshape(at,q-1,length(at)/(q-1)).';
        at = mod( sum(at,1), p );
        poly_form(k,:) = mod( at*field(2:q,:), p );

    end

end

% Calculate the simplest exponential form of the input 'a' if requested.
if nargout > 1

    exp_form = zeros(m_a,1);

    % Cycle through each input row.
    pvec = p.^[0:(m-1)].';
    for k = 1:m_a
        exp_form(k,:) = find( field*pvec == poly_form(k,:)*pvec ) - 2;
    end
    idx = find( exp_form < 0 );
    exp_form(idx) = -Inf;

end;

%--- end of gftuple --

