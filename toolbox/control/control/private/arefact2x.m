function [X,Report] = arefact2x(X1,X2,D,Report)
% Computes Riccati solution X = D*(X2/X1)*D from X1,X2,D.

%   Author(s): Pascal Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:13:53 $
if Report<0
   X = [];
else
   % Solve X * X1 = X2
   [l,u,p] = lu(X1);
   CondX1 = rcond(u);
   if CondX1>eps,
      % Solve for X based on LU decomposition
      X = ((X2/u)/l)*p;
      % Symmetrize
      X = (X+X')/2;
      % Factor in scaling D (X -> DXD)
      X = lrscale(X,D,D);
   else
      % X1 is singular
      X = [];  Report = -2;
   end
end

      