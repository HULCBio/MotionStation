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
## @deftypefn {Function File} {@var{V} =} qnosvisits (@var{P}, @var{lambda})
##
## Compute the average number of visits to the service centers of a single 
## class open Queueing Network with @math{K} service centers.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @code{@var{P}(i,j)} is the probability that a request which completed
## service at center @math{i} is routed to center @math{j}. 
##
## @item lambda
## @code{@var{lambda}(i)} is the external arrival rate to
## center @math{i}. 
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item V
## @code{@var{V}(i)} is the average number of
## visits to server @math{i}.
##
## @end table
## 
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function V = qnosvisits( P, lambda )

  if ( nargin != 2 )
    print_usage();
  endif

  issquare(P) || \
      error("P must be a square matrix");

  K = rows(P);

  all(P(:)>=0) && all( sum(P,2)<=1+1e-5 ) || \
      error( "invalid transition probability matrix P" );
  
  ( isvector(lambda) && length(lambda) == K ) || \
      error( "lambda must be a vector with %d elements", K );

  all( lambda>= 0 ) || \
      error( "lambda contains negative values" );

  lambda = lambda(:)';

  V = zeros(size(P));  
  A = eye(K)-P;
  b = lambda / sum(lambda);
  V = b/A;
  ## Make sure that no negative values appear (sometimes, numerical
  ## errors produce tiny negative values instead of zeros)
  V = max(0,V);
endfunction
%!test
%! fail( "qnosvisits([0 .5; .5 0],[0 -1])", "contains negative" );
%! fail( "qnosvisits([1 1 1; 1 1 1], [1 1])", "square" );

%!test
%!
%! ## Open, single class network
%!
%! P = [0 0.2 0.5; 1 0 0; 1 0 0];
%! lambda = [ 0.1 0.3 0.2 ];
%! V = qnosvisits(P,lambda);
%! assert( V*P+lambda/sum(lambda),V,1e-5 );

%!demo
%! p = 0.3;
%! lambda = 1.2
%! P = [0 0.3 0.5; \
%!      1 0   0  ; \
%!      1 0   0  ];
%! V = qnosvisits(P,[1.2 0 0])

%!demo
%! P = [ 0 0.4 0.6 0; \
%!       0.2 0 0.2 0.6; \
%!       0 0 0 1; \
%!       0 0 0 0 ];
%! lambda = [0.1 0 0 0.3];
%! V = qnosvisits(P,lambda);
%! S = [2 1 2 1.8];
%! m = [3 1 1 2];
%! [U R Q X] = qnos( sum(lambda), S, V, m )

