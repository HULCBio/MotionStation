function [Bnull,Borth]=pdenullorth(H)
%PDENULLORTH Orthonormal basis for nullspace of H and its complement.

%       A. Nordmark 12-27-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:10:11 $

nu=size(H,2);

var=zeros(nu,1);

i=find(sum(abs(H),2));
H=H(i,:);

[k,l]=find(H);
if length(k)==0
  Bnull=speye(nu,nu);
  Borth=zeros(nu,0);
  return;
end

var(l)=ones(size(l));
v1=find(var);
v2=find(var==0);

HH=H(:,v1);
% dmperm gives a large first block and/or last block.
% Perhaps these should be broken up.
[p,q,r,s]=dmperm(HH);

l=length(r);
rs=r(2:l)-r(1:l-1); % Block row lengths
cs=s(2:l)-s(1:l-1); % Block column lengths

ccs=cs*cs'; % Total number of elements
% Now some space for indices and elements
in1=zeros(ccs,1);
in2=zeros(ccs,1);
bn=zeros(ccs,1);
io1=zeros(ccs,1);
io2=zeros(ccs,1);
bo=zeros(ccs,1);

nn=0; % Number of elements in Bnull
nrn=0; % Number of columns Bnull
no=0; % Number of elements in Borth
nro=0; % Number of elements in Borth

for k=1:l-1
  if cs(k)==1 % Simple case
    rank=1;
    null=[];
    orth=1;
  else % Use svd
    h=full(HH(p(r(k):r(k+1)-1),q(s(k):s(k+1)-1)));
    [U,S,V]=svd(h);
    if rs(k) ~= 1, ss = diag(S); else ss = S(1,1); end
    tol = max(rs(k),cs(k)) * max(s) * eps;
    rank = sum(ss > tol);
    null = V(:,rank+1:cs(k));
    orth=V(:,1:rank);
  end

  in1(nn+1:nn+cs(k)*(cs(k)-rank))=v1(q(s(k):s(k+1)-1))*ones(1,cs(k)-rank);
  in2(nn+1:nn+cs(k)*(cs(k)-rank))=ones(cs(k),1)*(nrn+1:nrn+cs(k)-rank);
  bn(nn+1:nn+cs(k)*(cs(k)-rank))=null;

  io1(no+1:no+cs(k)*rank)=v1(q(s(k):s(k+1)-1))*ones(1,rank);
  io2(no+1:no+cs(k)*rank)=ones(cs(k),1)*(nro+1:nro+rank);
  bo(no+1:no+cs(k)*rank)=orth;

  nn=nn+cs(k)*(cs(k)-rank);
  nrn=nrn+cs(k)-rank;
  no=no+cs(k)*rank;
  nro=nro+rank;

end

Bnull=sparse(in1(1:nn),in2(1:nn),bn(1:nn),nu,nrn);
Borth=sparse(io1(1:no),io2(1:no),bo(1:no),nu,nro);

if size(Bnull,2)>0
  Bnull=[Bnull sparse(v2,1:length(v2),1,nu,length(v2))];
else
  Bnull=sparse(v2,1:length(v2),1,nu,length(v2));
end

% XXX Fix empty sparse matrices
if size(Bnull,2)==0
  Bnull=zeros(nu,0);
end
