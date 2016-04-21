function F = nlsf1a(x)
%NLSF1A Nonlinear vector function
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2004/02/07 19:13:19 $
%   Thomas F. Coleman 7-1-96

%
% Evaluate the vector function
  n = length(x);
  F = zeros(n,1);
  i=2:(n-1);
  F(i)= (3-2*x(i)).*x(i)-x(i-1)-2*x(i+1)+1;
  F(n)= (3-2*x(n)).*x(n)-x(n-1)+1;
  F(1)= (3-2*x(1)).*x(1)-2*x(2)+1;
