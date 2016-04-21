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
## @deftypefn {Function File} {[@var{t} @var{N} @var{B}] =} dtmcmtta (@var{P})
## @deftypefnx {Function File} {[@var{t} @var{N} @var{B}] =} dtmcmtta (@var{P}, @var{p0})
##
## @cindex mean time to absorption, DTMC
## @cindex absorption probabilities, DTMC
## @cindex fundamental matrix
## @cindex DTMC
## @cindex discrete time Markov chain
## @cindex Markov chain, discrete time
##
## Compute the expected number of steps before absorption for a
## DTMC with @math{N \times N} transition probability matrix @var{P};
## compute also the fundamental matrix @var{N} for @var{P}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @math{N \times N} transition probability matrix.
##
## @end table
##
## @strong{OUTPUTS} 
##
## @table @var
##
## @item t
## When called with a single argument, @var{t} is a vector of size
## @math{N} such that @code{@var{t}(i)} is the expected number of steps
## before being absorbed in any absorbing state, starting from state
## @math{i}; if @math{i} is absorbing, @code{@var{t}(i) = 0}. When
## called with two arguments, @var{t} is a scalar, and represents the
## expected number of steps before absorption, starting from the initial
## state occupancy probability @var{p0}.
##
## @item N
## When called with a single argument, @var{N} is the @math{N \times N}
## fundamental matrix for @var{P}. @code{@var{N}(i,j)} is the expected
## number of visits to transient state @var{j} before absorption, if it
## is started in transient state @var{i}. The initial state is counted
## if @math{i = j}. When called with two arguments, @var{N} is a vector
## of size @math{N} such that @code{@var{N}(j)} is the expected number
## of visits to transient state @var{j} before absorption, given initial
## state occupancy probability @var{P0}.
##
## @item B
## When called with a single argument, @var{B} is a @math{N \times N}
## matrix where @code{@var{B}(i,j)} is the probability of being absorbed
## in state @math{j}, starting from transient state @math{i}; if
## @math{j} is not absorbing, @code{@var{B}(i,j) = 0}; if @math{i}
## is absorbing, @code{@var{B}(i,i) = 1} and
## @code{@var{B}(i,j) = 0} for all @math{j \neq j}. When called with
## two arguments, @var{B} is a vector of size @math{N} where
## @code{@var{B}(j)} is the probability of being absorbed in state
## @var{j}, given initial state occupancy probabilities @var{p0}.
##
## @end table
##
## @seealso{ctmcmtta}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [t N B] = dtmcmtta( P, p0 )

  persistent epsilon = 10*eps;

  if ( nargin < 1 || nargin > 2 )
    print_usage();
  endif

  [K err] = dtmcchkP(P);

  (K>0) || \
      error(err);
  
  if ( nargin == 2 )
    ( isvector(p0) && length(p0) == K && all(p0>=0) && abs(sum(p0)-1.0)<epsilon ) || \
	error( "p0 must be a state occupancy probability vector" );
  endif

  ## identify transient states
  tr = find(diag(P) < 1);
  ab = find(diag(P) == 1);
  k = length(tr); # number of transient states
  if ( k == K )
    error("There are no absorbing states");
  endif

  N = B = zeros(size(P));
  t = zeros(1,rows(P));

  ## Source: Grinstead, Charles M.; Snell, J. Laurie (July 1997). "Ch.
  ## 11: Markov Chains". Introduction to Probability. American
  ## Mathematical Society. ISBN 978-0821807491.
  ## http://www.cs.virginia.edu/~gfx/Courses/2006/DataDriven/bib/texsyn/Chapter11.pdf

  tmpN = inv(eye(k) - P(tr,tr)); # matrix N = (I-Q)^-1
  N(tr,tr) = tmpN;
  R = P(tr,ab);

  res = tmpN * ones(k,1);
  t(tr) = res;

  tmp = tmpN*R;
  B(tr,ab) = tmp;
  ## set B(i,i) = 1 for all absorbing states i
  dd = diag(B);
  dd(ab) = 1;
  B(1:K+1:end) = dd;

  if ( nargin == 2 )
    t = dot(p0,t);
    N = p0*N;
    B = p0*B;
  endif

endfunction
%!test
%! fail( "dtmcmtta(1,2,3)" );
%! fail( "dtmcmtta()" );

%!test
%! P = dtmcbd([0 .5 .5 .5], [.5 .5 .5 0]);
%! [t N B] = dtmcmtta(P);
%! assert( t, [0 3 4 3 0], 10*eps );
%! assert( B([2 3 4],[1 5]), [3/4 1/4; 1/2 1/2; 1/4 3/4], 10*eps );
%! assert( B(1,1), 1 );
%! assert( B(5,5), 1 );

%!test
%! P = dtmcbd([0 .5 .5 .5], [.5 .5 .5 0]);
%! [t N B] = dtmcmtta(P);
%! assert( t(3), 4, 10*eps );
%! assert( B(3,1), 0.5, 10*eps );
%! assert( B(3,5), 0.5, 10*eps );

## Example on p. 422 of [GrSn97]
%!test
%! P = dtmcbd([0 .5 .5 .5 .5], [.5 .5 .5 .5 0]);
%! [t N B] = dtmcmtta(P);
%! assert( t(2:5), [4 6 6 4], 100*eps );
%! assert( B(2:5,1), [.8 .6 .4 .2]', 100*eps );
%! assert( B(2:5,6), [.2 .4 .6 .8]', 100*eps );

## Compute the probability of completing the "snakes and ladders"
## game in n steps, for various values of n. Also, computes the expected
## number of steps which are necessary to complete the game.
## Source: 
## http://mapleta.emich.edu/aross15/coursepack3419/419/ch-04/chutes-and-ladders.pdf
%!demo
%! n = 6;
%! P = zeros(101,101);
%! for j=0:(100-n)
%!   i=1:n;
%!   P(1+j,1+j+i) = 1/n;
%! endfor  
%! for j=(101-n):100 
%!   P(1+j,1+j) = (n-100+j)/n;
%! endfor
%! for j=(101-n):100
%!   i=1:(100-j);
%!   P(1+j,1+j+i) = 1/n;
%! endfor
%! Pstar = P;
%! ## setup snakes and ladders
%! SL = [1 38; \
%!       4 14; \
%!       9 31; \
%!       16 6; \
%!       21 42; \
%!       28 84; \
%!       36 44; \
%!       47 26; \
%!       49 11; \
%!       51 67; \
%!       56 53; \
%!       62 19; \
%!       64 60; \
%!       71 91; \
%!       80 100; \
%!       87 24; \
%!       93 73; \
%!       95 75; \
%!       98 78 ];
%! for ii=1:rows(SL);
%!   i = SL(ii,1);
%!   j = SL(ii,2);
%!   Pstar(1+i,:) = 0;
%!   for k=0:100
%!     if ( k != i )
%!       Pstar(1+k,1+j) = P(1+k,1+j) + P(1+k,1+i);
%!     endif
%!   endfor
%!   Pstar(:,1+i) = 0;
%! endfor
%! Pstar += diag( 1-sum(Pstar,2) );
%! # spy(Pstar); pause
%! nsteps = 250; # number of steps
%! Pfinish = zeros(1,nsteps); # Pfinish(i) = probability of finishing after step i
%! pstart = zeros(1,101); pstart(1) = 1; pn = pstart;
%! for i=1:nsteps
%!   pn = pn*Pstar;
%!   Pfinish(i) = pn(101); # state 101 is the ending (absorbing) state
%! endfor
%! f = dtmcmtta(Pstar,pstart);
%! printf("Average number of steps to complete the game: %f\n", f );
%! plot(Pfinish,"linewidth",2);
%! line([f,f],[0,1]);
%! text(f*1.1,0.2,["Mean Time to Absorption (" num2str(f) ")"]);
%! xlabel("Step number (n)");
%! title("Probability of finishing the game before step n");

## "Rat maze" problem (p. 453 of [GrSn97]);
%!test
%! P = zeros(9,9);
%! P(1,[2 4]) = .5;
%! P(2,[1 5 3]) = 1/3;
%! P(3,[2 6]) = .5;
%! P(4,[1 5 7]) = 1/3;
%! P(5,:) = 0; P(5,5) = 1;
%! P(6,[3 5 9]) = 1/3;
%! P(7,[4 8]) = .5;
%! P(8,[7 5 9]) = 1/3;
%! P(9,[6 8]) = .5;
%! t = dtmcmtta(P);
%! assert( t, [6 5 6 5 0 5 6 5 6], 10*eps );

