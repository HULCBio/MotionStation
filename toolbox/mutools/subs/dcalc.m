% function  d = dcalc(b,c,sig,q)
%
% Calculates a D matrix such that the L-infinity norm of
%  (C(sI-A)^(-1)B+D) is <= sig(1)+...+sig(n).
%  B and C are from a balanced realisation with n states,
%  SIG is the vector of hankel singular values.
%  Q is the dimension in which the system is embedded.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function d = dcalc(b,c,sig,q)

n=sum(sign(sig));if n<1,error('n<1');end;
[nn,m]=size(b);[p,nn]=size(c);
if nargin<4, q=m+p;end
if q<m+p,q=m+p;end;
d=zeros(p,m);
z=[b';zeros(q-m,n)];
y=[c;zeros(q-p,n)];
signd=-1;u=zeros(q,q);
oneq=ones(q,1);
i=0;r=1;
while i+r<=n,
  i=i+r;
 % test for repeated sig(i)
  r=1;
  if i<n,
    while (sig(i+r-1)<1.001*sig(i+r)),
      r=r+1;
      if i+r>n, break; end;
     end; %while (sig(i)<
   end; %if i<n
  if r==1,
    a1=norm(y(:,i))*sign(y(1,i)+eps);
    y(1,i)=y(1,i)+a1;
    pi1=a1*y(1,i);
    a2=norm(z(:,i))*sign(z(1,i)+eps);
    z(1,i)=z(1,i)+a2;
    pi2=a2*z(1,i);
    bet=-a1/a2;
    u=eye(q)-y(:,i)*(y(:,i))'/pi1;
    u(:,1)=u(:,1)*bet;
    u(:,2:m+p-1)=u(:,[p+1:m+p-1,2:p]);
    u=u-u*z(:,i)*(z(:,i))'/pi2;
  else, %if r=1
    [uc,sc,vc]=svd(y(:,i:i+r-1));
    [ub,sb,vb]=svd(z(:,i:i+r-1)*vc);
    rb=rank(z(:,i:i+r-1));
    u=-uc*[vb(1:rb,1:rb) zeros(rb,q-rb); zeros(q-rb,rb) eye(q-rb)]*ub';
  end;%if r=1
% update z & y
  if i~=n-r+1,
    gam=oneq*sqrt(sig(i)^2*ones(1,n-i-r+1)-(sig(i+r:n))'.^2);
    tmp=-(y(:,i+r:n).*(oneq*(sig(i+r:n))')+u*z(:,i+r:n)*sig(i))./gam;
    z(:,i+r:n)=(z(:,i+r:n).*(oneq*(sig(i+r:n))')+u'*y(:,i+r:n)*sig(i))./gam;
    y(:,i+r:n)=tmp;
  end; %if i~=n-r+1
  signd=-signd;
  d=d+signd*sig(i)*u(1:p,1:m);
end;%while i<n


%
%