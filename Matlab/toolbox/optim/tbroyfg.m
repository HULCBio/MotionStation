function [f, grad] = tbroyfg(x,dummy)
%TBROYFG Test problem

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2004/02/07 19:13:59 $
%   Thomas F. Coleman 7-1-96

n=length(x);  % n should be a multiple of 4

p=7/3; y=zeros(n,1);
i=2:(n-1);
y(i)= abs((3-2*x(i)).*x(i)-x(i-1)-x(i+1)+1).^p;
y(n)= abs((3-2*x(n)).*x(n)-x(n-1)+1).^p;
y(1)= abs((3-2*x(1)).*x(1)-x(2)+1).^p;
j=1:(n/2); z=zeros(length(j),1);
z(j)=abs(x(j)+x(j+n/2)).^p;
f=1+sum(y)+sum(z);
%
% Evaluate the gradient.
if nargout > 1
   p=7/3; n=length(x); g = zeros(n,1); t = zeros(n,1);
   i=2:(n-1);
   t(i)=(3-2*x(i)).*x(i)-x(i-1)-x(i+1)+1;
   g(i)= p*abs(t(i)).^(p-1).*sign(t(i)).*(3-4*x(i));
   g(i-1)=g(i-1)-p*abs(t(i)).^(p-1).*sign(t(i));
   g(i+1)=g(i+1)-p*abs(t(i)).^(p-1).*sign(t(i));
   tt = (3-2*x(n)).*x(n)-x(n-1)+1;
   g(n)=g(n)+p*abs(tt).^(p-1).*sign(tt).*(3-4*x(n));
   g(n-1)=g(n-1)-p*abs(tt).^(p-1).*sign(tt);
   tt=(3-2*x(1)).*x(1)-x(2)+1;
   g(1)=g(1)+p*abs(tt).^(p-1).*sign(tt).*(3-4*x(1));
   g(2)=g(2)-p*abs(tt).^(p-1).*sign(tt);
   j=1:(n/2); t(j)=x(j)+x(j+n/2);
   g(j) = g(j)+p*abs(t(j)).^(p-1).*sign(t(j));
   jj=j+(n/2);
   g(jj) = g(jj)+p*abs(t(j)).^(p-1).*sign(t(j));
   grad = g;
end
