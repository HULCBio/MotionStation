## Copyright (C) 2012 Tony Richardson <richardson.tony@gmailcom>
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
## @deftypefn {Function File} {@var{x} =} convenc (@var{m}, @var{G}, @var{k})
## Compute output of an (n, @var{k}, L) convolutional encoder with vector input
## @var{m} and matrix of generator polynomials @var{G}.
##
## The input vector @var{m} can be of arbitrary length. @var{G} is a matrix with n rows
## and @var{k}*(L+1) columns. The rows of @var{G} are the generator polynomials for each
## of the n output bits (per @var{k} input bits).
##
## The output is a vector whose length is n*floor([length(@var{m})+@var{k}*(L+1)-1]/@var{k}).
## If unspecified, @var{k} defaults to 1.
##
## Example 1: Compute the output from a (2, 1, 2) convolutional encoder
## @example
## @group
## m  = [ 1 1 0 1 1 1 0 0 1 0 0 0];
## g1 = [1 1 1];
## g2 = [1 0 1];
## convenc (m, [g1; g2])
##      @result{} [1 1 0 1 0 1 0 0 0 1 1 0 0 1 1 1 1 1 1 0 1 1 0 0 0 0 0 0]
## @end group
## @end example
##
## Example 2: Compute the output from a (3, 2, 1) convolutional encoder
## @example
## @group
## m  = [0 1 1 0 0 0 1 1 ];
## g1 = [1 0 1 1];
## g2 = [1 1 0 1];
## g3 = [1 0 1 0];
## convenc (m, [g1; g2; g3], 2)
##      @result{} [1 1 1 1 1 1 1 1 0 1 0 1]
## @end group
## @end example
##
## @strong{Caution:}: this function is not compatible with @sc{matlab}'s convenc().
## @end deftypefn

function x = convenc (m, G, k = 1)
  if (nargin < 2 || nargin > 3)
    print_usage;
  endif

                                # Use conv2 to do repeated 1d convolutions of m with each row of G. 
                                # rem is used to transform the standard convolution result to one
                                # which uses modulo-2 addition.  Only cols with index a mult. of k 
                                # are in the actual enc. output

  x = rem(conv2(1, m(:)', G),2)(:,!rem(1:numel(m),k))(:)';
endfunction
