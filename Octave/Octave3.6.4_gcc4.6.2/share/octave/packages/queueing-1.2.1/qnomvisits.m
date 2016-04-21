## Copyright (C) 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {@var{V} =} qnomvisits (@var{P}, @var{lambda})
##
## Compute the average number of visits to the service centers of an open multiclass network with @math{K} service centers and @math{C} customer classes.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @code{@var{P}(r,i,s,j)} is the probability that a
## class @math{r} request which completed service at center @math{i} is
## routed to center @math{j} as a class @math{s} request. Class switching
## is supported.
##
## @item lambda
## @code{@var{lambda}(r,i)} is the arrival rate of class @math{r}
## requests to center @math{i}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item V
## @code{@var{V}(r,i)} is the number of visits of class @math{r}
## requests at center @math{i}.
##
## @end table
## 
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function V = qnomvisits( P, lambda )

  if ( nargin != 2 )
    print_usage();
  endif

  ndims(P) == 4 || \
      error("P must be a 4-dimensional matrix");

  [C, K, C2, K2] = size( P );
  (K == K2 && C == C2) || \
      error( "P must be a [C,K,C,K] matrix");

  ismatrix(lambda) && [C,K] == size(lambda) || \
      error( "lambda must be a %d x %d matrix", C, K );

  all(lambda(:)>=0) || \
      error(" lambda contains negative values" );

  ## solve the traffic equations: V(s,j) = lambda(s,j) / lambda + sum_r
  ## sum_i V(r,i) * P(r,i,s,j), for all s,j where lambda is defined as
  ## sum_r sum_i lambda(r,i)
  A = eye(K*C) - reshape(P,[K*C K*C]);
  b = reshape(lambda / sum(lambda(:)), [1,K*C]);
  V = reshape(b/A, [C, K]);

  ## Make sure that no negative values appear (sometimes, numerical
  ## errors produce tiny negative values instead of zeros)
  V = max(0,V);
endfunction
%!test
%! fail( "qnomvisits( zeros(3,3,3), [1 1 1] )", "matrix");

%!test
%! C = 2; K = 4;
%! P = zeros(C,K,C,K);
%! # class 1 routing
%! P(1,1,1,1) = .05;
%! P(1,1,1,2) = .45;
%! P(1,1,1,3) = .5;
%! P(1,2,1,1) = 0.1;
%! P(1,3,1,1) = 0.2;
%! # class 2 routing
%! P(2,1,2,1) = .01;
%! P(2,1,2,3) = .5;
%! P(2,1,2,4) = .49;
%! P(2,3,2,1) = 0.2;
%! P(2,4,2,1) = 0.16;
%! lambda = [0.1 0 0 0.1 ; 0 0 0.2 0.1];
%! lambda_sum = sum(lambda(:));
%! V = qnomvisits(P, lambda);
%! assert( all(V(:)>=0) );
%! for i=1:K
%!   for c=1:C
%!     assert(V(c,i), lambda(c,i) / lambda_sum + sum(sum(V .* P(:,:,c,i))), 1e-5);
%!   endfor
%! endfor

