function [out1,out2,out3,out4,out5,out6]=...
          ssssaux(type,arg1,arg2,arg3,arg4,arg5,arg6,arg7)
%SSSSAUX Auxiliary file to n4sid.

%   M. Viberg, T. McKelvey, and L. Ljung 94-09-27
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $ $Date: 2004/04/10 23:20:29 $

if strcmp(type,'kric')
   a=arg1';b=arg2';q=arg3;r=arg4;nn=arg5;
%   r=(r+r')/2;q=(q+q')/2;
   q=q-nn/r*nn';
   a1=a-b/r*nn';
   [n,ndum]=size(a);
   [v,d] = eig([a1+b/r*b'/a1'*q  -b/r*b'/a1'; -a1'\q  pinv(a1)']);

   d = diag(d);
   [e,index] = sort(abs(d));    % sort on magnitude of eigenvalues
   out2 = 0;
   if (~((e(n) < 1) & (e(n+1)>1)))
      warning('Can''t order eigenvalues.');
      out2 = 1;
   else
      e = d(index(1:n));
   end

chi = v(1:n,index(1:n));
if min(svd(chi))<10*eps
   warning('Estimation problem ill-conditioned.')
   out = 2;
   end
   lambda = v((n+1):(2*n),index(1:n));
   s = real(lambda/chi)';
   k = (a'*s*b+nn)/(b'*s*b+r);
%   k = (r+b'*s*b)\b'*s*a + r\nn';

   out1=k;
elseif strcmp(type,'gsvd')
  A=arg1;
  B=arg2;
%
% Calculates the generalized singular value decomposition of the matrices
% A and B such that
%
%   A = U*C*X',   U*U'=I and C diagonal
%
%   B = V*S*X',    V*V'=I and S diagonal
[na,dum]=size(A);
[nb,dum]=size(B);
comp=computer;
if strcmp(comp(1:2),'PC')
  [Q,R]=qr([A;B]);[nr,nc]=size([A;B]);nrr=nc;
  Q=Q(:,1:nrr);R=R(1:nrr,:);
else
  [Q,R]=qr([A;B],0);
end
[U,C,W]=svd(Q(1:na,:),0);
[V,S,W2]=svd(Q(na+1:na+nb,:),0);
X = R'*W;
T=inv(W)*W2;
V = V*T';
S = T*S*T';
out1=U;out2=C;out3=X;out4=V;out5=S;

elseif  strcmp(type,'idblockh')
% IDBLOCKH Constructs Block Hankel Matrix. Subroutine to SSSS
%
% M = idblockh(x,i,j)
%
% Constructs Hankel matrix of signal x (possibly
% multicolumn):
% x = [x(1:N,1:p)] , N = no data, p = no components
%
%     [x(1,:)' x(2,:)'   ...   x(j,:)']
%     [x(2,:)'           ...          ]
%     [                               ]
% M = [ ...                           ]
%     [                               ]
%     [x(i,:)' x(i+1,:)' ...   x(N,:)']

%    Mats Viberg, 8-13-1992, L. Ljung 9-26-1993.

 x=arg1;i=arg2;
[N,p] = size(x);

if nargin < 4
   j = N-i+1;
else
   j=arg3;
end

M = zeros(p*i,j);

for ii = 1:i
   M((ii-1)*p+1:ii*p,1:j) = x(ii:j+ii-1,:)';
end
out1=M;

elseif strcmp(type,'idblockc')
X=arg1;blsz=arg2;
% IDBLOCKC Manipulates block columns. Subroutine to SSSS
%
% X = [X1 , X2 , ... , XN] converted into
%
%     [X1]
%     |X2|
% H   |. |
%     |. |
%     [XN]

%    Mats Viberg, 8-13-1992, L. Ljung 9-26-1993.

[m,nn] = size(X);

no_blocks = nn/blsz;
H = zeros(m*no_blocks,blsz);

for k = 1:no_blocks
    H( (k-1)*m+1:k*m,: ) = X(:, (k-1)*blsz+1:k*blsz );
end
out1=H;
elseif strcmp(type,'idspech')
X=arg1;blsz=arg2;
% IDSPECH Construcs a special Hankel matrix. Subroutine to SSSS
%
%   X = [X1 , X2 , ... , XN] converted into
%
%    [X1  X2  ...  XN-1 XN]
%    |X2  X3  ...   XN   0|
% H= |.                   |
%    |.                   |
%    [XN   0  ...        0]

%    Mats Viberg, 8-13-1992, L. Ljung 9-26-1993.

[m,nn] = size(X);

no_blocks = nn/blsz;
H = zeros(m*no_blocks,blsz*no_blocks);

for k = 1:no_blocks
    H( (k-1)*m+1:k*m,: ) = [X(:, (k-1)*blsz+1:nn ) zeros(m,(k-1)*blsz)];
end
out1=H;
elseif strcmp(type,'expand')
a=arg1;b=arg2;c=arg3;d=arg4;k=arg5;x=arg6;nk=arg7;
[n,dum]=size(a);[dum,nu]=size(b);[ny,dum]=size(c);
nk1=nk-1;
nkind=find(nk1>0);
newst=nk1(nkind);
stateind=cumsum(newst);naux=sum(newst);
if naux==0,out1=a;out2=b;out3=c;out4=d;out5=k;out6=x;return,end
anew=[[a,zeros(n,naux)];...
      zeros(1,n+naux);...
      [zeros(naux-1,n),eye(naux-1,naux-1),zeros(naux-1,1)]];

bnew=[b;zeros(naux,nu)];cnew=[c,zeros(ny,naux)];
knew=[k;zeros(naux,ny)];
xnew=[x;zeros(naux,1)];
anew(1:n,n+stateind)=b(:,nkind);
bnew(:,nkind)=zeros(n+naux,length(nkind));
arowind=[n+1,stateind+n+1];
for kk=1:length(nkind),
    bnew(arowind(kk),nkind(kk))=1;
    anew(arowind(kk),arowind(kk)-1)=0;
end
out1=anew;out2=bnew;out3=cnew;out4=d;out5=knew;out6=xnew;
end
