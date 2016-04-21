function mod=modstruc(a,b,c,d,k,x0,age)
%MODSTRUC  Constructs model structures to be used in MS2TH.
%   MS = MODSTRUC(A,B,C,D,K,X0)
%
%   MS = The resulting model structure.
%   A,B,C,D,K,X0 are the matrices of the state-space model
%
%   xnew = A x(t) + B u(t) + K e(t)
%   y(t) = C x(t) + D u(t) + e(t)
%
%   where xnew is x(t+T) or dx(t)/dt. X0 is the initial state.
%
%   The entries of these matrices are numerical values for the parameters
%   that are fixed, while a parameter to be estimated (a free parameter) is
%   entered as NaN in the corresponding position.
%   Example: A=[0 1;NaN NaN].
%   The default value of X0 is zeros.
%   See also CANFORM and MS2TH.

%   L. Ljung 10-2-90,13-3-93
%   revised by W. Wang 10-27-92
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:21:51 $

if nargin<5
   disp('Usage: MS = MODSTRUC(A,B,C,D,K)')
   disp('       MS = MODSTRUC(A,B,C,D,K,X0)')
   return
end
if nargin<7
   age='new';
end

[nx,nd]=size(a);
if nx ~= nd, error('The A-matrix must be square.'),end
if nargin<6, x0=zeros(nx,1);end,if isempty(x0),x0=zeros(nx,1);end
[nd,nu]=size(b);
if nx ~= nd & nu~=0, error('A and B must have the same number of rows.'),
end
[ny,nd]=size(c);
if nx ~= nd, error('A and C must have the same number of columns.'),
end
[nd1,nd2]=size(d);
if nd1 ~= ny & nu~=0, error('D and C must have the same number of rows.'),end
if nd2 ~= nu, error('D and B must have the same number of columns.'),
end
[nd1,nd2]=size(k);
if nd1 ~= nx, error('K and A must have the same number of rows.'),
end
if nd2 ~= ny, error('The number of columns in K must equal the number of rows in C.'),end
[nd1,nd2]=size(x0);
if nd1~=nx, error('X0 and A must have the same number of rows.'),end
if nd2 ~= 1, error('X0 must be a column vector.'),end
if ~strcmp(age,'old')
mod.as=a;
mod.bs=b;
mod.cs=c;
mod.ds=d;
mod.ks=k;
mod.x0s=x0;
else
   mod(1:nx,1:nx)=a;
if nu>0, mod(1:nx,nx+1:nx+nu)=b;end
mod(1:nx,nx+nu+1:nx+nu+ny)=c';
if nu>0, mod(1:ny,nx+nu+ny+1:nx+2*nu+ny)=d;end
nn=nx+2*(nu+ny);
mod(1:nx,nx+2*nu+ny+1:nn)=k;
mod(1:nx,nn+1:nn+1)=x0;
mod(1,nn+2)=ny;
mod(2,nn+2)=nx;
end
%end of modstruc.m
