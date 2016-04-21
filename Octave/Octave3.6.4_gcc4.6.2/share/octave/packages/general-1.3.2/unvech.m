## Copyright (C) 2006 Michael Creel <michael.creel@uab.es>
## Copyright (C) 2009 Jaroslav Hajek <highegg@gmail.com>
## Copyright (C) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {@var{m} =} unvech (@var{v}, @var{scale})
## Performs the reverse of @code{vech} on the vector @var{v}.
##
## Given a Nx1 array @var{v} describing the lower triangular part of a
## matrix (as obtained from @code{vech}), it returns the full matrix.
##
## The upper triangular part of the matrix will be multiplied by @var{scale} such
## that 1 and -1 can be used for symmetric and antisymmetric matrix respectively.
## @var{scale} must be a scalar and defaults to 1.
##
## @seealso{vech, ind2sub}
## @end deftypefn

## TODO remove subfunction ind2sub_tril after new release of octave that will have
## it builtin standard ind2sub

function M = unvech (v, scale = 1)

  if ( nargin < 1 || nargin > 2 )
    print_usage;
  elseif ( !ismatrix (v) && any (size (v) != 1) )
    error ("V must be a row or column matrix")
  elseif ( !isnumeric (scale) || !isscalar (scale) )
    error ("SCALE must be a scalar")
  endif

  N      = length (v);
  dim    = (sqrt ( 1 + 8*N ) - 1)/2;
  [r, c] = ind2sub_tril (dim, 1:N);   # replace with core ind2sub after octave 3.6
  M      = accumarray ([r; c].', v);
  M     += scale * tril (M, -1).';

endfunction

function [r c] = ind2sub_tril(N,idx)

  endofrow = 0.5*(1:N) .* (2*N:-1:N + 1);
  c = lookup(endofrow, idx-1)+1;

  r = N - endofrow(c) + idx ;

endfunction

%!assert(unvech([1;0;0;1;0;1]), full(eye(3,3)) );

%!test %symmetric
%! dim = 10;
%! A = tril( floor ( 5*(2*rand(dim)-1) ) );
%! A += A.';
%! M = vech(A);
%! M = unvech(M, 1);
%! assert (A, M);

%!test %antisymmetric
%! dim = 10;
%! A = tril( floor ( 5*(2*rand(dim)-1) ) );
%! A -= A.';
%! M = vech(A);
%! M = unvech(M, -1);
%! assert (A, M);
