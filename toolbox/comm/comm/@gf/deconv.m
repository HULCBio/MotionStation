function [quotient, remainder] = deconv(b,a)
%DECONV Deconvolution and polynomial division.
%   [Q,R] = DECONV(B,A) deconvolves a Galois field vector A out
%   of a Galois field vector B. The result is returned in vector Q
%   and the remainder in vector R such that
%   B = conv(A,Q) + R.
%
%   If A and B are vectors of polynomial coefficients, deconvolution
%   is equivalent to polynomial division.  The result of dividing B by
%   A is quotient Q and remainder R.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 20:11:21 $

if a.m~=b.m
    error('Orders must match.')
elseif a.prim_poly~=b.prim_poly
    error('Primitive polynomials must match.')
end

b_size = size(b);
a_size = size(a);

if(length(a_size) > 2 | length(b_size) > 2 )
    error('Input must be a vector');
end

% error out on matrix
if( min(b_size)~= 1 | min(a_size) ~= 1)
    error('Input must be a vector')
end

if(find(a_size==1) == find(b_size==1))
    poly_a = a;
else
    poly_a = a';
    a_size = fliplr(a_size);
end

poly_b = b;

quotient = gf(zeros(b_size(1)-a_size(1)+1, b_size(2)-a_size(2)+1), a.m, a.prim_poly);

for i = 1:(length(b)-length(a)+1)
    coeff =  gf(poly_b.x(1), poly_b.m, poly_b.prim_poly)/gf(poly_a.x(1), poly_a.m, poly_a.prim_poly);
    quotient.x(i) = coeff.x;
    for j = 1:length(a)
        temp = gf(poly_b.x(j), poly_b.m, poly_b.prim_poly) - coeff * gf(poly_a.x(j),poly_b.m, poly_b.prim_poly);        
        poly_b.x(j) = temp.x;
    end
    temp = poly_b.x(2:length(b)-i+1);
    poly_b.x = temp;
end
if nargout>1,
    remainder = b - conv(poly_a,quotient);
end


