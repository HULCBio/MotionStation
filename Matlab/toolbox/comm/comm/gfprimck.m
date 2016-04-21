function ck = gfprimck(a, p)
%GFPRIMCK Check whether a polynomial over a Galois field is primitive.
%   CK = GFPRIMCK(A) checks whether the degree-M GF(2) polynomial A is 
%   a primitive polynomial for GF(2^M), where M = length(A)-1.  The
%   output CK is as follows:
%       CK = -1   A is not an irreducible polynomial;
%       CK =  0   A is irreducible but not a primitive polynomial;
%       CK =  1   A is a primitive polynomial.
%
%   CK = GFPRIMCK(A, P) checks whether the degree-M GF(P) polynomial 
%   A is a primitive polynomial for GF(P^M).  P is a prime number.
%
%   The row vector A represents a polynomial by listing its coefficients
%   in order of ascending exponents.  
%   Example:  In GF(5), A = [4 3 0 2] represents 4 + 3x + 2x^3.
%
%   See also GFPRIMFD, GFPRIMDF, GFTUPLE, GFMINPOL, GFADD.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.14 $   $Date: 2002/03/27 00:07:56 $

% Error checking.
error(nargchk(1,2,nargin));

% Error checking - P.
if nargin < 2
   p = 2;
elseif ( isempty(p) | ~isreal(p) | p<=1 | floor(p)~=p | prod(size(p))~=1 | ~isprime(p) )
    error('P must be a real prime integer greater than one.');
end

% Error checking - A.
if ( isempty(a) | ndims(a)>2 | any(any( abs(a)~=a | floor(a)~=a | a>=p )) )
    if (p == 2)
        error('Polynomial coefficients must be either 0 or 1 for P=2.');
    else
        error('Polynomial coefficients must be real integers between 0 and P-1.');
    end
end
[m_a, n_a] = size(a);
if ( m_a>1 & n_a==1 )
    error('Polynomial input must be represented as a row vector.');
end

% Allocate space for the result, assume primitive.
ck = ones(m_a,1);

% Each row is interpreted as a seperate polynomial.  Cycle through each row.
for k = 1:m_a,

    % First remove high-order zeros.                        
    at = gftrunc(a(k,:));        
    m = length(at) - 1;                                     

    % The polynomial is divisible by x, hence is reducible.
    if (at(1,1) == 0)             
        ck(k) = -1;              
               
    % This polynomial is actually a constant.
    elseif ( m == 0 ) 
        ck(k) = 1;               
               
    % The typical case.          
    else               
                                          
        % First test if the current polynomial is irreducible.
        n = p^(floor(m/2)+1)-1;
        % 'test_dec' is a vector containing the decimal(scalar) representations of
        % the polynomials that could be divisors of 'at'.
        test_dec = p+1:n;  
        % test_dec's that correspond to polynomials divisible by X can be removed.
        test_dec = test_dec( find( mod(test_dec,p)~=0 ) );
        len_t = length(test_dec);
        idx = 1;           
        % Loop through all polynomials that could be divisors of 'at'.
        while ( idx <= len_t )
            % Expand the decimal(scalar) values to polynomials in GF(P).
            test_poly = de2bi(test_dec(idx),m,p);
            [ignored, r] = gfdeconv(at,test_poly,p);
            if ( max(r) == 0 )
                ck(k) = -1;
                break;
            end
            idx = idx + 1;
        end

        % If the current polynomial is irreducible then check if it is primitive.
        if ( ck(k) == 1 )
            test_ord = m;
            while ( test_ord <= p^m-2 )
                test_poly = [p-1 zeros(1,test_ord-1) 1];
                [ignored, r] = gfdeconv(test_poly,at,p);
                if ( max(r) == 0 )
                    ck(k) = 0;
                    break;
                end
                test_ord = test_ord + 1;
            end
        end
    end
end

%--end of gfprimck--
