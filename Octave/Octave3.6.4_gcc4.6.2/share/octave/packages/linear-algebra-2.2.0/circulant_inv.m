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
## @deftypefn{Function File} {@var{c} =} circulant_inv (@var{v})
##
## Fast, compact calculation of inverse of a circulant matrix@*
## Given an @var{n}*1 vector @var{v}, return the inverse @var{c} of the @var{n}*@var{n} circulant matrix @var{C} that has @var{v} as its first column
## The returned @var{c} is the first column of the inverse, which is also circulant -- to get the full matrix, use `circulant_make_matrix(c)'
##
## Theoretically same as @code{inv(make_circulant_matrix(v))(:, 1)}, but requires many fewer computations and does not form matrices explicitly
##
## Roundoff may induce a small imaginary component in @var{c} even if @var{v} is real -- use @code{real(c)} to remedy this
##
## Reference: Robert M. Gray, Toeplitz and Circulant Matrices: A Review, Now Publishers, http://ee.stanford.edu/~gray/toeplitz.pdf, Chapter 3
##
## @seealso{circulant_make_matrix, circulant_matrix_vector_product, circulant_eig}
## @end deftypefn

function c = circulant_inv(v)

  ## Find the eigenvalues and eigenvectors
  [vs, lambda] = circulant_eig(v);

  ## Find the first column of the inverse
  c = vs * diag(1 ./ diag(lambda)) * conj(vs(:, 1));

endfunction

%!shared v
%! v = [1 2 3]';
%!assert (make_circulant_matrix(circulant_inv(v)), inv(make_circulant_matrix(v)), 10*eps);
