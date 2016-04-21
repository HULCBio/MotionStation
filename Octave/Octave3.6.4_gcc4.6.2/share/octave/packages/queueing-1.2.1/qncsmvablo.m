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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncsmvablo (@var{N}, @var{S}, @var{M}, @var{P} )
##
## @cindex queueing network with blocking
## @cindex blocking queueing network
## @cindex closed network, finite capacity
## @cindex MVABLO
##
## Approximate MVA algorithm for closed queueing networks with blocking.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## population size, i.e., number of requests in the system. @var{N} must
## be strictly greater than zero, and less than the overall network capacity:
## @code{0 < @var{N} < sum(@var{M})}.
##
## @item S
## Average service time. @code{@var{S}(i)} is the average service time 
## requested on server @math{i} (@code{@var{S}(i) > 0}).
##
## @item M
## @code{@var{M}(i)} is the capacity of center
## @math{i}. The capacity is the maximum number of requests in a service
## center, including the request currently in service (@code{@var{M}(i) @geq{} 1}).
##
## @item P
## @code{@var{P}(i,j)} is the probability that a request which completes
## service at server @math{i} will be transferred to server @math{j}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## @code{@var{U}(i)} is the utilization of
## service center @math{i}.
##
## @item R
## @code{@var{R}(i)} is the average response time
## of service center @math{i}.
##
## @item Q
## @code{@var{Q}(i)} is
## the average number of requests in service center @math{i} (including
## the request in service).
##
## @item X
## @code{@var{X}(i)} is the throughput of
## service center @math{i}.
##
## @end table
##
## @seealso{qnopen, qnclosed}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qncsmvablo( K, S, M, P )

  ## Note that we use "K" instead of "N" as the number of requests in
  ## order to be compliant with the paper by Akyildiz describing this
  ## algorithm.

  if ( nargin != 4 ) 
    print_usage();
  endif
  ( isscalar(K) && K > 0 ) || \
      error( "K must be a positive integer" );
  isvector(S) && all(S>0) || \
      error ("S must be a vector > 0");
  S = S(:)'; # make S a row vector
  N = length(S);
  ( isvector(M) && length(M) == N ) || \
      error( "M must be a vector with %d elements", N );
  all( M >= 1) || \
      error( "M must be >= 1");
  M = M(:)'; # make M a row vector

  (K < sum(M)) || \
      error( "The population size K=%d exceeds the total system capacity %d", K, sum(M) );

  [na err] = dtmcchkP(P);
  ( na>0 ) || \
      error( err );

  rows(P) == N || \
      error("The number of rows of P must be equal to the length of S");

  ## Note: in this implementation we make use of the same notation found
  ## in Akyildiz's paper cited in the REFERENCES above, with the minor
  ## exception of using 'v' instead of 'e' as the visit count vector.
  ## k_bar(i) is the average number of jobs in the i-th server, lambda
  ## is the network throughput, t_bar(i) is the mean residence time
  ## (time spent in queue and in service) for requests in the i-th
  ## service center.

  ## Initialization
  k_bar_m1 = zeros(1,N); # k_bar(k-1)
  BT = zeros(1,N);
  z = ones(1,N);
  lambda = 0;
  ## Computation of the visit counts
  v = qncsvisits(P);
  D = S .* v; # Service demand
  ## Main loop
  for k=1:K
    do
    ## t_bar_i(k) = S(i) *(z_i(k) + k_bar_i(k-1))+BT_i(k)
      t_bar = S .* ( z + k_bar_m1 ) + BT; 
      lambda = k / dot(v,t_bar);
      k_bar = t_bar .* v * lambda;
      if ( any(k_bar>M) )
        i = find( k_bar > M, 1 );
        z(i) = 0;
        BT = BT + S(i) * ( v .* P(:,i)' ) / v(i);
      endif
    until( all(k_bar<=M) );
    k_bar_m1 = k_bar;
  endfor
  R = t_bar;
  X = v * lambda; # Throughputs
  ## w_bar = t_bar - S - BT; # mean waiting time
  U = X .* S;
  Q = X .* R;
endfunction
%!test
%! fail( "qncsmvablo( 10, [1 1], [4 5], [0 1; 1 0] )", "capacity");
%! fail( "qncsmvablo( 6, [1 1], [4 5], [0 1; 1 1] )", "stochastic");
%! fail( "qncsmvablo( 5, [1 1 1], [1 1], [0 1; 1 1] )", "3 elements");

%!test
%! # This is the example on section v) p. 422 of the reference paper
%! M = [12 10 14];
%! P = [0 1 0; 0 0 1; 1 0 0];
%! S = [1/1 1/2 1/3];
%! K = 27;
%! [U R Q X]=qncsmvablo( K, S, M, P );
%! assert( R, [11.80 1.66 14.4], 1e-2 );

%!test
%! # This is example 2, i) and ii) p. 424 of the reference paper
%! M = [4 5 5];
%! S = [1.5 2 1];
%! P = [0 1 0; 0 0 1; 1 0 0];
%! K = 10;
%! [U R Q X]=qncsmvablo( K, S, M, P );
%! assert( R, [6.925 8.061 4.185], 1e-3 );
%! K = 12;
%! [U R Q X]=qncsmvablo( K, S, M, P );
%! assert( R, [7.967 9.019 8.011], 1e-3 );

%!test
%! # This is example 3, i) and ii) p. 424 of the reference paper
%! M = [8 7 6];
%! S = [0.2 1.2 1.4];
%! P = [ 0 0.5 0.5; 1 0 0; 1 0 0 ];
%! K = 10;
%! [U R Q X] = qncsmvablo( K, S, M, P );
%! assert( R, [1.674 5.007 7.639], 1e-3 );
%! K = 12;
%! [U R Q X] = qncsmvablo( K, S, M, P );
%! assert( R, [2.166 5.372 6.567], 1e-3 );

%!test
%! # Network which never blocks, central server model
%! M = [50 50 50];
%! S = [1 1/0.8 1/0.4];
%! P = [0 0.7 0.3; 1 0 0; 1 0 0];
%! K = 40;
%! [U1 R1 Q1] = qncsmvablo( K, S, M, P );
%! V = qncsvisits(P);
%! [U2 R2 Q2] = qncsmva( K, S, V );
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );

