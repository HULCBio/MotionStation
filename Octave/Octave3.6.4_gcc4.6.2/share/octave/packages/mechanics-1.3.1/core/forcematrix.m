%% Copyright (c) 2010 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {[@var{F}, @var{D}] =} forcematrix (@var{pos}, @var{A},@var{funcs})
%% Evaluates a force function depending on the separation of multiple interacting points.
%%
%% @strong{INPUT}
%%
%% @itemize
%% @item
%% @var{pos} is a Nxdim array of positions. N is the number of points and dim the
%% dimension. Each row represent a different point.
%%
%% @item
%% @var{A} is the a connectivity (adjacency) matrix expressed as a vector. That is, if
%% @var{M} is the complete NxN symmetric connectivity matrix, then
%% @code{@var{A}= vech(@var{M})}. The diagonal of @var{M} is not used. The elements
%% of A are indexes to the corresponding interaction force in @var{funcs}. For
%% example, there are 3 points and points 2 and 3 interact with a force
%% described in the 5th element of @var{funcs}, then @code{ M(2, 3) = 5}.
%%
%% @item
%% @var{funcs} is a Nfx1 cell. Elements that are matrices are evaluated with
%% @code{polyval}. elements that are function handles are evaluated directly.
%% Functions handles must be of the form @code{@@(@var{x})f(@var{x})}, where x is
%% the distance between two interacting points.
%%
%% @end itemize
%%
%% @strong{OUTPUT}
%%
%% @itemize
%% @item
%% @var{F} is a Nxdim array of forces acting on each point.
%%
%% @item
%% @var{D} is an array in the same format as @var{A} containing the euclidean
%% distances between the points.
%% @end itemize
%%
%% @html
%% @include doc/matrixforce.svg
%% @end html
%% @seealso{pointmassmesh, polyval, vech, sub2ind}
%% @end deftypefn

function [F D dr] = forcematrix (pos, A, funcs)

  %% Argument parsing
  [N dim] = size(pos);
  nA      = numel(A);

  % Relative position matrix
  dr = zeros (nA,dim);
  for ic = 1:dim
    dr(:,ic) = vech (bsxfun (@minus, pos(:,ic)', pos(:,ic)));
  end

  % Distance vector
  D = sqrt (sum (dr.^2, 2));
  % Versor
  drhat = dr ./ repmat(D, 1,dim);

  %% Extend funcs to handle 0 elements. This or eliminate all diagonals.
  funcs{end+1} = 0;
  nf = numel(funcs);
  A(A==0) = nf;

  %% pair to pair forces
  f = cellfun (@handleOpoly, {funcs{A}}.', mat2cell (D, ones(nA,1), 1));
  f = repmat(f,1,dim) .* drhat;

  %% net force on p1
  F = zeros (N,dim);

  aux = ones(1,N-1);
  p2 = sub2ind_tril (N, 2:N, aux);
  F(1,:) = sum (f(p2,:));

  p2 = sub2ind_tril (N, 1:N-1, N*aux );
  F(N,:) = -sum (f(p2,:));

  for p1 = 2:N-1
    idx = sub2ind_tril (N, 1:N, repmat (p1,1,N) );
    sthalf = idx(1:(p1-1));
    ndhalf = idx((p1+1):N);
    F(p1,:) = sum (f(ndhalf,:)) - sum (f(sthalf,:));
  end

endfunction

function f = handleOpoly (y,x)

  if isnumeric(y)
    f = polyval(y,x);
  else
    f = y(x);
  end

end

%% 1D
%!test
%! pos = [0;1]; A=vech ([0 1; 1 0]); funcs={[-1 1]};
%! [F D] = forcematrix (pos, A, funcs);
%! assert (F, [0; 0], 1e-8);
%! assert (D, [0; 1; 0]);

%!test
%! pos = [0;1;2]; A=vech ([0 1 0; 1 0 1; 0 1 0]); funcs={[-1 1]};
%! [F D] = forcematrix (pos, A, funcs);
%! assert (F, [0; 0; 0], 1e-8);
%! assert (D, [0; 1; 2; 0; 1; 0]);

%!test
%! pos = [0;1;2]; A=vech ([0 1 0; 1 0 1; 1 0 0]); funcs={[-1 1]};
%! [F D] = forcematrix (pos, A, funcs);
%! assert (F, [1; 0; -1], 1e-8);
%! assert (D, [0; 1; 2; 0; 1; 0]);

%!test
%! pos = [0;1;2]; A=vech ([0 1 0; 1 0 1; 1 1 0]); funcs={[-1 1]};
%! [F D] = forcematrix (pos, A, funcs);
%! assert (F, [1; 0; -1], 1e-8);
%! assert (D, [0; 1; 2; 0; 1; 0]);

%% 2D
%!test % Equilateral triangle
%! pos = [0 0;1 0;cos(pi/3) sin(pi/3)]; A=[0;1;1; 0;1; 0]; funcs={[-1 1]};
%! [F D] = forcematrix (pos, A, funcs);
%! assert (F, [0 0; 0 0; 0 0], 1e-8);
%! assert (D, [0; 1; 1; 0; 1; 0], 1e-8);

%!test % Square
%! pos = [0 0;1 0;1 1;0 1]; A=[0;1;0;1; 0;1;0; 0;1; 0]; funcs={[-1 1]};
%! [F D] = forcematrix (pos, A, funcs);
%! assert (F, [0 0; 0 0; 0 0; 0 0], 1e-8);
%! assert (D, [0;1;sqrt(2);1; 0;1;sqrt(2); 0;1; 0], 1e-8);


% 3D
%!test % Cube
%! pos = [0 0 0; 1 0 0; 1 1 0; 0 1 0; ...
%!        0 0 1; 1 0 1; 1 1 1; 0 1 1;];
%! A= [0;1;0;1;1;0;0;0; ...
%!       0;1;0;0;1;0;0; ...
%!         0;1;0;0;1;0; ...
%!           0;0;0;0;1; ...
%!             0;1;0;1; ...
%!               0;1;0; ...
%!                 0;1; ...
%!                   0; ];
%! funcs={[-1 1]};
%! [F D] = forcematrix (pos, A, funcs);
%! assert (F, zeros(8,3), 1e-8);
%! D_sb = [0;sqrt([1;2;1;1;2;3;2]); ...
%!           0;sqrt([1;2;2;1;2;3]); ...
%!             0;sqrt([1;3;2;1;2]); ...
%!               0;sqrt([2;3;2;1]); ...
%!                 0;sqrt([1;2;1]); ...
%!                   0;sqrt([1;2]); ...
%!                     0;sqrt(1); ...
%!                       0];
%! assert (D, D_sb, 1e-8);

%!test % Cube 2 funcs
%! pos = [0 0 0; 1 0 0; 1 1 0; 0 1 0; ...
%!        0 0 1; 1 0 1; 1 1 1; 0 1 1;];
%! A= [0;1;0;1;2;0;0;0; ...
%!       0;1;0;0;2;0;0; ...
%!         0;1;0;0;2;0; ...
%!           0;0;0;0;2; ...
%!             0;1;0;1; ...
%!               0;1;0; ...
%!                 0;1; ...
%!                   0; ];
%! funcs={[-1 1], @(x)-x};
%! [F D] = forcematrix (pos, A, funcs);
%! F_sb = [zeros(4,2) ones(4,1); ...
%!         zeros(4,2) -ones(4,1)];
%! assert (F, F_sb, 1e-8);
%! D_sb = [0;sqrt([1;2;1;1;2;3;2]); ...
%!           0;sqrt([1;2;2;1;2;3]); ...
%!             0;sqrt([1;3;2;1;2]); ...
%!               0;sqrt([2;3;2;1]); ...
%!                 0;sqrt([1;2;1]); ...
%!                   0;sqrt([1;2]); ...
%!                     0;sqrt(1); ...
%!                       0];
%! assert (D, D_sb, 1e-8);
