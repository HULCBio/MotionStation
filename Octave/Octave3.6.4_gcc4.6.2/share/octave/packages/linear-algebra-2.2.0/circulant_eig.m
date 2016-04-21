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
## @deftypefn{Function File} {@var{lambda} =} circulant_eig (@var{v})
## @deftypefnx{Function File} {[@var{vs}, @var{lambda}] =} circulant_eig (@var{v})
##
## Fast, compact calculation of eigenvalues and eigenvectors of a circulant matrix@*
## Given an @var{n}*1 vector @var{v}, return the eigenvalues @var{lambda} and optionally eigenvectors @var{vs} of the @var{n}*@var{n} circulant matrix @var{C} that has @var{v} as its first column
##
## Theoretically same as @code{eig(make_circulant_matrix(v))}, but many fewer computations; does not form @var{C} explicitly
##
## Reference: Robert M. Gray, Toeplitz and Circulant Matrices: A Review, Now Publishers, http://ee.stanford.edu/~gray/toeplitz.pdf, Chapter 3
##
## @seealso{circulant_make_matrix, circulant_matrix_vector_product, circulant_inv}
## @end deftypefn

function [a, b] = circulant_eig (v)

  ## FIXME when warning for broadcastin is turned off by default, this
  ## unwind_protect block could be removed

  ## we are using broadcasting on the code below so we turn off the
  ## warnings but will restore to previous state at the end
  bc_warn = warning ("query", "Octave:broadcast");
  unwind_protect
    warning ("off", "Octave:broadcast");

    #find the eigenvalues
    n = numel(v);
    lambda = ones(n, 1);
    s = (0:(n-1));
    lambda = sum(v .* exp(-2*pi*i*s'*s/n))';

    if nargout < 2
      a = lambda;
      return
    endif

    #find the eigenvectors (which in fact do not depend on v)
    a = exp(-2*i*pi*s'*s/n) / sqrt(n);
    b = diag(lambda);
  unwind_protect_cleanup
    ## restore broadcats warning status
    warning (bc_warn.state, "Octave:broadcast");
  end_unwind_protect

endfunction

%!shared v,C,vs,lambda
%! v = [1 2 3]';
%! C = circulant_make_matrix(v);
%! [vs lambda] = circulant_eig(v);
%!assert (vs*lambda, C*vs, 100*eps);
