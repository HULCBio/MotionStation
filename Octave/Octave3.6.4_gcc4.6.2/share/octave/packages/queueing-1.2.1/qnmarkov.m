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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnmarkov (@var{lambda}, @var{S}, @var{C}, @var{P})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnmarkov (@var{lambda}, @var{S}, @var{C}, @var{P}, @var{m})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnmarkov (@var{N}, @var{S}, @var{C}, @var{P})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnmarkov (@var{N}, @var{S}, @var{C}, @var{P}, @var{m})
##
## @cindex closed network, multiple classes
## @cindex closed network, finite capacity
## @cindex blocking queueing network
## @cindex RS blocking
##
## Compute utilization, response time, average queue length and
## throughput for open or closed queueing networks with finite capacity.
## Blocking type is Repetitive-Service (RS). This function explicitly
## generates and solve the underlying Markov chain, and thus might
## require a large amount of memory.
## 
## More specifically, networks which can me analyzed by this
## function have the following properties:
##
## @itemize @bullet
##
## @item There exists only a single class of customers.
##
## @item The network has @math{K} service centers. Center
## @math{i} has @math{m_i > 0} servers, and has a total (finite) capacity of
## @math{C_i \geq m_i} which includes both buffer space and servers.
## The buffer space at service center @math{i} is therefore
## @math{C_i - m_i}.
##
## @item The network can be open, with external arrival rate to
## center @math{i} equal to 
## @math{\lambda_i}, or closed with fixed
## population size @math{N}. For closed networks, the population size
## @math{N} must be strictly less than the network capacity: @math{N < \sum_i C_i}.
##
## @item Average service times are load-independent.
##
## @item @math{P_{i, j}} is the probability that requests completing
## execution at center @math{i} are transferred to
## center @math{j}, @math{i \neq j}. For open networks, a request may leave the system
## from any node @math{i} with probability @math{1-\sum_j P_{i, j}}.
##
## @item Blocking type is Repetitive-Service (RS). Service
## center @math{j} is @emph{saturated} if the number of requests is equal
## to its capacity @math{C_j}. Under the RS blocking discipline,
## a request completing service at center @math{i} which is being
## transferred to a saturated server @math{j} is put back at the end of
## the queue of @math{i} and will receive service again. Center @math{i}
## then processes the next request in queue. External arrivals to a
## saturated servers are dropped.
##
## @end itemize
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## @itemx N
## If the first argument is a vector @var{lambda}, it is considered to be
## the external arrival rate @code{@var{lambda}(i) @geq{} 0} to service center
## @math{i} of an open network. If the first argument is a scalar, it is
## considered as the population size @var{N} of a closed network; in this case
## @var{N} must be strictly
## less than the network capacity: @code{@var{N} < sum(@var{C})}.
##
## @item S
## @code{@var{S}(i)} is the average service time at service center
## @math{i}
##
## @item C
## @code{@var{C}(i)} is the Capacity of service center @math{i}. The capacity includes both
## the buffer and server space @code{@var{m}(i)}. Thus the buffer space is
## @code{@var{C}(i)-@var{m}(i)}.
##
## @item P
## @code{@var{P}(i,j)} is the transition probability from service center
## @math{i} to service center @math{j}.
##
## @item m
## @code{@var{m}(i)} is the number of servers at service center
## @math{i}. Note that @code{@var{m}(i) @geq{} @var{C}(i)} for each @var{i}.
## If @var{m} is omitted, all service centers are assumed to have a
## single server (@code{@var{m}(i) = 1} for all @math{i}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## @code{@var{U}(i)} is the utilization of service center @math{i}.
##
## @item R
## @code{@var{R}(i)} is the response time on service center @math{i}.
##
## @item Q
## @code{@var{Q}(i)} is the average number of customers in the
## service center @math{i}, @emph{including} the request in service.
##
## @item X
## @code{@var{X}(i)} is the throughput of service center @math{i}.
##
## @end table
##
## @quotation Note
##
## The space complexity of this implementation is
## @math{O( \prod_{i=1}^K (C_i + 1)^2)}. The time complexity is dominated
## by the time needed to solve a linear system with 
## @math{\prod_{i=1}^K (C_i + 1)}
## unknowns.
##
## @end quotation
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnmarkov( x, S, C, P, m )

  if ( nargin < 4 || nargin > 5 )
    print_usage();
  endif

  isvector(S) || error( "S must be a vector" );
  K = length(S); # number of service centers

  if ( nargin < 5 )
    m = ones(1,K);
  else
    size_equal(m,S) || error( "m must have the same langth as S" );
  endif

  ( [K,K] == size(P) && all( all(P>=0)) && all(sum(P,2) <= 1)) || \
      error( "P must be SxS and nonnegative" );

  if ( isscalar(x) )
    is_open = false;
    N = x; # closed network
    ( N < sum(C) ) || \
        error( "The population size exceeds the network capacity" );
    all( abs(sum(P,2)-1) < 1000*eps ) || \
        error( "P for closed networks cannot have exit nodes" );
  else
    is_open = true;
    lambda = x; # open network
    size_equal(lambda, S ) || \
        error( "lambda must have the same langth as S" );
  endif

  ( all(m > 0) && all(m <= C) ) || \
      error( "Capacities C must be greater or equal than m" );

  q_size = prod( C+1 ); # number of states of the system

  ## The infinitesimal generator matrix Q_markovmight be sparse, so it
  ## would be appropriate to represent it as a sparse matrix. In this
  ## case the UMFPACK library must be installed to solve the @math{{\bf
  ## A}x=b} sparse system. Since I'm not sure everyone built Octave with
  ## sparse matrix support, I leave Q_markov as a full matrix here.
  Q_markov = zeros( q_size, q_size );
  cur_state = zeros(1, K);

  if ( is_open ) 
    valid_populations = linspace(0, sum(C), sum(C)+1);
  else
    valid_populations = [ N ];
  endif
  ## exit_prob(i) is the probability that a job leaves the system from node i
  exit_prob = 1 - sum(P,2);
  for n=valid_populations
    pop_mix = qncmpopmix( n, C );
    for cur_state=pop_mix' # for each feasible configuration with n customers
      cur_idx = sub2cell( C, cur_state );
      for i=1:K
        if ( is_open ) # for open networks only
          ## handle new external arrival to center i
          if ( lambda(i) > 0 && cur_state(i) < C(i) )
            next_state = cur_state; next_state(i) += 1;
            next_idx = sub2cell( C, next_state );
            Q_markov( cur_idx, next_idx ) = lambda(i);
          endif
          ## handle requests that leave the system from center i
          ## exit_prob = 1-sum(P(i,:));
          if ( exit_prob(i) > 0 && cur_state(i) > 0 )
            next_state = cur_state; next_state(i) -= 1;
            next_idx = sub2cell( C, next_state );
            Q_markov( cur_idx, next_idx ) = min(m(i), cur_state(i))*exit_prob(i)/S(i);            
          endif
        endif # end open networks only
        ## for both open and closed networks
        for j=[1:(i-1) (i+1):K]
          ## check whether a job can move from server i to server j!=i
          if ( cur_state(i) > 0 && cur_state(j) < C(j) && P(i,j) > 0 )
            next_state = cur_state; next_state(i) -= 1; next_state(j) += 1;
            next_idx = sub2cell( C, next_state );
            Q_markov( cur_idx, next_idx ) = min(m(i), cur_state(i))*P(i,j)/S(i);
          endif
        endfor
      endfor
    endfor
  endfor
  ##spy( Q_markov );
  ## complete the diagonal elements of the matrix Q
  d = sum(Q_markov,2);
  Q_markov -= diag( d );
  ## Solve the ctmc
  prob = ctmc( Q_markov );
  ## Compute the average queue length
  p = zeros(K, max(C)+1); # p(k,i+1) = prob that there are i requests at service center k
  for n=valid_populations
    pop_mix = qncmpopmix( n, C );
    for cur_state=pop_mix'
      cur_idx = sub2cell( C, cur_state );
      for k=1:K
        i=cur_state(k);
        p(k,i+1) += prob(cur_idx);
      endfor
    endfor
  endfor
  ## We can now compute all the performance measures
  U = R = Q = X = zeros(1,K);
  for k=1:K
    j = [0:m(k)-1];
    U(k) = 1 - sum( ( m(k) - j ) ./ m(k) .* p(k,1+j) );
    ##X(k) = U(k)/S(k);
    j = [1:C(k)];
    Q(k) = sum( j .* p(k,1+j) );
    ##R(k) = Q(k)/X(k);
  endfor
  X = U./S;
  R = Q./X;
endfunction
%!test
%! S = [5 2.5];
%! P = [0 1; 1 0];
%! C = [3 3];
%! m = [1 1];
%! [U R Q X] = qnmarkov( 3, S, C, P, m );
%! assert( U, [0.9333 0.4667], 1e-4 );
%! assert( X, [0.1867 0.1867], 1e-4 );
%! assert( R, [12.1429 3.9286], 1e-4 );

## Example 7.5 p. 292 Bolch et al.
%!test
%! S = [1/0.8 1/0.6 1/0.4];
%! P = [0.6 0.3 0.1; 0.2 0.3 0.5; 0.4 0.1 0.5];
%! C = [3 3 3];
%! [U R Q X] = qnmarkov( 3, S, C, P );
%! assert( U, [0.543 0.386 0.797], 1e-3 );
%! assert( Q, [0.873 0.541 1.585], 1e-3 );

## Example 10.19, p. 551 Bolch et al.
%!xtest
%! S = [2 0.9];
%! C = [7 5];
%! P = [0 1; 1 0];
%! [U R Q X] = qnmarkov( 10, S, C, P );
%! assert( Q, [6.73 3.27], 1e-3 );

## Example 8.1 p. 317 Bolch et al.
%!test
%! S = [1/0.8 1/0.6 1/0.4];
%! P = [(1-0.667-0.2) 0.667 0.2; 1 0 0; 1 0 0];
%! m = [2 3 1];
%! C = [3 3 3];
%! [U R Q X] = qnmarkov( 3, S, C, P, m );
%! assert( U, [0.590 0.350 0.473], 1e-3 );
%! assert( Q(1:2), [1.290 1.050], 1e-3 );

## This is a simple test of an open QN with fixed capacity queues. There
## are two service centers, S1 and S2. C(1) = 2 and C(2) = 1. Transition
## probability from S1 to S2 is 1. Transition probability from S2 to S1
## is p.
%!test
%! p = 0.5; # transition prob. from S2 to S1
%! mu = [1 2]; # Service rates
%! C = [2 1]; # Capacities
%! lambda = [0.5 0]; # arrival rate at service center 1
%!
%! PP = [ 0 1; p 0 ];
%! [U R Q X] = qnmarkov( lambda, 1./mu, C, PP );
%! ## Now we generate explicitly the infinitesimal generator matrix
%! ## of the underlying MC.
%! ##    00  01  10  11  20  21
%! QQ = [ 0 0 lambda(1) 0 0 0; ... ## 00
%!        mu(2)*(1-p) 0 mu(2)*p lambda(1) 0 0; ... ## 01
%!        0 mu(1) 0 0 lambda(1) 0; ... ## 10
%!        0 0 mu(2)*(1-p) 0 mu(2)*p lambda(1); ... ## 11
%!        0 0 0 mu(1) 0 0; ... ## 20
%!        0 0 0 0 mu(2)*(1-p) 0 ]; ## 21
%! ## Complete matrix
%! sum_el = sum(QQ,2);
%! QQ -= diag(sum_el);
%! q = ctmc(QQ);
%! ## Compare results
%! assert( U(1), 1-sum(q([1, 2])), 1e-5 );
%! assert( U(2), 1-sum(q([1,3,5])), 1e-5 );

## This is a closed network with fixed-capacity queues. The population
## size N is such that blocking never occurs, so this model can be
## analyzed using the conventional MVA algorithm. MVA and qnmarkov()
## must produce the same results.
%!test
%! P = [0 0.5 0.5; 1 0 0; 1 0 0];
%! C = [6 6 6];
%! S = [1 0.8 1.8];
%! N = 6;
%! [U1 R1 Q1 X1] = qnclosed( N, S, qncsvisits(P) );
%! [U2 R2 Q2 X2] = qnmarkov( N, S, C, P );
%! assert( U1, U2, 1e-6 );
%! assert( R1, R2, 1e-6 );
%! assert( Q1, Q2, 1e-6 );
%! assert( X1, X2, 1e-6 );

## return a linear index corresponding to index idx on a
## multidimensional vector of dimension(s) dim
function i = sub2cell( dim, idx )
  idx_cell = num2cell( idx+1 );
  i = sub2ind( dim+1, idx_cell{:} );
endfunction

