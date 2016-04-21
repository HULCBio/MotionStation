function[VV] = nlsmm3(A,UU,flag,S);
%NLSMM3 Structured matrix multiply (snlsf3)
%
% Components of the Jacobian matrix, Jac, are stored in array A.
%
% Compute VV = Jac'*Jac*UU (flag =0)
%         VV = Jac*UU      (flag > 0) .
%         VV = Jac'*UU     (flag < 0)
%
% S is not used
%
%*************************************************************************

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/02/07 19:13:21 $

  if nargin <= 3, flag = 0; end
  [n,m]  = size(UU);
  
  Jtil = A(:,1:n); 
  Jbar = A(:,n+1:2*n); 
  R = A(:,2*n+1:3*n); 
  p = A(:,3*n+1);
  VV = zeros(n,m);
  
  for k = 1: m
      y = UU(:,k);
      if flag == 0 % compute vec = Jac'*Jac*y
         w = Jtil*y; 
         ww = R'\w(p);
         w(p) = R\ww;
         y = Jbar*w;
         w = Jbar'*y;     
         ww = R'\w(p);
         w(p) = R\ww;
         vec = Jtil'*w;
      elseif flag > 0 % compute vec =  Jac*y
         w = Jtil*y; 
         ww = R'\w(p);
         w(p) = R\ww;
         vec = Jbar*w;
      else % compute vec = Jac'*y
         w = Jbar'*y;
         ww = R'\w(p);
         w(p) = R\ww;
         vec = Jtil'*w;
      end
      VV(:,k) = vec;
   end
