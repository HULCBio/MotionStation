% function [x]=axxbc(a,b,c)
%
%   Solves the equation a*x+x*b=c, using the function SYLV.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [x]=axxbc(a,b,c)
if nargin < 3
  disp(['usage: x = axxbc(a,b,c)']);
  return
end
[n,p]=size(a);
[q,m]=size(b);if (p~=n)|(q~=m),error('dimensions wrong in axxbc');end;
[p,q]=size(c);if (p~=n)|(q~=m),error('dimensions wrong in axxbc');end;
[u,a]=schur(a');a=a';
[v,b]=hess(b);
c=u'*c*v;
x=zeros(n,m);
% set hard zeros in the Schur form for a
for i=1:n-1,
   s=abs(a(i,i))+abs(a(i+1,i+1));
   if s+abs(a(i,i+1))==s,
      a(i,i+1)=0;
    end; % if s+abs(a(i,i+1))==s
 end; % for i=1:n-1
for i=1:n-2,  % check no adjacent nonzeros on super-diag
   if a(i,i+1)~=0 & a(i+1,i+2)~=0,
      if abs(a(i,i+1))<abs(a(i+1,i+2)),
          a(i,i+1)=0;
        else a(i+1,i+2)=0
      end; % if abs(a(i,i+1))
    end; % if a(i,i+1)~=0
 end; % for i=1:n-2
bl=1;bsz=[];
for i=1:n-1,
  if a(i,i+1)==0,bsz=[bsz,bl];bl=1;
  else bl=2;end
end
bsz=[bsz,bl];
[ss,s]=size(bsz);bst=zeros(1,s);
bst(1)=1;
for i=1:s-1,bst(i+1)=bst(i)+bsz(i);end
if bsz(1)==1,x(1,:)=c(1,:)/(a(1,1)*eye(m)+b);...
else y=sylv(a(1:2,1:2),b,c(1:2,:));x(1:2,:)=y;end
for i=2:s,
  t=bst(i);
  if bsz(i)==1,x(t,:)=(c(t,:)-a(t,1:t-1)...
    *x(1:t-1,:))/(a(t,t)*eye(m)+b);...
  else y=sylv(a(t:t+1,t:t+1),b,...
    c(t:t+1,:)-a(t:t+1,1:t-1)*x(1:t-1,:));
    x(t:t+1,:)=y;
  end
end
x=u*x*v';