## Copyright (C) 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {@var{t} =} ctmcmtta (@var{Q}, @var{p})
##
## @cindex Markov chain, continuous time
## @cindex continuous time Markov chain
## @cindex CTMC
## @cindex mean time to absorption, CTMC
##
## Compute the Mean-Time to Absorption (MTTA) of the CTMC described by
## the infinitesimal generator matrix @var{Q}, starting from initial
## occupancy probabilities @var{p}. If there are no absorbing states, this
## function fails with an error.
##
## @strong{INPUTS}
##
## @table @var
##
## @item Q
## @math{N \times N} infinitesimal generator matrix. @code{@var{Q}(i,j)}
## is the transition rate from state @math{i} to state @math{j}, @math{i
## \neq j}. The matrix @var{Q} must satisfy the condition
## @math{\sum_{j=1}^N Q_{i j} = 0}
##
## @item p
## @code{@var{p}(i)} is the probability that the system is in state @math{i}
## at time 0, for each @math{i=1, @dots{}, N}
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item t
## Mean time to absorption of the process represented by matrix @var{Q}.
## If there are no absorbing states, this function fails.
##
## @end table
##
## @seealso{dtmcmtta}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function t = ctmcmtta( Q, p )

  persistent epsilon = 10*eps;

  if ( nargin != 2 )
    print_usage();
  endif

  [N err] = ctmcchkQ(Q);

  (N>0) || \
      error(err);

  ( isvector(p) && length(p) == N && all(p>=0) && abs(sum(p)-1.0)<epsilon ) || \
      error( "p must be a probability vector" );
  p = p(:)';

  L = ctmcexps(Q,p);
  t = sum(L);
endfunction
%!test
%! Q = [0 1 0; 1 0 1; 0 1 0 ]; Q -= diag( sum(Q,2) );
%! fail( "ctmcmtta(Q,[1 0 0])", "no absorbing");

%!test
%! Q = [0 1 0; 1 0 1; 0 0 0; 0 0 0 ];
%! fail( "ctmcmtta(Q,[1 0 0])", "square matrix");

%!test
%! Q = [0 1 0; 1 0 1; 0 0 0 ];
%! fail( "ctmcmtta(Q,[1 0 0])", "infinitesimal");

%!test
%! Q = [ 0 0.1 0 0; \
%!       0.9 0 0.1 0; \
%!       0 0.9 0 0.1; \
%!       0 0 0 0 ];
%! Q -= diag( sum(Q,2) );
%! assert( ctmcmtta( Q,[0 0 0 1] ), 0 ); # state 4 is absorbing

%!test
%! Q = [-1 1; 0 0];
%! assert( ctmcmtta( Q, [0 1] ), 0 ); # state 2 is absorbing
%! assert( ctmcmtta( Q, [1 0] ), 1 ); # the result has been computed by hand

## Compute the MTTA of a pure death process with 4 states
## (state 1 is absorbing). State 4 is the initial state.
%!demo
%! mu = 0.01;
%! death = [ 3 4 5 ] * mu;
%! birth = 0*death;
%! Q = ctmcbd(birth,death);
%! t = ctmcmtta(Q,[0 0 0 1])

%!demo
%! N = 100;
%! birth = death = ones(1,N-1); birth(1) = death(N-1) = 0;
%! Q = diag(birth,1)+diag(death,-1); 
%! Q -= diag(sum(Q,2));
%! t = zeros(1,N/2);
%! initial_state = 1:(N/2);
%! for i=initial_state
%!   p = zeros(1,N); p(i) = 1;
%!   t(i) = ctmcmtta(Q,p);
%! endfor
%! plot(initial_state,t,"+");
%! xlabel("Initial state");
%! ylabel("MTTA");


