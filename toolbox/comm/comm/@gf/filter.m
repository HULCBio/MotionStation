function [Y, Zf] = filter(B, A, X)
%FILTER One-dimensional digital filter over a Galois field.
%   Y = FILTER(B, A, X) filters the data in vector X with the
%   filter described by vectors A and B to create the filtered
%   data Y.  The filter is a "Direct Form II Transposed"
%   implementation of the standard difference equation:
%
%   a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
%                         - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
%
%   If a(1) is not equal to 1, FILTER normalizes the filter
%   coefficients by a(1). 
%
%   [Y, Zf] = FILTER(B, A, X) gives access to the final
%   conditions, Zf, of the delays. 

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 20:11:23 $

% Get the right gf objects set up
flag = 0;
if isa(B,'gf'), flag = 1; end
if isa(A,'gf'), flag = 2; end
if isa(X,'gf'), flag = 3; end
switch flag
case 1
    if ~isa(A,'gf'), A = gf(A, B.m, B.prim_poly); end
    if ~isa(X,'gf'), X = gf(X, B.m, B.prim_poly); end
case 2
    if ~isa(B,'gf'), B = gf(B, A.m, A.prim_poly); end
    if ~isa(X,'gf'), X = gf(X, A.m, A.prim_poly); end
case 3
    if ~isa(B,'gf'), B = gf(B, X.m, X.prim_poly); end
    if ~isa(A,'gf'), A = gf(A, X.m, X.prim_poly); end
end

% Confirm all objects are of same type
if (B.m~=A.m | B.m~= X.m)
    error('Orders must match.')
elseif( B.prim_poly~=A.prim_poly | B.prim_poly ~= X.prim_poly)
    error('Primitive polynomials must match.')
end

% a,b,x must be vectors
if ((size(X,1)>1 & size(X,2)>1) | length(size(X)) == 3  )
    error('X must be a vector.')
end

if ((size(A,1)>1 & size(A,2)>1) | length(size(A)) == 3  )
    error('A must be a vector.')
end

if ((size(B,1)>1 & size(B,2)>1) | length(size(B)) == 3  )
    error('B must be a vector.')
end

% Check that the first value of A is not zero
if(A(1)==0)
    error('The first element of A can not be zero.');
end

% Normalize the coefficients
if(A(1)~=1)
    A = A/A(1);
    B = B/A(1);
end

% if length(A) > length(B), zero-pad b
if(length(A)>length(B))
    % pad B 
    if (size(B,1)>1) % column vector
        Bpad = [B; gf(zeros(length(A) - length(B), 1), B.m, B.prim_poly)];
    else
        Bpad = [B, gf(zeros(1, length(A) - length(B)), B.m, B.prim_poly)];
    end
else
    Bpad = B; 
end

% if length(B) > length(A), zero-pad a
if(length(B)>length(A))
    % pad A
    if (size(A,1)>1) % column vector
        Apad = [A; gf(zeros(length(B)-length(A), 1), A.m, A.prim_poly)];
    else
        Apad = [A, gf(zeros(1, length(B)-length(A)), A.m, A.prim_poly)];    
    end
else
    Apad = A;
end

% Compute the output of the FIR filter
firOut = conv(Bpad,X);

% Comput the output of the IIR filter
if(nargout < 2)
    Y = deconv(firOut,Apad);
elseif(nargout == 2)
    [Y Zf] = deconv(firOut,Apad); 
    
    % chop off the extra points of Zf
    Zf.x = Zf.x( (length(Zf) - max(length(A),length(B)) +2 ) :end)';
end

% [EOF]
