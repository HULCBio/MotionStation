function [num,den] = ss2tf2(a,b,c,d,iu)
%SS2TF2 Obtain the transfer function of a SS model (one at a time)
%	[Num,Den] = ss2tfs(A,B,C,D,iu)
% Num is a matrix containing as many rows as there are outputs
% Den is the denominator polynomial
% The state space system is given by:
%              x(k+1) = A*x(k) + B*u(k)
%              y(k)   = C*x(k) + D*u(k)
% iu is the input to be used.  The transfer function can
% only be computed between the outputs and one input at a
% time due to MATLAB limitations
%

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

%
% For reference on the formula used see Kailath's "Linear Systems"
% page 651.
%

[nx,nx2] = size(a);
if(nx ~= nx2),
  error('Matrix A must be square')
end
[nx2,nu] = size(b);
if(nx ~= nx2)
  error('Matrices A and B must have same number of rows')
end
[ny,nx2] = size(c);
if(nx ~= nx2)
  error('Matrices A and C must have same number of columns')
end
[ny2,nu2] = size(d);
if(ny2 ~= ny)
  error('Matrices C and D must have same number of rows')
end
if(nu2 ~= nu)
  error('Matrices B and D must have same number of columns')
end

den = poly(a);

for i = 1:ny
  num(i,:) = poly(a-b(:,iu)*c(i,:)) - den + d(i,1)*den;
end