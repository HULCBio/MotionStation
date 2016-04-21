function [f,g,H] = brownfgH(x)
%BROWNFGH  Nonlinear minimization test problem

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/02/07 19:12:48 $
%   Thomas F. Coleman 7-1-96

% Evaluate the function.
  n=length(x); y=zeros(n,1);
  i=1:(n-1);
  y(i)=(x(i).^2).^(x(i+1).^2+1)+(x(i+1).^2).^(x(i).^2+1);
  f=sum(y);
%
% Evaluate the gradient.
  if nargout > 1
     i=1:(n-1); g = zeros(n,1);
     g(i)= 2*(x(i+1).^2+1).*x(i).*((x(i).^2).^(x(i+1).^2))+...
             2*x(i).*((x(i+1).^2).^(x(i).^2+1)).*log(x(i+1).^2);
     g(i+1)=g(i+1)+...
              2*x(i+1).*((x(i).^2).^(x(i+1).^2+1)).*log(x(i).^2)+...
              2*(x(i).^2+1).*x(i+1).*((x(i+1).^2).^(x(i).^2));
  end
%
% Evaluate the (sparse, symmetric) Hessian matrix
  if nargout > 2
     v=zeros(n,1);
     i=1:(n-1);
     v(i)=2*(x(i+1).^2+1).*((x(i).^2).^(x(i+1).^2))+...
            4*(x(i+1).^2+1).*(x(i+1).^2).*(x(i).^2).*((x(i).^2).^((x(i+1).^2)-1))+...
            2*((x(i+1).^2).^(x(i).^2+1)).*(log(x(i+1).^2));
     v(i)=v(i)+4*(x(i).^2).*((x(i+1).^2).^(x(i).^2+1)).*((log(x(i+1).^2)).^2);
     v(i+1)=v(i+1)+...
              2*(x(i).^2).^(x(i+1).^2+1).*(log(x(i).^2))+...
              4*(x(i+1).^2).*((x(i).^2).^(x(i+1).^2+1)).*((log(x(i).^2)).^2)+...
              2*(x(i).^2+1).*((x(i+1).^2).^(x(i).^2));
     v(i+1)=v(i+1)+4*(x(i).^2+1).*(x(i+1).^2).*(x(i).^2).*((x(i+1).^2).^(x(i).^2-1));
     v0=v;
     v=zeros(n-1,1);
     v(i)=4*x(i+1).*x(i).*((x(i).^2).^(x(i+1).^2))+...
            4*x(i+1).*(x(i+1).^2+1).*x(i).*((x(i).^2).^(x(i+1).^2)).*log(x(i).^2);
     v(i)=v(i)+ 4*x(i+1).*x(i).*((x(i+1).^2).^(x(i).^2)).*log(x(i+1).^2);
     v(i)=v(i)+4*x(i).*((x(i+1).^2).^(x(i).^2)).*x(i+1);
     v1=v;
     i=[(1:n)';(1:(n-1))'];
     j=[(1:n)';(2:n)'];
     s=[v0;2*v1];
     H=sparse(i,j,s,n,n);
     H=(H+H')/2;
  end
