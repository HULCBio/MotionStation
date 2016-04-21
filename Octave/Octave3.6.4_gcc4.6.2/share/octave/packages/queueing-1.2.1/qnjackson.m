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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnjackson (@var{lambda}, @var{S}, @var{P} )
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnjackson (@var{lambda}, @var{S}, @var{P}, @var{m} )
## @deftypefnx {Function File} {@var{pr} =} qnjackson (@var{lambda}, @var{S}, @var{P}, @var{m}, @var{k})
##
## @cindex open network, single class
## @cindex Jackson network
##
## This function is deprecated. Please use @code{qnopensingle} instead.
##
## With three or four arguments, this function computes the steady-state
## occupancy probabilities for a Jackson network. With five arguments,
## this function computes the steady-state probability
## @code{@var{pi}(j)} that there are @code{@var{k}(j)} requests at
## service center @math{j}.
##
## This function solves a subset of Jackson networks, with the
## following constraints:
##
## @itemize
##
## @item External arrival rates are load-independent.
## 
## @item Service center @math{i} consists either of @code{@var{m}(i) @geq{}
## 1} identical servers with individual average service time
## @code{@var{S}(i)}, or of an Infinite Server (IS) node.
##
## @end itemize
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## @code{@var{lambda}(i)} is
## the external arrival rate to service center @math{i}. @var{lambda}
## must be a vector of length @math{N}, @code{@var{lambda}(i) @geq{} 0}.
##
## @item S
## @code{@var{S}(i)} is the average service time on service center @math{i}
## @var{S} must be a vector of length @math{N}, @code{@var{S}(i)>0}.
##
## @item P
## @code{@var{P}(i,j)} is the probability
## that a job which completes service at service center @math{i} proceeds
## to service center @math{j}. @var{P} must be a matrix of size
## @math{N \times N}.
##
## @item m
## @code{@var{m}(i)} is the number of servers at center
## @math{i}. If @code{@var{m}(i) < 1}, center @math{i} is an
## infinite-server node. Otherwise, it is a regular FCFS queueing center with
## @code{@var{m}(i)} servers. Default is 1.
##
## @item k
## Compute the steady-state probability that there are @code{@var{k}(i)}
## requests at service center @math{i}. @var{k} must have the same length
## as @var{lambda}, with @code{@var{k}(i) @geq{} 0}.
## 
## @end table
##
## @strong{OUTPUT}
##
## @table @var
##
## @item U
## If @math{i} is a FCFS node, then
## @code{@var{U}(i)} is the utilization of service center @math{i}.
## If @math{i} is an IS node, then @code{@var{U}(i)} is the
## @emph{traffic intensity} defined as @code{@var{X}(i)*@var{S}(i)}.
##
## @item R
## @code{@var{R}(i)} is the average response time of service center @math{i}.
##
## @item Q
## @code{@var{Q}(i)} is the average number of customers in service center
## @math{i}.
##
## @item X
## @code{@var{X}(i)} is the throughput of service center @math{i}.
##
## @item pr
## @code{@var{pr}(i)} is the steady state probability 
## that there are @code{@var{k}(i)} requests at service center @math{i}.
##
## @end table
##
## @seealso{qnopen}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U_or_pi R Q X] = qnjackson( lambda, S, P, m, k )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnjackson is deprecated. Please use qnopensingle insgead");
  endif
  if ( nargin < 3 || nargin > 5 )
    print_usage();
  endif
  ( isvector(lambda) && all(lambda>=0) ) || \
      error( "lambda must be a vector >= 0" );
  lambda=lambda(:)'; # make lambda a row vector
  N = length(lambda);
  isvector(S) || \
      error( "S must be a vector" );
  S = S(:)'; # make S a row vector
  size_equal(lambda,S) || \
      error( "lambda and S must of be of the same length" );
  all(S>0) || \
      error( "S must be >0" );
  [N,N] == size(P) || \
      error(" P must be a matrix of size length(lambda) x length(lambda)" );  
  all(all(P>=0)) && all(sum(P,2)<=1) || \
      error( "P is not a transition probability matrix" );

  if ( nargin < 4 || isempty(m) )
    m = ones(1,N);
  else
    [errorcode, lambda, m] = common_size(lambda, m);
    ( isvector(m) && (errorcode==0) ) || \
        error("m and lambda must have the same length" );
  endif

  ## Compute the arrival rates using the traffic equation:
  l = sum(lambda)*qnosvisits( P, lambda );
  ## Check ergodicity
  for i=1:N
    if ( m(i)>0 && l(i)>=m(i)/S(i) )      
      error( "Server %d not ergodic: arrival rate=%f, service rate=%f", i, l(i), m(i)/S(i) );
    endif
  endfor

  U_or_pi = zeros(1,N);

  if ( nargin == 5 )

    ( isvector(k) && size_equal(lambda,k) ) || \
        error( "k must be a vector of the same size as lambda" );
    all(k>=0) || \
        error( "k must be nonnegative" );

    ## compute occupancy probability
    rho = l .* S ./ m;      
    i = find(m==1); # M/M/1 queues
    U_or_pi(i) = (1-rho(i)).*rho(i).^k(i);
    for i=find(m>1) # M/M/k queues
      k = [0:m(i)-1];
      pizero = 1 / (sum( (m(i)*rho(i)).^k ./ factorial(k)) + \
                    (m(i)*rho(i))^m(i) / (factorial(m(i))*(1-rho(i))) \
                    );      
      ## Compute the marginal probabilities
      U_or_pi(i) = pizero * (m(i)^min(k(i),m(i))) * (rho(i)^k(i)) / \
          factorial(min(m(i),k(i)));
    endfor
    i = find(m<1); # infinite server nodes
    U_or_pi(i) = exp(-rho(i)).*rho(i).^k(i)./factorial(k(i));

  else 

    ## Compute steady-state parameters
    U_or_pi = R = Q = X = zeros(1,N); # Initialize vectors
    ## single server nodes
    i = find( m==1 );
    [U_or_pi(i) R(i) Q(i) X(i)] = qnmm1(l(i),1./S(i));
    ## multi server nodes  
    i = find( m>1 );
    [U_or_pi(i) R(i) Q(i) X(i)] = qnmmm(l(i),1./S(i),m(i));
    ## infinite server nodes
    i = find( m<1 );
    [U_or_pi(i) R(i) Q(i) X(i)] = qnmminf(l(i),1./S(i));

  endif
endfunction
%!test
%! # Test various error conditions
%! fail( "qnjackson( [0.5 0.5], [0 1], [0 0; 0 0], [1 1])", "S must be" );
%! fail( "qnjackson( [-1 1], [1 1], [0 0; 0 0], [1 1])", "lambda must be" );
%! fail( "qnjackson( [0.5 0.5], [1 1], [1 1; 0 0], [1 1])", "P is not" );
%! fail( "qnjackson( [0.5 0.5], [1 1], [1 0; -1 0], [1 1])", "P is not" );
%! fail( "qnjackson( [0.5 0.5], [1 1 1], [0 0; 0 0], [1 1])", "lambda and S" );
%! fail( "qnjackson( [0.5 0.5], [1 1], [0 0; 0 0], [1 1 1])", "m and lambda" );
%! fail( "qnjackson( [0.5 0.5], [1 1], [0 0; 0 0], [1 1], [1 1 1])", "k must be" );
%! fail( "qnjackson( [0.5 0.5], [1 1], [0 0; 0 0], [1 1], [1 -1])", "k must be" );
%! fail( "qnjackson( [0 1], [2 2], [0 0.9; 0 0] )", "not ergodic" );

%!test
%! # Example 7.4 p. 287 Bolch et al.
%! S = [ 0.04 0.03 0.06 0.05 ];
%! P = [ 0 0.5 0.5 0; 1 0 0 0; 0.6 0 0 0; 1 0 0 0 ];
%! lambda = [0 0 0 4];
%! k = [ 3 2 4 1 ];
%! [U R Q X] = qnjackson( lambda, S, P, 1 );
%! assert( X, [20 10 10 4], 1e-4 );
%! assert( U, [0.8 0.3 0.6 0.2], 1e-2 );
%! assert( R, [0.2 0.043 0.15 0.0625], 1e-3 );
%! assert( Q, [4, 0.429 1.5 0.25], 1e-3 );

%!test
%! # Example 7.4 p. 287 Bolch et al.
%! S = [ 0.04 0.03 0.06 0.05 ];
%! P = [ 0 0.5 0.5 0; 1 0 0 0; 0.6 0 0 0; 1 0 0 0 ];
%! lambda = [0 0 0 4];
%! k = [ 3 2 4 1 ];
%! p_i = qnjackson( lambda, S, P, 1, k );
%! assert( p_i, [0.1024, 0.063, 0.0518, 0.16], 1e-4 );
