function [f,g] = brownfg(x)
%BROWNFG Nonlinear minimization test problem

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/01 16:13:02 $
%   Thomas F. Coleman 7-1-96

% Evaluate the function.
  n=length(x); y=zeros(n,1);
  i=1:(n-1);
  y(i)=(x(i).^2).^(x(i+1,1).^2+1)+(x(i+1).^2).^(x(i).^2+1);
  f=sum(y);
%
% Evaluate the gradient if nargout > 1
  if nargout > 1
     i=1:(n-1); g = zeros(n,1);
     g(i)= 2*(x(i+1).^2+1).*x(i).*((x(i).^2).^(x(i+1).^2))+...
             2*x(i).*((x(i+1).^2).^(x(i).^2+1)).*log(x(i+1).^2);
     g(i+1)=g(i+1)+...
              2*x(i+1).*((x(i).^2).^(x(i+1).^2+1)).*log(x(i).^2)+...
              2*(x(i).^2+1).*x(i+1).*((x(i+1).^2).^(x(i).^2));
  end
