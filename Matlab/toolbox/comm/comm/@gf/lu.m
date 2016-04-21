function [L,U,P] = lu(A)
%LU  Lower-upper triangular factorization of GF array.
%   [L,U,P] = LU(X) performs Gaussian elimination on the square 
%   GF matrix X and returns arguments as does the LU function 
%   of MATLAB for double matrices.  Specifically:
%
%   [L,U] = LU(X) stores an upper triangular matrix in U and a
%   "psychologically lower triangular matrix" (i.e. a product
%   of lower triangular and permutation matrices) in L, so
%   that X = L*U.  X must be square.
%
%   [L,U,P] = LU(X) returns lower triangular matrix L, upper
%   triangular matrix U, and permutation matrix P so that
%   P*X = L*U.
%
%   See also LSOLVE, USOLVE, INV.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.5.4.1 $  $Date: 2002/11/13 16:53:08 $ 

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

n=length(A);
U=A;
if ~isequal(U.m,GF_TABLE_M) | ~isequal(U.prim_poly,GF_TABLE_PRIM_POLY)
    [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(U);
end
%  piv=A;
piv=zeros(1,n);
for k=1:n-1,
    %max_row = find(U(k:n,k)==max(U(k:n,k))) + k - 1;  % find maximums
    max_row = find(U.x(k:n,k)~=0) + k - 1;  % find non zero elements
    if isempty(max_row)
        error('matrix not invertible')
    end
    max_row = max_row(1);        % allow for repeated maximums
    if (max_row ~= k),
        U.x([k max_row],1:n) = U.x([max_row k],1:n);  % swap rows
    end;
    piv(k) = max_row;
    %U(k+1:n,k) = U(k+1:n,k)/U(k,k);
    Ukk_inv = gf_mex(U.x(k,k),U.x(k,k),U.m,'rdivide',...
        A.prim_poly,GF_TABLE1,GF_TABLE2);
    U.x(k+1:n,k) = gf_mex(U.x(k+1:n,k),Ukk_inv(ones(length(k+1:n),1)),U.m,'times',...
        A.prim_poly,GF_TABLE1,GF_TABLE2);
    % U(k+1:n,k+1:n) = U(k+1:n,k+1:n) - U(k+1:n,k)*U(k,k+1:n);
    temp = gf_mex(U.x(k+1:n,k),U.x(k,k+1:n),U.m,'mtimes',...
        A.prim_poly,GF_TABLE1,GF_TABLE2);
    U.x(k+1:n,k+1:n) = gf_mex(U.x(k+1:n,k+1:n),temp,U.m,'plus',...
        A.prim_poly,GF_TABLE1,GF_TABLE2);
end;

%    L=tril(U)+eye(U)-diag(diag(U));
L=A;
L.x=uint16(eye(n));
for i=2:n
    L.x(i,1:i-1)=U.x(i,1:i-1);
end;
U.x=triu(U.x);

% Create Permutation matrix:
P=A;
P.x=uint16(eye(n));    % start with identity
for k=1:n-1,
    P.x([k piv(k)],:)=P.x([piv(k) k],:);   % exchange row k with row p(k)
end;

% Adjust L according to the Permutation matrix
if(nargout==2)
    L = P'*L;
end
