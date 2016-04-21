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
## @deftypefn {Function File} {@var{p} =} ctmc (@var{Q})
## @deftypefnx {Function File} {@var{p} =} ctmc (@var{Q}, @var{t}. @var{p0})
##
## @cindex Markov chain, continuous time
## @cindex continuous time Markov chain
## @cindex Markov chain, state occupancy probabilities
## @cindex stationary probabilities
## @cindex CTMC
##
## Compute stationary or transient state occupancy probabilities for a continuous-time Markov chain.
##
## With a single argument, compute the stationary state occupancy
## probability vector @var{p}(1), @dots{}, @var{p}(N) for a
## continuous-time Markov chain with state space @math{@{1, 2, @dots{},
## N@}} and @math{N \times N} infinitesimal generator matrix @var{Q}.
## With three arguments, compute the state occupancy probabilities
## @var{p}(1), @dots{}, @var{p}(N) that the system is in state @math{i}
## at time @var{t}, given initial state occupancy probabilities
## @var{p0}(1), @dots{}, @var{p0}(N) at time 0.
##
## @strong{INPUTS}
##
## @table @var
##
## @item Q
## Infinitesimal generator matrix. @var{Q} is a @math{N \times N} square
## matrix where @code{@var{Q}(i,j)} is the transition rate from state
## @math{i} to state @math{j}, for @math{1 @leq{} i \neq j @leq{} N}.
## #var{Q} must satisfy the property that @math{\sum_{j=1}^N Q_{i, j} =
## 0}
##
## @item t
## Time at which to compute the transient probability (@math{t @geq{}
## 0}). If omitted, the function computes the steady state occupancy
## probability vector.
##
## @item p0
## @code{@var{p0}(i)} is the probability that the system
## is in state @math{i} at time 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item p
## If this function is invoked with a single argument, @code{@var{p}(i)}
## is the steady-state probability that the system is in state @math{i},
## @math{i = 1, @dots{}, N}. If this function is invoked with three
## arguments, @code{@var{p}(i)} is the probability that the system is in
## state @math{i} at time @var{t}, given the initial occupancy
## probabilities @var{p0}(1), @dots{}, @var{p0}(N).
##
## @end table
##
## @seealso{dtmc}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function q = ctmc( Q, t, p0 )

  persistent epsilon = 10*eps;

  if ( nargin != 1 && nargin != 3 )
    print_usage();
  endif

  [N err] = ctmcchkQ(Q);

  ( N>0 ) || \
      error(err);

  if ( nargin == 1 ) # steady-state analysis

    ## non zero columns
    nonzero=find( any(abs(Q)>epsilon,1 ) );
    if ( length(nonzero) == 0 )
      error( "Q is the zero matrix" );
    endif
    
    normcol = nonzero(1); # normalization condition column
    
    ## force probability of unvisited states to zero
    for i=find( all(abs(Q)<epsilon,1) )
      Q(i,i) = 1;
    endfor
    
    ## assert( rank(Q) == N-1 );
    
    Q(:,normcol) = 1; # add normalization condition
    b = zeros(1,N); b(normcol)=1;
    q = b/Q; # qQ = b;
    
  else # transient analysis

    ( isscalar(t) && t>=0 ) || \
        error("t must be a scalar >= 0");

    ( isvector(p0) && length(p0) == N && all(p0>=0) && abs(sum(p0)-1.0)<N*eps ) || \
        error( "p0 must be a probability vector" );   

    p0 = p0(:)'; # make p0 a row vector

    q = p0*expm(Q*t);

  endif

endfunction

%!test
%! Q = [-1 1 0 0; 2 -3 1 0; 0 2 -3 1; 0 0 2 -2];
%! q = ctmc(Q);
%! assert( q*Q, 0*q, 1e-5 );
%! assert( q, [8/15 4/15 2/15 1/15], 1e-5 );

## test failure patterns
%!test
%! fail( "ctmc([1 1; 1 1])", "infinitesimal" );
%! fail( "ctmc([1 1 1; 1 1 1])", "square" );

## test unvisited state.
%!test
%! Q = [0  0  0; ...
%!      0 -1  1; ...
%!      0  1 -1];
%! q = ctmc(Q);
%! assert( q*Q, 0*q, 1e-5 );
%! assert( q, [ 0 0.5 0.5 ], 1e-5 );

## Example 3.1 p. 123 Bolch et al.
%!test
%! lambda = 1;
%! mu = 2;
%! Q = [ -lambda lambda 0 0   ; ...
%!       mu -(lambda+mu) lambda 0  ; ...
%!       0 mu -(lambda+mu) lambda ; ...
%!       0 0 mu -mu ];
%! q = ctmc(Q);
%! assert( q, [8/15 4/15 2/15 1/15], 1e-5 );

## Example 3.4 p. 138 Bolch et al.
%!test
%! Q = [ -1 0.4 0.6 0 0 0; ...
%!       2 -3 0 0.4 0.6 0; ...
%!       3 0 -4 0 0.4 0.6; ...
%!       0 2 0 -2 0 0; ...
%!       0 3 2 0 -5 0; ...
%!       0 0 3 0 0 -3 ];
%! q = ctmc(Q);
%! assert( q, [0.6578 0.1315 0.1315 0.0263 0.0263 0.0263], 1e-4 );

## Example 3.2 p. 128 Bolch et al.
%!test
%! Q = [-1 1 0 0 0 0 0; ...
%!      0 -3 1 0 2 0 0; ...
%!      0 0 -3 1 0 2 0; ...
%!      0 0 0 -2 0 0 2; ...
%!      2 0 0 0 -3 1 0; ...
%!      0 2 0 0 0 -3 1; ...
%!      0 0 2 0 0 0 -2 ];
%! q = ctmc(Q);
%! assert( q, [0.2192 0.1644 0.1507 0.0753 0.1096 0.1370 0.1438], 1e-4 );

%!test
%! a = 0.2;
%! b = 0.8;
%! Q = [-a a; b -b];
%! qlim = ctmc(Q);
%! q = ctmc(Q, 100, [1 0]);
%! assert( qlim, q, 1e-5 );

## Example on p. 172 of [Tij03]
%!test
%! ll = 0.1;
%! mu = 100;
%! eta = 5;
%! Q = zeros(9,9);
%! ## 6--1, 7=sleep2 8=sleep1 9=crash
%! Q(6,5) = 6*ll;
%! Q(5,4) = 5*ll;
%! Q(4,3) = 4*ll;
%! Q(3,2) = 3*ll;
%! Q(2,1) = 2*ll;
%! Q(2,7) = mu;
%! Q(1,9) = ll;
%! Q(1,8) = mu;
%! Q(8,9) = ll;
%! Q(7,8) = 2*ll;
%! Q(7,6) = eta;
%! Q(8,6) = eta;
%! Q -= diag(sum(Q,2));
%! q0 = zeros(1,9); q0(6) = 1;
%! q = ctmc(Q,10,q0);
%! assert( q(9), 0.000504, 1e-6 );
%! q = ctmc(Q,2,q0);
%! assert( q, [3.83e-7 1.938e-4 0.0654032 0.2216998 0.4016008 0.3079701 0.0030271 0.0000998 5e-6], 1e-5 );
%! # Compute probability that no shuttle needs to leave during 10 years
%! Q(7,:) = Q(8,:) = 0; # make states 7 and 8 absorbing
%! q = ctmc(Q,10,q0);
%! assert( 1-sum(q(7:9)), 0.3901, 1e-4 );

%!demo
%! Q = [ -1  1; \
%!        1 -1  ];
%! q = ctmc(Q)

%!demo
%! a = 0.2;
%! b = 0.15;
%! Q = [ -a a; b -b];
%! T = linspace(0,14,50);
%! pp = zeros(2,length(T));
%! for i=1:length(T)
%!   pp(:,i) = ctmc(Q,T(i),[1 0]);
%! endfor
%! ss = ctmc(Q); # compute steady state probabilities
%! plot( T, pp(1,:), "b;p_0(t);", "linewidth", 2, \
%!       T, ss(1)*ones(size(T)), "b;Steady State;", \
%!       T, pp(2,:), "r;p_1(t);", "linewidth", 2, \
%!       T, ss(2)*ones(size(T)), "r;Steady State;" );
%! xlabel("Time");

## This example is from: David I. Heimann, Nitin Mittal, Kishor S. Trivedi,
## "Availability and Reliability Modeling for Computer Systems", sep 1989,
## section 2.4.
## **NOTE** the value of \pi_0 reported in the paper appears to be wrong
## (it is written as 0.00000012779, but probably should be 0.0000012779).
%!test
%! sec = 1;
%! min = 60*sec;
%! hour = 60*min;
%! ## the state space enumeration is {2, RC, RB, 1, 0}
%! a = 1/(10*min);    # 1/a = duration of reboot (10 min)
%! b = 1/(30*sec);    # 1/b = reconfiguration time (30 sec)
%! g = 1/(5000*hour); # 1/g = processor MTTF (5000 hours)
%! d = 1/(4*hour);    # 1/d = processor MTTR (4 hours)
%! c = 0.9;           # coverage
%! Q = [ -2*g 2*c*g 2*(1-c)*g      0  0 ; \
%!          0    -b         0      b  0 ; \
%!          0     0        -a      a  0 ; \
%!          d     0         0 -(g+d)  g ; \
%!          0     0         0      d -d];
%! p = ctmc(Q);
%! assert( p, [0.9983916, 0.000002995, 0.0000066559, 0.00159742, 0.0000012779], 1e-6 );
%! Q(3,:) = Q(5,:) = 0; # make states 3 and 5 absorbing
%! p0 = [1 0 0 0 0];
%! MTBF = ctmcmtta(Q, p0) / hour;
%! assert( fix(MTBF), 24857);

## This example is from: David I. Heimann, Nitin Mittal, Kishor S. Trivedi,
## "Availability and Reliability Modeling for Computer Systems", sep 1989,
## section 2.5
%!demo
%! sec  = 1;
%! min  = 60*sec;
%! hour = 60*min;
%! day  = 24*hour;
%! year = 365*day;
%! # state space enumeration {2, RC, RB, 1, 0}
%! a = 1/(10*min);    # 1/a = duration of reboot (10 min)
%! b = 1/(30*sec);    # 1/b = reconfiguration time (30 sec)
%! g = 1/(5000*hour); # 1/g = processor MTTF (5000 hours)
%! d = 1/(4*hour);    # 1/d = processor MTTR (4 hours)
%! c = 0.9;           # coverage
%! Q = [ -2*g 2*c*g 2*(1-c)*g      0  0; \
%!          0    -b         0      b  0; \
%!          0     0        -a      a  0; \
%!          d     0         0 -(g+d)  g; \
%!          0     0         0      d -d];
%! p = ctmc(Q);
%! A = p(1) + p(4); 
%! printf("System availability   %9.2f min/year\n",A*year/min);
%! printf("Mean time in RB state %9.2f min/year\n",p(3)*year/min);
%! printf("Mean time in RC state %9.2f min/year\n",p(2)*year/min);
%! printf("Mean time in 0 state  %9.2f min/year\n",p(5)*year/min);
%! Q(3,:) = Q(5,:) = 0; # make states 3 and 5 absorbing
%! p0 = [1 0 0 0 0];
%! MTBF = ctmcmtta(Q, p0) / hour;
%! printf("System MTBF %.2f hours\n",MTBF);