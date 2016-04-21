function X1 = pinv(A1,Tol)
% Embedded MATLAB Library function.
% 
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/dsp/pinv.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/04/01 16:07:13 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(A1), 'error', ['Function ''pinv'' is not defined for values of class ''' class(A1) '''.']);

if isempty(A1),
   X1 = A1;
   return;
end;

[q,r] = size(A1);

if r > q
   A=A1';
   m=r;
   n=q;
   do_trans=1;
else
   A=A1; 
   m=q;
   n=r;
   do_trans=0;
end
% Initialize parameters
if(isreal(A))
%     U = zeros(m,n,class(A));
%     S = zeros(n,1,class(A));
    V = zeros(n,n,class(A)); 
    X = zeros(n,m,class(A));
    V_sinv=V;
else
%     U = complex(zeros(m,n,class(A)));
%     S = zeros(n,1,class(A));
    V = complex(zeros(n,n,class(A)));
    X = complex(zeros(n,m,class(A)));
    V_sinv=V;
end
[U,S,V] = svd(A, 'econ');

if m > 1
    if size(S,1)==1 || size(S,2)==1
        s=S;
    else
        s=diag(S);
    end
elseif m == 1, s = S(1);
else s = 0;
end
   
if nargin == 2
   tol = Tol;
else
    tol = max(m,n) * max(real(s)) * eps(class(A));
end   


r = sum(s > tol);

% Do matrix multiplication
for i=1:r
    sinv=1/s(i);
    for j=1:n
        V_sinv(j,i)=V(j,i)*sinv;
    end
end
for j=1:m
    for i=1:n
        for k=1:r
            X(i,j) = X(i,j)+V_sinv(i,k)*conj(U(j,k));
        end
    end
end

% Transpose pseudoinverse if necesscary
if do_trans == 1
    X1=X';
else
    X1=X;
end
