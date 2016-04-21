function roots = roots(x);
%ROOTS  Find polynomial roots in a Galois field.
%   ROOTS(C) computes the roots of the polynomial whose coefficients
%   are the elements of the vector C. If C has N+1 components,
%   the polynomial is C(1)*X^N + ... + C(N)*X + C(N+1).

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 20:11:25 $

if ((size(x,1)>1 & size(x,2)>1) | length(size(x)) == 3  )
    error('Must be a vector.')
end

roots = [];

x = reshape(x,1, max(size(x)));

n = size(x,2);
inz = find(x~=0);
if isempty(inz),
    % All elements are zero
    return
end
% Strip leading zeros and throw away.  
% Strip trailing zeros, but remember them as roots at zero.
nnz = length(inz);
temp = x.x(inz(1):inz(nnz));
x.x = temp;
if(n-inz(nnz)>0)
    r = zeros(1,n-inz(nnz));
else r = [];
end

x = fliplr(x);

i = 0;
while i<2^x.m
    d = gf(i,x.m,x.prim_poly);
    y = x*(d.^[0:length(x)-1]');
    if(y==0),  % if y is zero, we have a root. now, need to check for multplicities
        roots = [roots i];
        
        factor = 1./gf([1 i], x.m, x.prim_poly);      % deconvolve the root we just found
                                                      % from x1                                                  
        x = deconv(x,factor);
        i = i-1;                                %decrement i, and check again        
    end
    i = i+1;
end

roots = gf(roots,x.m, x.prim_poly);
% add the zero roots back in 
roots = [r roots];
roots = reshape(roots,max(size(roots)),1);
