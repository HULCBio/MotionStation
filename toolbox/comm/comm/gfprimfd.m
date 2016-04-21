function pr = gfprimfd(m, fd_flag, p)
%GFPRIMFD Find primitive polynomials for a Galois field.
%   PR = GFPRIMFD(M) computes one degree-M primitive polynomial for GF(2^M). 
%
%   PR = GFPRIMFD(M, OPT) computes primitive polynomial(s) for GF(2^M).
%   OPT = 'min'  find one primitive polynomial of minimum weight.
%   OPT = 'max'  find one primitive polynomial of maximum weight.
%   OPT = 'all'  find all primitive polynomials. 
%   OPT = L      find all primitive polynomials of weight L.
%  
%   PR = GFPRIMFD(M, OPT, P) is the same as PR = GFPRIMFD(M, OPT) except that
%   2 is replaced by a prime number P. 
%
%   The output row vector PR represents a polynomial by listing its 
%   coefficients in order of ascending exponents.
%   Example:  In GF(5), A = [4 3 0 2] represents 4 + 3x + 2x^3.
%
%   If OPT = 'all' or L, and more than one primitive polynomial satisfies the
%   constraints, then each row of PR represents a different polynomial.  If no
%   primitive polynomial satisfies the constraints, then PR is empty.
%
%   See also GFPRIMCK, GFPRIMDF, GFTUPLE, GFMINPOL.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.12 $   $Date: 2002/03/27 00:08:02 $

% Error checking.
error(nargchk(1,3,nargin));

% Error checking - M.
if ( isempty(m) | ~isreal(m) | m<1 | floor(m)~=m | prod(size(m))~=1 )
    error('M must be a real positive scalar.');
end

% Error checking - FD_FLAG.
if nargin > 1
    if ischar(fd_flag)
        fd_flag = lower(fd_flag);
        if ~( strcmp(fd_flag,'min') | strcmp(fd_flag,'max') | strcmp(fd_flag,'all') )
            error('Invalid string input.');
        end
    elseif ( isempty(fd_flag) | floor(fd_flag)~=fd_flag | ~isreal(fd_flag) | prod(size(fd_flag))~=1 | fd_flag<2 | fd_flag>m+1 )
        error('OPT parameter must be either a string, or a real integer greater than one and less than M+1.');
    end
else
    fd_flag = 'one';
end

% Error checking - P.
if nargin < 3
   p = 2;
elseif ( isempty(p) | ~isreal(p) | floor(p)~=p | p<2 | prod(size(p))~=1 | ~isprime(p) )
    error('P must be a real prime integer greater than one.');
end

% 'test_end' is the decimal(scalar) representation of the largest polynomial 
% that may be tested.
test_end = 2*(p^m) - 1;

pr = [];


% Find either just the first, or all valid primitive polynomials.
if ( ( strcmp(fd_flag,'one') ) | ( strcmp(fd_flag,'all') ) )

    % 'test_dec' is the decimal(scalar) representation of
    % the polynomial that will be tested each cycle.
    test_dec = p^m + 1;

    % Cycle through all possible polynomials.
    while ( test_dec <= test_end )

        % Check that this polynomial is not divisible by X.
        if ( mod(test_dec,p)~=0 )
            % Expand the decimal(scalar) value to a polynomial in GF(P).
            test_poly = de2bi( test_dec, m+1, p );
            % Test the polynomial.
            if ( gfprimck(test_poly, p) == 1 )
                if strcmp(fd_flag,'one')
                    pr = test_poly;
                    break;
                else
                    pr = [pr; test_poly];
                end
            end
        end
        test_dec = test_dec + 1;
    end

% Find the primitive polynomials of only certain weight.
else
    
    % Define what range of polynomial weights to work over.
    if strcmp(fd_flag,'min')
        weight = [2:m+1];
    elseif strcmp(fd_flag,'max')
        weight = [m+1:-1:2];
    else
        weight = fd_flag;
    end
    weight_len = length(weight);
    weight_idx = 1;

    % Cycle through specified weights.
    while ( weight_idx <= weight_len )

        % 'test_dec' is the decimal(scalar) representation of
        % the polynomial that will be tested each cycle.
        test_dec = p^m + 1;
        
        % Cycle through all possible polynomials.
        while ( test_dec <= test_end )
            
            % Check that this polynomial is not divisible by X.
            if ( mod(test_dec,p)~=0 )
                % Expand the decimal(scalar) value to a polynomial in GF(P).
                test_poly = de2bi( test_dec, m+1, p );

                % Check that this polynomial has the proper weight.
                if ( sum(test_poly~=0) == weight(weight_idx) )

                    % Test the polynomial.
                    if ( gfprimck(test_poly, p) == 1 )
                        if ischar(fd_flag)
                            pr = test_poly;
                            weight_idx = weight_len + 1;
                            break;
                        else
                            pr = [pr; test_poly];
                        end
                    end
                end
            end
            test_dec = test_dec + 1;
        end
        weight_idx = weight_idx + 1;
    end
end

if isempty(pr)
    disp('No primitive polynomial satisfies the given constraints.');
end;

%--end of GFPRIMFD--


