## Copyright (C) 2012 Nir Krakauer <nkrakauer@ccny.cuny.edu>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{C} =} circulant_make_matrix (@var{v})
##
## Produce a full circulant matrix given the first column@*
## Given an @var{n}*1 vector @var{v}, returns the @var{n}*@var{n} circulant matrix @var{C} where @var{v} is the left column and all other columns are downshifted versions of @var{v}
##
## Note: If the first row @var{r} of a circulant matrix is given, the first column @var{v} can be obtained as @code{v = r([1 end:-1:2])}
##
## Reference: Gene H. Golub and Charles F. Van Loan, Matrix Computations, 3rd Ed., Section 4.7.7
##
## @seealso{circulant_matrix_vector_product, circulant_eig, circulant_inv}
## @end deftypefn

function C = circulant_make_matrix(v)

  n = numel(v);
  C = ones(n, n);
  for i = 1:n
    C(:, i) = v([(end-i+2):end 1:(end-i+1)]); #or circshift(v, i-1)
  endfor

endfunction

%!shared v,C
%! v = [1 2 3]'; C = [1 3 2; 2 1 3; 3 2 1];
%!assert (circulant_make_matrix(v), C);
