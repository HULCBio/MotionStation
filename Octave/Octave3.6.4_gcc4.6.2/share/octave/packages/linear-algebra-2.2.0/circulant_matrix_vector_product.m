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
## @deftypefn{Function File} {@var{y} =} circulant_matrix_vector_product (@var{v}, @var{x})
##
## Fast, compact calculation of the product of a circulant matrix with a vector@*
## Given @var{n}*1 vectors @var{v} and @var{x}, return the matrix-vector product @var{y} = @var{C}@var{x}, where @var{C} is the @var{n}*@var{n} circulant matrix that has @var{v} as its first column
##
## Theoretically the same as @code{make_circulant_matrix(x) * v}, but does not form @var{C} explicitly; uses the discrete Fourier transform
##
## Because of roundoff, the returned @var{y} may have a small imaginary component even if @var{v} and @var{x} are real (use @code{real(y)} to remedy this)
##
## Reference: Gene H. Golub and Charles F. Van Loan, Matrix Computations, 3rd Ed., Section 4.7.7
##
## @seealso{circulant_make_matrix, circulant_eig, circulant_inv}
## @end deftypefn

function y = circulant_matrix_vector_product (v, x)

  xf = fft(x);
  vf = fft(v);
  z = vf .* xf;
  y = ifft(z);

endfunction

%!shared v,x
%! v = [1 2 3]'; x = [2 5 6]';
%!assert (circulant_matrix_vector_product(v, x), circulant_make_matrix(v)*x, eps);
