function c = gfsub(a, b, field, len)
%GFSUB Subtract polynomials over a Galois field.
%   C = GFSUB(A, B) subtracts polynomial B from A in GF(2).  If A and B are
%   vectors of the same orientation but different lengths, then the shorter
%   vector is zero-padded.  If A and B are matrices they must be of the same
%   size.  Each entry of A and B represents an element of GF(2).  The entries
%   of A and B are either 0 or 1.  In this case, the result is the
%   same as using GFADD.
%
%   C = GFSUB(A, B, P) subtracts polynomial B from A in GF(P), where P is
%   a prime number scalar.  Each entry of A and B represents an element of
%   GF(P).  The entries of A and B are integers between 0 and P-1.
%
%   C = GFSUB(A, B, P, LEN) subtracts polynomial B from A in GF(P) and returns
%   a truncated or extended representation of the answer.  If the row vector
%   corresponding to the answer has fewer than LEN entries, then extra zeros
%   are added at the end; if it has more than LEN entries, then entries from
%   the end are removed.  If LEN is negative, then all high-order zeros are
%   removed.
%
%   C = GFSUB(A, B, FIELD) subtracts elements B from A in GF(P^M) where P is a
%   prime number and M is a positive integer. Each entry of A and B represents
%   an element of GF(P^M) in exponential format.  The entries of A and B are
%   integers between -Inf and P^M-2.  FIELD is a matrix listing all the
%   elements in GF(P^M), arranged relative to the same primitive element.
%   FIELD can be generated using, FIELD = GFTUPLE([-1:P^M-2]', M, P);
%
%   See also GFADD, GFCONV, GFMUL, GFDECONV, GFDIV, GFTUPLE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.19 $   $Date: 2002/03/27 00:08:14 $

% Error checking.
error(nargchk(2,4,nargin));

% Default field.
if nargin < 3
    field = 2;
end

[m_a, n_a] = size(a);
[m_b, n_b] = size(b);
[m_field, n_field] = size(field);

% Error checking - LEN.
if ( (nargin > 3) & ( isempty(len) | (floor(len)~=len) | (real(len)~=len) | (prod(size(len))~=1) ) )
    error('Length parameter must be a real integer scalar.');
end

% Error checking - A & B.
if ( ( (m_a > 1) & (n_a > 1) ) | ( (m_b > 1) & (n_b > 1) ) )
    if ( (m_a ~= m_b) | (n_a ~= n_b) )
        error('If inputs are matrices, they must have the same size.');
    end
elseif ( ((m_a > 1) & (n_b > 1)) | ((m_b > 1) & (n_a > 1)) )
    error('Orientations of input vectors must be the same.');
end


if m_field*n_field == 1
    % Subtraction over a prime field.
    p = field;

    % Error checking - P.
    if ( ndims(a)>2 | ndims(b)>2 )
        error('Inputs must not have more than two dimensions.');
    end
    if ( isempty(p) | ~isreal(p) | p<=1 | prod(size(p))~=1 | floor(p)~=p | ~isprime(p) )
        error('P must be a real prime integer greater than one.')
    end

    % Match the length of vectors, zero-pad.
    if (m_a > m_b)
        b = [b; zeros(m_a-m_b,1)];
    elseif (m_a < m_b)
        a = [a; zeros(m_b-m_a,1)];
    elseif (n_a > n_b)
        b = [b zeros(1,n_a-n_b)];
    elseif (n_a < n_b)
        a = [a zeros(1,n_b-n_a)];
    end
    [m_a, n_a] = size(a);

    % Error checking - A & B.
    if ( isempty(a) | isempty(b) | any(any( a~=floor(a) | real(a)~=a | b~=floor(b) | real(b)~=b )) )
        error('Input elements must be real integers.')
    end

    % Error checking - A & B.
    if any(any( a<0 | b<0 | a>=p | b>=p ))
        if ( p == 2 )
            error('Input elements must be either 0 or 1 for subtraction over GF(2).')
        else
            error('Input elements must be between 0 and P-1 for subtraction over a prime field.')
        end
    end;

    % The actual subtraction.
    c = mod(a - b, p);

    % Truncate/zero-pab the result if requested.
    if (nargin > 3)
        if (n_a < len)
            c = [c zeros(m_a,len-n_a)];
        elseif (len < 0)
                c = c( : , 1:max([max(find(sum(c~=0,1))),1]) );
        elseif (n_a > len)
            c = c( : , 1:len );
        end
    end

else
    % Subtraction over an extension field.

    % Error checking - FIELD.
    if ( ndims(a)>2 | ndims(b)>2 | ndims(field)>2 )
        error('Inputs must not have more than two dimensions.');
    end
    if ( isempty(field) | any(any( floor(field)~=field | abs(field)~=field )) )
        error('Field parameter values must be real nonnegative integers.')
    end

    % Determine the characteristic of this field.
    p = max(max(field)) + 1;
    m = round( log(m_field)/log(p) );
    q = p^m;

    % Error checking - FIELD.
    if ( ~isprime(p) | (m_field ~= q) | (n_field ~= m) )
        error('Field parameter is not valid. See GFTUPLE.');
    end

    % More thorough error checking of FIELD matrix.
    if ~( ( m == 1 ) & ( p == 2 ) )
        alpha_m = field(m+2,:);
    else
        alpha_m = 1;
    end
    prim_poly = [ mod( -1*alpha_m , p ) 1];
    % Verify that FIELD is derived from a valid primitive polynomial.
    if gfprimck(prim_poly,p) ~= 1
        error('Field parameter is not valid. See GFTUPLE.');
    end
    % Verify that top row is all zero and next m rows form an identity matrix.
    if ( sum( field(1,:) ~= 0 ) | sum(sum( field(2:m+1,:) ~= eye(m) )) )
        error('Field parameter is not valid. See GFTUPLE.');
    end
    % Verify that all subsequent rows are formed from the primitive polynomial and the previous row.
    if ( p>2 | m>1 )
        should_be = mod( field(m+2:q-1,m)*field(m+2,:) + [zeros(q-m-2,1) field(m+2:q-1,1:m-1)] , p );
        if any(any( should_be ~= field(m+3:q,:) ))
               error('Field parameter is not valid. See GFTUPLE.');
        end
    end

    % Match the length of vectors, zero-pad.
    if (m_a > m_b)
        b = [b; -1*ones(m_a-m_b,1)];
    elseif (m_a < m_b)
        a = [a; -1*ones(m_b-m_a,1)];
    elseif (n_a > n_b)
        b = [b -1*ones(1,n_a-n_b)];
    elseif (n_a < n_b)
        a = [a -1*ones(1,n_b-n_a)];
    end
    [m_a, n_a] = size(a);

    % Error checking - A & B.
    if ( isempty(a) | isempty(b) | any(any( a~=floor(a) | real(a)~=a | b~=floor(b) | real(b)~=b )) )
        error('Input elements must be real integers.')
    end

    % Error checking - A & B.
    if any(any( ( a > (p^m)-2 ) | ( b > (p^m)-2 ) ))
        error('Input elements must be between -Inf and P^M-2 for subtraction over an extension field.')
    end;

    % Any negative input coefficients represent the zero element, set them to -1.
    indx = find( a < 0 );
    a(indx) = - ones(1, length(indx));
    indx = find( b < 0 );
    b(indx) = - ones(1, length(indx));

    % For the subtraction, convert matrices to column vectors.
    a = a(:);
    b = b(:);
    len_a = length(a);

    % The actual subtraction, done using the polynomial representations of the elements.
    result = mod(field(a + 2, :) - field(b + 2, :), p);

    % Convert the polynomial representations back to exponential representations.
    c = zeros(size(a));
    for k = 1:len_a
        c(k) = find( sum( ones(q,1)*result(k,:) ~= field, 2 ) == 0 ) - 2;
        if ( c(k) < 0 )
            c(k) = -Inf;
        end
    end

    % Reshape output back to original shape.
    c = reshape(c,m_a,n_a);

end;
%--end of GFSUB---
