function G = numgrid(R,n)
%NUMGRID Number the grid points in a two dimensional region.
%   G = NUMGRID('R',n) numbers the points on an n-by-n grid in
%   the subregion of -1<=x<=1 and -1<=y<=1 determined by 'R'.
%   SPY(NUMGRID('R',n)) plots the points.
%   DELSQ(NUMGRID('R',n)) generates the 5-point discrete Laplacian.
%   The regions currently available are:
%      'S' - the entire square.
%      'L' - the L-shaped domain made from 3/4 of the entire square.
%      'C' - like the 'L', but with a quarter circle in the 4-th square.
%      'D' - the unit disc.
%      'A' - an annulus.
%      'H' - a heart-shaped cardioid.
%      'B' - the exterior of a "Butterfly".
%      'N' - a nested dissection ordering of the square.
%   To add other regions, edit toolbox/matlab/demos/numgrid.m.
%
%   See also DELSQ, DELSQSHOW, DELSQDEMO.

%   C. Moler, 7-16-91, 12-22-93.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/06/17 13:20:30 $

if R == 'N'
   G = nested(n);
else
   x = ones(n,1)*[-1, (-(n-3):2:(n-3))/(n-1), 1];
   y = flipud(x');
   if R == 'S'
      G = (x > -1) & (x < 1) & (y > -1) & (y < 1);
   elseif R == 'L'
      G = (x > -1) & (x < 1) & (y > -1) & (y < 1) & ( (x > 0) | (y > 0));
   elseif R == 'C'
      G = (x > -1) & (x < 1) & (y > -1) & (y < 1) & ((x+1).^2+(y+1).^2 > 1);
   elseif R == 'D'
      G = x.^2 + y.^2 < 1;
   elseif R == 'A'
      G = ( x.^2 + y.^2 < 1) & ( x.^2 + y.^2 > 1/3);
   elseif R == 'H'
      RHO = .75; SIGMA = .75;
      G = (x.^2+y.^2).*(x.^2+y.^2-SIGMA*y) < RHO*x.^2;
   elseif R == 'B'
      t = atan2(y,x);
      r = sqrt(x.^2 + y.^2);
      G = (r >= sin(2*t) + .2*sin(8*t)) & ...
          (x > -1) & (x < 1) & (y > -1) & (y < 1);
   else
      error('Invalid region type.');
   end
   k = find(G);
   G = zeros(size(G));      % Convert from logical to double matrix
   G(k) = (1:length(k))';
end
