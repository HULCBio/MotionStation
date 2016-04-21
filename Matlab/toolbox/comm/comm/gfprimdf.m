function pol = gfprimdf(m, p)
%GFPRIMDF Provide default primitive polynomials for a Galois field.
%   POL = GFPRIMDF(M) outputs the default primitive polynomial POL in
%   GF(2^M). 
%
%   POL = GFPRIMDF(M, P) outputs the default primitive polynomial POL
%   in GF(P^M).
%
%   The default primitive polynomials are monic polynomials.
%
%   See also GFPRIMCK, GFPRIMFD, GFTUPLE, GFMINPOL.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.12 $   $Date: 2002/03/27 00:07:59 $

% Error checking.
error(nargchk(1,2,nargin));

% Error checking - M.
if ( isempty(m) | ~isreal(m) | m<1 | floor(m)~=m | prod(size(m))~=1 )
    error('M must be a real positive scalar.');
end

% Error checking - P.
if nargin < 2
   p = 2;
elseif ( isempty(p) | ~isreal(p) | p<2 | floor(p)~=p | prod(size(p))~=1 | ~isprime(p) )
    error('P must be a real prime integer greater than one.');
end

% The polynomials that are stored in the database over GF(2).
if ( (p == 2) & (m <= 24) )
    switch m
        case 1
            pol = [1 1];
        case 2
            pol = [1 1 1];
        case 3
            pol = [1 1 0 1];
        case 4
            pol = [1 1 0 0 1];
        case 5
            pol = [1 0 1 0 0 1];
        case 6
            pol = [1 1 0 0 0 0 1];
        case 7
            pol = [1 0 0 1 0 0 0 1];
        case 8
            pol = [1 0 1 1 1 0 0 0 1];
        case 9
            pol = [1 0 0 0 1 0 0 0 0 1];
        case 10
            pol = [1 0 0 1 0 0 0 0 0 0 1];
        case 11
            pol = [1 0 1 0 0 0 0 0 0 0 0 1];
        case 12
            pol = [1 1 0 0 1 0 1 0 0 0 0 0 1];
        case 13
            pol = [1 1 0 1 1 0 0 0 0 0 0 0 0 1];
        case 14
            pol = [1 1 0 0 0 0 1 0 0 0 1 0 0 0 1];
        case 15
            pol = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 16
            pol = [1 1 0 1 0 0 0 0 0 0 0 0 1 0 0 0 1];
        case 17
            pol = [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 18
            pol = [1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1];
        case 19
            pol = [1 1 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 20
            pol = [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 21
            pol = [1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 22
            pol = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 23
            pol = [1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 24
            pol = [1 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
    end

% The polynomials that are stored in the database over GF(3).
elseif (p == 3) & (m <= 9)
    switch m
        case 1
            pol = [1 1];
        case 2
            pol = [2 1 1];
        case 3
            pol = [1 2 0 1];
        case 4
            pol = [2 1 0 0 1];
        case 5
            pol = [1 2 0 0 0 1];
        case 6
            pol = [2 1 0 0 0 0 1];
        case 7
            pol = [1 0 2 0 0 0 0 1];
        case 8
            pol = [2 0 0 1 0 0 0 0 1];
        case 9
            pol = [1 0 0 0 2 0 0 0 0 1];
    end

% The polynomials that are stored in the database over GF(5).
elseif (p == 5) & (m <= 5)
    switch m
        case 1
            pol = [2 1];
        case 2
            pol = [2 1 1];
        case 3
            pol = [2 3 0 1];
        case 4
            pol = [2 2 1 0 1];
        case 5
            pol = [2 4 0 0 0 1];
    end

% The polynomials that are stored in the database over GF(7).
elseif (p == 7) & (m <= 4)
    switch m
        case 1
            pol = [2 1];
        case 2
            pol = [3 1 1];
        case 3
            pol = [2 3 0 1];
        case 4
            pol = [5 3 1 0 1];
    end

else
    % Call GFPRIMFD for polynomials that are not stored in the database over GF(P>2).
    disp(['You have requested a polynomial of degree ', num2str(m), ' over GF(', num2str(p), ').']);
    disp('This polynomial is outside the range of values stored in GFPRIMDF.');
    disp('GFPRIMFD is being called to compute the primitive polynomial.');
    pol = gfprimfd(m,'min',p);
end

% -- end of gfprimdf--
