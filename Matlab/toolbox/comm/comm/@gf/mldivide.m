function z = mldivide(A,b)
%MLDIVIDE Matrix left division \ of GF arrays.
%   A\B is the matrix division of A into B, which is roughly the
%   same as INV(A)*B , except it is computed in a different way.
%   If A is an N-by-N matrix and B is a column vector with N
%   components, or a matrix with several such columns, then
%   X = A\B is the solution to the equation A*X = B computed by
%   Gaussian elimination. A\EYE(SIZE(A)) produces the
%   inverse of A.
%
%   If A is an M-by-N tall matrix with M > N and B is a column
%   vector with M components, or a matrix with several such columns,
%   then X = A\B attempts to return the solution via (A'*A)\(A'*b).
%   If A'*A is not invertible, this method will fail, but
%   a solution may still exist.
%
%   If A is an M-by-N wide matrix with M < N and B is a column
%   vector with M components, or a matrix with several such columns,
%   then X = A\B attempts to return the (nonunique) solution 
%   A'*((A*A')\b). If A*A' is not invertible, this method will 
%   fail, but solutions may still exist.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.4 $  $Date: 2002/03/27 00:15:57 $ 

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

if ~isa(A,'gf'), A = gf(A,b.m,b.prim_poly); end
if size(A.x,1)>size(A.x,2)  % tall matrix
    if(det(A'*A)==0);
        error('A''*A is not invertible, so MLDIVIDE cannot find a solution. However, a solution may still exist.');
    end
    z = (A'*A)\(A'*b);      
    return
elseif size(A.x,1)<size(A.x,2)  % wide matrix
    if (det(A*A')==0);
        error('A*A''is not invertible, so MLDIVIDE cannot find a solution. However, a solution may still exist.');
    end    
    z = A'*((A*A')\b);
    return
end
if ~isa(b,'gf'), b = gf(b,A.m,A.prim_poly); end
if A.m~=b.m
    error('Orders must match.')
elseif A.prim_poly~=b.prim_poly
    error('Primitive polynomials must match.')
end

if ~isequal(A.m,GF_TABLE_M) | ~isequal(A.prim_poly,GF_TABLE_PRIM_POLY)
    [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(A);
end

% expand scalar to match size of other argument
if prod(size(A.x))==1
    A.x = A.x(ones(size(b.x)));
    z = b;
    z.x = gf_mex(A.x,A.x,A.m,'rdivide',...
        A.prim_poly,GF_TABLE1,GF_TABLE2);  % <-- element-wise multiplicitive inverse
    z.x = gf_mex(b.x,z.x,A.m,'times',...
        A.prim_poly,GF_TABLE1,GF_TABLE2);  % <-- element-wise multiplication
elseif size(A.x,1)~=size(b.x,1)
    error('matrix dimensions must agree')
else
    z = A;
    z.x = uint16(zeros(size(A.x,2),size(b.x,2)));
    [L,U,P] = lu(A);
    for i = 1:size(b.x,2)
        temp = lsolve(L,gf(double(P.x)*double(b.x(1:size(A.x,2),i)),b.m,b.prim_poly));
        temp = usolve(U,temp);      
        z.x(:,i) = temp.x;
    end
end   
