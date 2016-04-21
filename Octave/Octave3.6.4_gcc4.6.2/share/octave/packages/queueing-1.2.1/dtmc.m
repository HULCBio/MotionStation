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
## @deftypefn {Function File} {@var{p} =} dtmc (@var{P})
## @deftypefnx {Function File} {@var{p} =} dtmc (@var{P}, @var{n}, @var{p0})
##
## @cindex Markov chain, discrete time
## @cindex discrete time Markov chain
## @cindex DTMC
## @cindex Markov chain, stationary probabilities
## @cindex Markov chain, transient probabilities
##
## Compute stationary or transient state occupancy probabilities for a discrete-time Markov chain.
##
## With a single argument, compute the stationary state occupancy
## probability vector @code{@var{p}(1), @dots{}, @var{p}(N)} for a
## discrete-time Markov chain with state space @math{@{1, 2, @dots{},
## N@}} and with @math{N \times N} transition probability matrix
## @var{P}. With three arguments, compute the transient state occupancy
## vector @code{@var{p}(1), @dots{}, @var{p}(N)} that the system is in
## state @math{i} after @var{n} steps, given initial occupancy
## probabilities @var{p0}(1), @dots{}, @var{p0}(N).
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @code{@var{P}(i,j)} is the transition probability from state @math{i}
## to state @math{j}. @var{P} must be an irreducible stochastic matrix,
## which means that the sum of each row must be 1 (@math{\sum_{j=1}^N
## P_{i, j} = 1}), and the rank of @var{P} must be equal to its
## dimension.
##
## @item n
## Number of transitions after which compute the state occupancy probabilities
## (@math{n=0, 1, @dots{}})
##
## @item p0
## @code{@var{p0}(i)} is the probability that at step 0 the system
## is in state @math{i}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item p
## If this function is called with a single argument, @code{@var{p}(i)}
## is the steady-state probability that the system is in state @math{i}.
## If this function is called with three arguments, @code{@var{p}(i)}
## is the probability that the system is in state @math{i}
## after @var{n} transitions, given the initial probabilities
## @code{@var{p0}(i)} that the initial state is @math{i}.
##
## @end table
##
## @seealso{ctmc}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function p = dtmc( P, n, p0 )

  if ( nargin != 1 && nargin != 3 )
    print_usage();
  endif

  [N err] = dtmcchkP(P);
  
  ( N>0 ) || \
      error( err );

  if ( nargin == 1 ) # steady-state analysis
    A = P-eye(N);
    A(:,N) = 1; # add normalization condition
    rank( A ) == N || \
	warning( "dtmc(): P is reducible" );
    
    b = [ zeros(1,N-1) 1 ];
    p = b/A;
  else # transient analysis
    ( isscalar(n) && n>=0 ) || \
	error( "n must be >=0" );

    ( isvector(p0) && length(p0) == N && all(p0>=0) && abs(sum(p0)-1.0)<N*eps ) || \
        error( "p0 must be a probability vector" );   

    p0 = p0(:)'; # make p0 a row vector

    p = p0*P^n;
  endif
endfunction

%!test
%! P = [0.75 0.25; 0.5 0.5];
%! p = dtmc(P);
%! assert( p*P, p, 1e-5 );
%! assert( p, [0.6666 0.3333], 1e-4 );

%!test
%! #Example 2.11 p. 44 Bolch et al.
%! P = [0.5 0.5; 0.5 0.5];
%! p = dtmc(P);
%! assert( p, [0.5 0.5], 1e-3 );

%!test
%! fail("dtmc( [1 1 1; 1 1 1] )", "square");

%!test
%! a = 0.2;
%! b = 0.8;
%! P = [1-a a; b 1-b];
%! plim = dtmc(P);
%! p = dtmc(P, 100, [1 0]);
%! assert( plim, p, 1e-5 );

%!test
%! P = [0 1 0 0 0; \
%!      .25 0 .75 0 0; \
%!      0 .5 0 .5 0; \
%!      0 0 .75 0 .25; \
%!      0 0 0 1 0 ];
%! p = dtmc(P);
%! assert( p, [.0625 .25 .375 .25 .0625], 10*eps );

## "Rat maze" problem (p. 441 of [GrSn97]);
%!test
%! P = zeros(9,9);
%! P(1,[2 4]) = 1/2;
%! P(2,[1 5 3]) = 1/3;
%! P(3,[2 6]) = 1/2;
%! P(4,[1 5 7]) = 1/3;
%! P(5,[2 4 6 8]) = 1/4;
%! P(6,[3 5 9]) = 1/3;
%! P(7,[4 8]) = 1/2;
%! P(8,[7 5 9]) = 1/3;
%! P(9,[6 8]) = 1/2;
%! p = dtmc(P);
%! assert( p, [1/12 1/8 1/12 1/8 1/6 1/8 1/12 1/8 1/12], 10*eps );

%!demo
%! P = zeros(9,9);
%! P(1,[2 4]    ) = 1/2;
%! P(2,[1 5 3]  ) = 1/3;
%! P(3,[2 6]    ) = 1/2;
%! P(4,[1 5 7]  ) = 1/3;
%! P(5,[2 4 6 8]) = 1/4;
%! P(6,[3 5 9]  ) = 1/3;
%! P(7,[4 8]    ) = 1/2;
%! P(8,[7 5 9]  ) = 1/3;
%! P(9,[6 8]    ) = 1/2;
%! p = dtmc(P);
%! disp(p)

%!demo
%! a = 0.2;
%! b = 0.15;
%! P = [ 1-a a; b 1-b];
%! T = 0:14;
%! pp = zeros(2,length(T));
%! for i=1:length(T)
%!   pp(:,i) = dtmc(P,T(i),[1 0]);
%! endfor
%! ss = dtmc(P); # compute steady state probabilities
%! plot( T, pp(1,:), "b+;p_0(t);", "linewidth", 2, \
%!       T, ss(1)*ones(size(T)), "b;Steady State;", \
%!       T, pp(2,:), "r+;p_1(t);", "linewidth", 2, \
%!       T, ss(2)*ones(size(T)), "r;Steady State;" );
%! xlabel("Time Step");
