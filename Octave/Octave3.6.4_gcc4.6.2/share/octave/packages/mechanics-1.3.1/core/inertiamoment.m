%% Copyright (c) 2011-2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} { @var{Iz} =} inertiamoment (@var{pp}, @var{m})
%%  Moment of intertia of a plane shape.
%%
%% Calculates the moment of inertia respect to an axis perpendicular to the
%% plane passing through the center of mass of the body.
%%
%% The shape is defined with piecewise smooth polynomials. @var{pp} is a
%% cell where each elements is a 2-by-(poly_degree+1) matrix containing
%% @code{px(i,:) =pp@{i@}(1,:)} and @code{py(i,:) = pp@{i@}(2,:)}.
%%
%% @seealso{masscenter, principalaxis}
%% @end deftypefn

function Iz = inertiamoment (pp, m)

  Iz = sum(cellfun (@Iint, pp));
  A = shapearea(pp);
  Iz = m*Iz / A;

endfunction

function dI = Iint (x)

    px = x(1,:);
    py = x(2,:);

    paux = conv (px, px)/3 + conv(py, py);
    paux2 = conv (px, polyder (py)) ;
    P = polyint (conv (paux, paux2));

    %% Faster than quad
    dI = diff(polyval(P,[0 1]));

endfunction

%!demo % non-convex bezier shape
%! weirdhearth ={[-17.6816  -34.3989    7.8580    3.7971; ...
%!                15.4585  -28.3820  -18.7645    9.8519]; ...
%!                 [-27.7359   18.1039  -34.5718    3.7878; ...
%!                  -40.7440   49.7999  -25.5011    2.2304]};
%! Iz = inertiamoment (weirdhearth,1)

%!test
%! square = {[1 -0.5; 0 -0.5]; [0 0.5; 1 -0.5]; [-1 0.5; 0 0.5]; [0 -0.5; -1 0.5]};
%! Iz = inertiamoment (square,1);
%! assert (1/6, Iz, sqrt(eps));

%!test
%! circle = {[1.715729  -6.715729    0   5; ...
%!            -1.715729  -1.568542   8.284271    0]; ...
%!            [1.715729   1.568542  -8.284271    0; ...
%!             1.715729  -6.715729    0   5]; ...
%!            [-1.715729   6.715729    0  -5; ...
%!             1.715729   1.568542  -8.284271    0]; ...
%!            [-1.715729  -1.568542   8.284271    0; ...
%!            -1.715729   6.715729    0  -5]};
%! Iz = inertiamoment (circle,1);
%! assert (Iz, 0.5*5^2, 5e-3);
