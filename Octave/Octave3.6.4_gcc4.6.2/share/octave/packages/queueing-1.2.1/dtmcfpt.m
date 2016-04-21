## Copyright (C) 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {@var{M} =} dtmcfpt (@var{P})
##
## @cindex first passage times
## @cindex mean recurrence times
## @cindex discrete time Markov chain
## @cindex Markov chain, discrete time
## @cindex DTMC
##
## Compute mean first passage times and mean recurrence times
## for an irreducible discrete-time Markov chain.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @code{@var{P}(i,j)} is the transition probability from state @math{i}
## to state @math{j}. @var{P} must be an irreducible stochastic matrix,
## which means that the sum of each row must be 1 (@math{\sum_{j=1}^N
## P_{i j} = 1}), and the rank of @var{P} must be equal to its
## dimension.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item M
## For all @math{i \neq j}, @code{@var{M}(i,j)} is the average number of
## transitions before state @var{j} is reached for the first time,
## starting from state @var{i}. @code{@var{M}(i,i)} is the @emph{mean
## recurrence time} of state @math{i}, and represents the average time
## needed to return to state @var{i}.
##
## @end table
##
## @seealso{ctmcfpt}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function result = dtmcfpt( P )

  if ( nargin != 1 )
    print_usage();
  endif

  [N err] = dtmcchkP(P);

  ( N>0 ) || \
      error(err);

  if ( any(diag(P) == 1) ) 
    error("Cannot compute first passage times for absorbing chains");
  endif

  ## Source [GrSn97]
  w = dtmc(P); # steady state probability vector
  W = repmat(w,N,1);
  ## Z = (I - P + W)^-1 where W is the matrix where each row is the
  ## steady-state probability vector for P
  Z = inv(eye(N)-P+W);
  ## m_ij = (z_jj - z_ij) / w_j
  result = (repmat(diag(Z)',N,1) - Z) ./ repmat(w,N,1) + diag(1./w);

endfunction
%!test
%! P = [1 1 1; 1 1 1];
%! fail( "dtmcfpt(P)" );

%!test
%! P = dtmcbd([1 1 1], [0 0 0] );
%! fail( "dtmcfpt(P)", "absorbing" );

%!test
%! P = [ 0.0 0.9 0.1; \
%!       0.1 0.0 0.9; \
%!       0.9 0.1 0.0 ];
%! p = dtmc(P);
%! M = dtmcfpt(P);
%! assert( diag(M)', 1./p, 1e-8 );

## Example on p. 461 of [GrSn97]
%!test
%! P = [ 0 1 0 0 0; \
%!      .25 .0 .75 0 0; \
%!      0 .5 0 .5 0; \
%!      0 0 .75 0 .25; \
%!      0 0 0 1 0 ];
%! M = dtmcfpt(P);
%! assert( M, [16 1 2.6667 6.3333 21.3333; \
%!             15 4 1.6667 5.3333 20.3333; \
%!             18.6667 3.6667 2.6667 3.6667 18.6667; \
%!             20.3333 5.3333 1.6667 4 15; \
%!             21.3333 6.3333 2.6667 1 16 ], 1e-4 );

%!test
%! sz = 10;
%! P = reshape( 1:sz^2, sz, sz );
%! normP = repmat(sum(P,2),1,columns(P));
%! P = P./normP;
%! M = dtmcfpt(P);
%! for i=1:rows(P)
%!   for j=1:columns(P)
%!     assert( M(i,j), 1 + dot(P(i,:), M(:,j)) - P(i,j)*M(j,j), 1e-8);
%!   endfor
%! endfor

## "Rat maze" problem (p. 453 of [GrSn97]);
%!test
%! P = zeros(9,9);
%! P(1,[2 4]) = .5;
%! P(2,[1 5 3]) = 1/3;
%! P(3,[2 6]) = .5;
%! P(4,[1 5 7]) = 1/3;
%! P(5,[2 4 6 8]) = 1/4;
%! P(6,[3 5 9]) = 1/3;
%! P(7,[4 8]) = .5;
%! P(8,[7 5 9]) = 1/3;
%! P(9,[6 8]) = .5;
%! M = dtmcfpt(P);
%! assert( M(1:9 != 5,5)', [6 5 6 5 5 6 5 6], 100*eps );

