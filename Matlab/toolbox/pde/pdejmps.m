function [EjK,fm] = pdejmps(p,t,c,a,f,u,alfa,beta,m)
%PDEJMPS Error estimates for adaption.
%
%       ERRF=PDEJMPS(P,T,C,A,F,U,ALFA,BETA,M) calculates the error
%       indication function used for adaption. The columns of ERRF
%       correspond to triangles, and the rows correspond to the
%       different equations in the PDE system.
%
%       P and T are mesh data. See INITMESH for details.
%
%       C, A, and F are PDE coefficients. See ASSEMPDE for details.
%       C, A, and F, must be expanded, so that columns corresponds
%       to triangles.
%
%       U is the current solution, given as a column vector.
%       See ASSEMPDE for details.
%
%       The formula for calculating ERRF(:,K) is
%       ALFA*L2K(H^M (F - AU)) + BETA SQRT(0.5 SUM((L(J)^M JMP(J))^2))
%       where L2K is the L2 norm on triangle K, H is the linear
%       size of triangle K, L(J) is the length of the J:th side,
%       the SUM ranges over the three sides, and JMP(J) is change
%       in normal derivative over side J.

%       J. Oppelstrup 10-24-94, AN 12-05-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 2002/04/14 22:14:03 $

nnod=size(p,2);
nel=size(t,2);
% Number of variables
N=size(u,1)/nnod;

% Perhaps expand c, a, and f here?

% compute areas and side lengths
[sl,ar]= pdetridi(p,t);

% fluxes through edges
ddncu= pdenrmfl(p,t,c,u,ar,sl);

% L2 norm of (f - au) over triangles
%    f and a are element data and u node:
cc=pdel2fau(p,t,a,f,u,ar);
% multiply by triangle diameters

cc = cc.*(ones(N,1)*max(sl).^m);
%    flux jumps computed by assembly of ddncu into nnod x nnod sparse matrix
%    jmps(i,j) becomes abs(jump across edge between nodes i and j).
%    note that sparse(...) accepts duplicates of indices and performs
%    summation ! (i.e., the flux differences )
ccc  = zeros(N,nel);

intj=sparse(t([2 3 1],:),t([3 1 2],:),1,nnod,nnod);
% intj+intj.' is 2 if interior edge and 1 if exterior edge
% Keep the interior only
intj=round((intj+intj.')/3);

for k=1:N
  jmps = sparse(t([2 3 1],:),t([3 1 2],:),ddncu([1 2 3]+3*(k-1),:),nnod,nnod);
  jmps = intj.*abs(jmps + jmps.');
  for l = 1:nel
    ccc(k,l) = (sl(3,l)^m*abs(jmps(t(1,l),t(2,l))))^2+...
               (sl(1,l)^m*abs(jmps(t(2,l),t(3,l))))^2+...
               (sl(2,l)^m*abs(jmps(t(3,l),t(1,l))))^2;
  end
end
EjK = alfa*cc + beta*sqrt(0.5*ccc);

