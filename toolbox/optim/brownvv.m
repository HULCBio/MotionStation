function [f,g,Hinfo] = brownvv(x,V)
%BROWNVV Nonlinear minimization with dense structured Hessian
% [F,G,HINFO] = BROWNVV(X,V) computes objective function F, the gradient
% G and part of the Hessian of F in HINFO, i.e.
%       F = FHAT(X) - 0.5*X'*V*V'*X
%       G is the gradient of F, i.e. 
%            G = gradient of FHAT(X) - V*V'*X
%       Hinfo is the Hessian of FHAT 
%       (H is not formed as it is dense but
%            H = Hinfo - V*V'.  see HMFBX4)

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2004/02/07 19:12:49 $

  n=length(x); y=zeros(n,1);
  i=1:(n-1);
  y(i,1)=(x(i,1).^2).^(x(i+1,1).^2+1)+(x(i+1,1).^2).^(x(i,1).^2+1);
  f = sum(y);
  extra = V'*x; 
  f = f - .5*extra'*extra;

% Evaluate the gradient.
  if nargout > 1
     i=1:(n-1); g = zeros(n,1);
     g(i,1)= 2*(x(i+1,1).^2+1).*x(i,1).*((x(i,1).^2).^(x(i+1,1).^2))+...
             2*x(i,1).*((x(i+1,1).^2).^(x(i,1).^2+1)).*log(x(i+1,1).^2);
     g(i+1,1) = g(i+1,1)+...
                2*x(i+1,1).*((x(i,1).^2).^(x(i+1,1).^2+1)).*log(x(i,1).^2)+...
                2*(x(i,1).^2+1).*x(i+1,1).*((x(i+1,1).^2).^(x(i,1).^2));
    g = g - V*extra;
  end

% Evaluate the Hessian matrix of FHAT, but not F.
  if nargout > 2
     v=zeros(n,1);
     i=1:(n-1);
     v(i,1) = 2*(x(i+1,1).^2+1).*((x(i,1).^2).^(x(i+1,1).^2))+...
              4*(x(i+1,1).^2+1).*(x(i+1,1).^2).*(x(i,1).^2).*((x(i,1).^2).^((x(i+1,1).^2)-1))+...
              2*((x(i+1,1).^2).^(x(i,1).^2+1)).*(log(x(i+1,1).^2));
     v(i,1) = v(i,1)+4*(x(i,1).^2).*((x(i+1,1).^2).^(x(i,1).^2+1)).*((log(x(i+1,1).^2)).^2);
     v(i+1,1) = v(i+1,1)+...
                2*(x(i,1).^2).^(x(i+1,1).^2+1).*(log(x(i,1).^2))+...
                4*(x(i+1,1).^2).*((x(i,1).^2).^(x(i+1,1).^2+1)).*((log(x(i,1).^2)).^2)+...
                2*(x(i,1).^2+1).*((x(i+1,1).^2).^(x(i,1).^2));
     v(i+1,1) = v(i+1,1)+4*(x(i,1).^2+1).*(x(i+1,1).^2).*(x(i,1).^2).*((x(i+1,1).^2).^(x(i,1).^2-1));
     v0 = v;
     v = zeros(n-1,1);
     v(i,1) = 4*x(i+1,1).*x(i,1).*((x(i,1).^2).^(x(i+1,1).^2))+...
              4*x(i+1,1).*(x(i+1,1).^2+1).*x(i,1).*((x(i,1).^2).^(x(i+1,1).^2)).*log(x(i,1).^2);
     v(i,1) = v(i,1)+ 4*x(i+1,1).*x(i,1).*((x(i+1,1).^2).^(x(i,1).^2)).*log(x(i+1,1).^2);
     v(i,1) = v(i,1)+4*x(i,1).*((x(i+1,1).^2).^(x(i,1).^2)).*x(i+1,1);
     v1 = v;
     i = [(1:n)';(1:(n-1))'];
     j = [(1:n)';(2:n)'];
     s = [v0;2*v1];
     Hinfo = sparse(i,j,s,n,n);
     Hinfo = (Hinfo+Hinfo')/2;
  end
