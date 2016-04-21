## Copyright (C) 2006, 2007 Arno Onken <asnelt@asnelt.org>
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
## @deftypefn {Function File} {@var{c} =} condeig (@var{a})
## @deftypefnx {Function File} {[@var{v}, @var{lambda}, @var{c}] =} condeig (@var{a})
## Compute condition numbers of the eigenvalues of a matrix. The
## condition numbers are the reciprocals of the cosines of the angles
## between the left and right eigenvectors.
##
## @subheading Arguments
##
## @itemize @bullet
## @item
## @var{a} must be a square numeric matrix.
## @end itemize
##
## @subheading Return values
##
## @itemize @bullet
## @item
## @var{c} is a vector of condition numbers of the eigenvalue of
## @var{a}.
##
## @item
## @var{v} is the matrix of right eigenvectors of @var{a}. The result is
## the same as for @code{[v, lambda] = eig (a)}.
##
## @item
## @var{lambda} is the diagonal matrix of eigenvalues of @var{a}. The
## result is the same as for @code{[v, lambda] = eig (a)}.
## @end itemize
##
## @subheading Example
##
## @example
## @group
## a = [1, 2; 3, 4];
## c = condeig (a)
## @result{} [1.0150; 1.0150]
## @end group
## @end example
## @end deftypefn

function [v, lambda, c] = condeig (a)

  # Check arguments
  if (nargin != 1 || nargout > 3)
    print_usage ();
  endif

  if (! isempty (a) && ! ismatrix (a))
    error ("condeig: a must be a numeric matrix");
  endif

  if (columns (a) != rows (a))
    error ("condeig: a must be a square matrix");
  endif

  if (issparse (a) && (nargout == 0 || nargout == 1) && exist ("svds", "file"))
    ## Try to use svds to calculate the condition as it will typically be much 
    ## faster than calling eig as only the smallest and largest eigenvalue are
    ## calculated.
    try
      s0 = svds (a, 1, 0);
      v = svds (a, 1) / s0;
    catch
      ## Caught an error as there is a singular value exactly at Zero!!
      v = Inf;
    end_try_catch
    return;
  endif

  # Right eigenvectors
  [v, lambda] = eig (a);

  if (isempty (a))
    c = lambda;
  else
    # Corresponding left eigenvectors
    vl = inv (v)';
    # Normalize vectors
    vl = vl ./ repmat (sqrt (sum (abs (vl .^ 2))), rows (vl), 1);

    # Condition numbers
    # cos (angle) = (norm (v1) * norm (v2)) / dot (v1, v2)
    # Norm of the eigenvectors is 1 => norm (v1) * norm (v2) = 1
    c = abs (1 ./ dot (vl, v)');
  endif

  if (nargout == 0 || nargout == 1)
    v = c;
  endif

endfunction

%!test
%! a = [1, 2; 3, 4];
%! c = condeig (a);
%! expected_c = [1.0150; 1.0150];
%! assert (c, expected_c, 0.001);

%!test
%! a = [1, 3; 5, 8];
%! [v, lambda, c] = condeig (a);
%! [expected_v, expected_lambda] = eig (a);
%! expected_c = [1.0182; 1.0182];
%! assert (v, expected_v, 0.001);
%! assert (lambda, expected_lambda, 0.001);
%! assert (c, expected_c, 0.001);
