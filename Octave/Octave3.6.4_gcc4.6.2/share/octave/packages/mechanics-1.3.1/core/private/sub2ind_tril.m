%% Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
%% @deftypefn {Function File} {ind = } sub2ind_tril (@var{N}, @var{r}, @var{c})
%% Convert subscripts to a linear index of a trinagular matrix.
%%
%% An example of trinagular matrix linearly indexed follows.
%%
%% @example
%%          N = 4;
%%          A = -repmat (1:N,N,1);
%%          A += repmat (diagind, N,1) - A.';
%%          A = tril(A)
%%          => A =
%%              1    0    0    0
%%              2    5    0    0
%%              3    6    8    0
%%              4    7    9   10
%% @end example
%%
%% The following example shows how to convert the two-dimensional
%% index `(3,2)' of the 4-by-4 matrix in the previous example to a linear index.
%%
%% @example
%%          linear_index = sub2ind_tril (4, 3, 2)
%%          => linear_index = 6
%% @end example
%%
%% When @var{r} and @var{c} are row or column matrices of subindeces of the same
%% size then @var{ind} have the same shape as any of them.
%%
%% @seealso{vech, sub2ind, ind2sub_tril}
%% @end deftypefn

function ind = sub2ind_tril(N,r,c)

  %% Horrible lengthly check
  if nargin < 3 ||( !isnumeric (N) && all(size(N)==1) )|| ...
    !( ismatrix (r) && any (size (r)==1) ) || ...
    !( ismatrix (c) && any (size (c)==1) ) || ...
    any(size(r) != size(c))
    print_usage;
  endif

  R = zeros(size(r));
  C = zeros(size(c));

  below = r >= c;
  above = !below;
  R(below) = r(below);
  C(below) = c(below);

  R(above) = c(above);
  C(above) = r(above);

  ind = sub2ind ([N N],R,C) - C.*(C-1)/2;

end

%!shared N, diagind
%! N = 2;
%! diagind = 1 + 0.5*(0:N-1).*( (2*N+1):-1:(N+2) );

%!assert (diagind, sub2ind_tril(N,1:N,1:N)) % diagonal indexes

%!test
%! A = - repmat (1:N, N, 1);
%! A += repmat (diagind, N, 1) - A.';
%! [r c] = ind2sub_tril (N, 1:N*(N+1)/2);
%! assert (sub2ind_tril (N,r',c'), vech (A)) % Full matrix

%!error sub2ind_tril([1 2 3], [4 5 6], [1 2 3]); % size is not a scalar
%!error sub2ind_tril(4, eye(2), [1 2]); % r is not a row or column matrix
%!error sub2ind_tril(4, [1 2], eye(2)); % c is not a row or column matrix
%!error sub2ind_tril(4, [1 2], [1 2 3]); % c,r not the same size
%!error sub2ind_tril(4, [1 2 3 ], 1); % c,r not the same size
%!error sub2ind_tril(4,{1, 2}, {1, 2}); % idx is not a row or column matrix
%!error sub2ind_tril([1 2 3]); % not enough arguments
%!error sub2ind_tril(3,[1 2 3]); % not enough arguments
