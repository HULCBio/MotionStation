## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{axes} @var{l} @var{moments}] =} principalaxes (@var{shape})
## Calculates the principal axes of a shape.
##
## Returns a matrix @var{axes} where each row corresponds to one of the principal
## axes of the shape. @var{l} is the second moment of area around the correspoding
## principal axis. @var{axes} is order from lower to higher @var{l}.
##
## @var{shape} can be defined by a polygon or by a piece-wise smooth shape.
##
## @seealso{inertiamoment, masscenter}
## @end deftypefn

function [PA l Jm] = principalaxes (shape)

  Jm = shapemoment (shape);

  Jsq = Jm(2)^2;
  if Jsq > eps;

    TrJ = Jm(1) + Jm(3);
    DetJ = Jm(1)*Jm(3) - Jsq;

    %% Eigenvalues
    l = ( [TrJ;  TrJ] + [1; -1]*sqrt(TrJ^2 - 4*DetJ) )/2;

    %% Eginevectors (Exchanged Jx with Jy)
    PA(:,1) = (l - Jm(1)) .* (l - Jm(3)) / Jsq;
    PA(:,2) = (l - Jm(1)) .* (l - Jm(3)).^2 / Jm(2)^3;

    %% Normalize
    PAnorm = sqrt ( sumsq(PA,2));
    PA(1,:) = PA(1,:) ./ PAnorm(1);
    PA(2,:) = PA(2,:) ./ PAnorm(2);
  else

    %% Matrix already diagonal
    PA(:,1) = [1 ; 0];
    PA(:,2) = [0 ; 1];
    l = [Jm(3); Jm(1)];

  end

  %% First axis is the one with lowest moment
  [l ind] = sort (l, 'ascend');
  PA = PA(ind([2 1]),:);

  %% Check that is a right hand oriented pair of axis
  if PA(1,1)*PA(2,2) - PA(1,2)*PA(2,1) < 0
    PA(1,:) = -PA(1,:);
  end
end

%!test
%! h = 1; b = 2;
%! rectangle = [-b/2 -h/2; b/2 -h/2; b/2 h/2; -b/2 h/2];
%! [PA l] = principalaxes(rectangle);
%! assert ( [1 0; 0 1], PA, 1e-6);
%! assert ([b*h^3; h*b^3]/12, l);

%!demo
%! t = linspace(0,2*pi,64).';
%! shape = [cos(t)-0.3*cos(3*t) sin(t)](1:end-1,:);
%! shapeR = shape*rotv([0 0 1],pi/4)(1:2,1:2);
%! [PAr l] = principalaxes(shapeR);
%! [PA l] = principalaxes(shape);
%!
%! figure (1)
%! clf
%! plot(shape(:,1),shape(:,2),'-k');
%! line([0 PA(1,1)],[0 PA(1,2)],'color','r');
%! line([0 PA(2,1)],[0 PA(2,2)],'color','b');
%!
%! hold on
%!
%! plot(shapeR(:,1)+3,shapeR(:,2),'-k');
%! line([3 PAr(1,1)+3],[0 PAr(1,2)],'color','r');
%! line([3 PAr(2,1)+3],[0 PAr(2,2)],'color','b');
%!
%! axis equal
%! axis square
