% SC = schrcomp(M,n1,n2,tol)
%
% Computes the Schur complement of the symmetric matrix M
% with respect to the block  M(n1:n2,n1:n2)
%
% TOL is the relative tolerance used to regularize
% M(n1:n2,n1:n2)

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function sc=schrcomp(M,n1,n2,tol)


if nargin<4, tol=sqrt(mach_eps); end

n=size(M,1);
nM=norm(M,1);


M11=M([1:n1-1,n2+1:n],[1:n1-1,n2+1:n]);
M22=M(n1:n2,n1:n2);
M12=M([1:n1-1,n2+1:n],n1:n2);

[u,t]=schur(M22);  t=real(diag(t));  abst=abs(t);
thresh=max(mach_eps*nM,tol*max(abst));   % threshold for regularization
ind=find(abst < thresh);
t(ind)=t(ind)+thresh;                    % regularize M22

tmp=M12*u;
sc=M11-tmp*diag(1./t)*tmp';
sc=(sc+sc')/2;
