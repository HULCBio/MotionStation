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
%% @deftypefn {Function File} { @var{cm} =} masscenter (@var{pp})
%%  Center of mass of a plane shape.
%%
%% The shape is defined with piecewise smooth polynomials. @var{pp} is a
%% cell where each elements is a 2-by-(poly_degree+1) matrix containing
%% @code{px(i,:) = pp@{i@}(1,:)} and @code{py(i,:) = pp@{i@}(2,:)}.
%%
%% @seealso{inertiamoment}
%% @end deftypefn

function cm = masscenter (shape)

  cm = sum( cell2mat ( cellfun (@CMint, shape, 'UniformOutput', false)));
  A = shapearea(shape);
  cm = cm / A;

endfunction

function dcm = CMint (x)

    px = x(1,:);
    py = x(2,:);
    Px = polyint (conv(conv (-px , py) , polyder (px)));
    Py = polyint (conv(conv (px , py) , polyder (py)));

    dcm = zeros (1,2);
    dcm(1) = diff(polyval(Px,[0 1]));
    dcm(2) = diff(polyval(Py,[0 1]));

endfunction

%!demo % non-convex bezier shape
%! weirdhearth ={[34.81947,-63.60585 41.35964,1.61093; ...
%!                73.22086,4.95439 7.1796,-34.7948]; ...
%!                 [30.26599,-50.0316 77.6279,8.52058; ...
%!                  -18.66371,58.02699 -168.20415,52.74819]};
%! CoM = masscenter (weirdhearth)

%!test
%! square = {[1 -0.5; 0 -0.5]; [0 0.5; 1 -0.5]; [-1 0.5; 0 0.5]; [0 -0.5; -1 0.5]};
%! CoM = masscenter (square);
%! square_t = shapetransform (square,[1;1]);
%! CoM_t = masscenter (square_t);
%! assert (CoM, [0 0], sqrt(eps));
%! assert (CoM_t, [1 1], sqrt(eps));

%!test
%! square = {[1 -0.5; 0 -0.5]; [0 0.5; 1 -0.5]; [-1 0.5; 0 0.5]; [0 -0.5; -1 0.5]};
%! CoM = masscenter (square);
%! assert (CoM, [0 0], sqrt(eps));

%!test
%! circle = {[1.715729  -6.715729    0   5; ...
%!            -1.715729  -1.568542   8.284271    0]; ...
%!            [1.715729   1.568542  -8.284271    0; ...
%!             1.715729  -6.715729    0   5]; ...
%!            [-1.715729   6.715729    0  -5; ...
%!             1.715729   1.568542  -8.284271    0]; ...
%!            [-1.715729  -1.568542   8.284271    0; ...
%!            -1.715729   6.715729    0  -5]};
%! CoM = masscenter (circle);
%! assert (CoM , [0 0], 5e-3);
