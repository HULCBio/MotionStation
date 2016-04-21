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
%% @deftypefn {Function File} {[ @var{r}, @var{c} ] = } ind2sub_tril (@var{N}, @var{idx})
%% Convert a linear index to subscripts of a trinagular matrix.
%%
%% An example of trinagular matrix linearly indexed follows
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
%% The following example shows how to convert the linear index `6' in
%% the 4-by-4 matrix of the example into a subscript.
%%
%% @example
%%          [r, c] = ind2sub_tril (4, 6)
%%          => r =  2
%%            c =  3
%% @end example
%%
%% when @var{idx} is a row or column matrix of linear indeces then @var{r} and
%% @var{c} have the same shape as @var{idx}.
%%
%% @seealso{vech, ind2sub, sub2ind_tril}
%% @end deftypefn

function [r c] = ind2sub_tril(N,idx)

  %% Horrible lengthly check
  if nargin < 2 ||( !isnumeric (N) && all(size(N)==1) )|| ...
    !( ismatrix (idx) && any (size (idx)==1) ) 
    print_usage;
  endif
  
  endofrow = 0.5*(1:N) .* (2*N:-1:N + 1);
  c = lookup(endofrow, idx-1)+1;

  r = N - endofrow(c) + idx ;

end

%!shared N, diagind
%! N=4;
%! diagind = 1 + 0.5*(0:N-1).*( (2*N+1):-1:(N+2) );

%!test
%! A = -repmat (1:N,N,1);
%! A += repmat (diagind, N,1) - A.';
%! A = tril(A);
%! [r c] = ind2sub_tril (rows(A),1:10);
%! A_shouldbe = accumarray([r; c]',1:10);
%! assert (A_shouldbe, A)

%!error ind2sub_tril([1 2 3],[4 5 6]); % size is not a scalar
%!error ind2sub_tril(4,eye(2)); % idx is not a row or column matrix
%!error ind2sub_tril(4,{1, 2}); % idx is not a row or column matrix
%!error ind2sub_tril([1 2 3]); % not enough arguments

