## Copyright (C) 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## Copyright (C) 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}, @var{pK}] =} qsmmmk (@var{lambda}, @var{mu}, @var{m}, @var{K})
##
## @cindex @math{M/M/m/K} system
##
## Compute utilization, response time, average number of requests and
## throughput for a @math{M/M/m/K} finite capacity system. In a
## @math{M/M/m/K} system there are @math{m \geq 1} identical service
## centers sharing a fixed-capacity queue. At any time, at most @math{K @geq{} m} requests can be in the system. The maximum queue length
## is @math{K-m}. This function generates and
## solves the underlying CTMC.
##
## @iftex
##
## The steady-state probability @math{\pi_k} that there are @math{k}
## jobs in the system, @math{0 @leq{} k @leq{} K} can be expressed as:
##
## @tex
## $$
## \pi_k = \cases{ \displaystyle{{\rho^k \over k!} \pi_0} & if $0 \leq k \leq m$;\cr
##                 \displaystyle{{\rho^m \over m!} \left( \rho \over m \right)^{k-m} \pi_0} & if $m < k \leq K$\cr}
## $$
## @end tex
##
## where @math{\rho = \lambda/\mu} is the offered load. The probability
## @math{\pi_0} that the system is empty can be computed by considering
## that all probabilities must sum to one: @math{\sum_{k=0}^K \pi_k = 1},
## which gives:
##
## @tex
## $$
## \pi_0 = \left[ \sum_{k=0}^m {\rho^k \over k!} + {\rho^m \over m!} \sum_{k=m+1}^K \left( {\rho \over m}\right)^{k-m} \right]^{-1}
## $$
## @end tex
##
## @end iftex
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## Arrival rate (@code{@var{lambda}>0}).
##
## @item mu
## Service rate (@code{@var{mu}>0}).
##
## @item m
## Number of servers (@code{@var{m} @geq{} 1}).
##
## @item K
## Maximum number of requests allowed in the system,
## including those inside the service centers
## (@code{@var{K} @geq{} @var{m}}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## Service center utilization
##
## @item R
## Service center response time
##
## @item Q
## Average number of requests in the system
##
## @item X
## Service center throughput
##
## @item p0
## Steady-state probability that there are no requests in the system.
##
## @item pK
## Steady-state probability that there are @var{K} requests in the system
## (i.e., probability that the system is full).
##
## @end table
##
## @var{lambda}, @var{mu}, @var{m} and @var{K} can be either scalars, or
## vectors of the  same size. In this case, the results will be vectors
## as well.
##
## @seealso{qsmm1,qsmminf,qsmmm}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X p0 pK] = qsmmmk( lambda, mu, m, K )
  if ( nargin != 4 )
    print_usage();
  endif

  ( isvector(lambda) && isvector(mu) && isvector(m) && isvector(K) ) || ...
      error( "lambda, mu, m, K must be vectors" );
  lambda = lambda(:)'; # make lambda a row vector
  mu = mu(:)'; # make mu a row vector
  m = m(:)'; # make m a row vector
  K = K(:)'; # make K a row vector

  [err lambda mu m K] = common_size( lambda, mu, m, K );
  if ( err ) 
    error( "Parameters are not of common size" );
  endif

  all( K>0 ) || \
      error( "k must be strictly positive" );
  all( m>0 ) && all( m <= K ) || \
      error( "m must be in the range 1:k" );
  all( lambda>0 ) && all( mu>0 ) || \
      error( "lambda and mu must be >0" );
  U = R = Q = X = p0 = pK = 0*lambda;
  for i=1:length(lambda)
    ## Build and solve the birth-death process describing the M/M/m/k system
    birth_rate = lambda(i)*ones(1,K(i));
    death_rate = [ linspace(1,m(i),m(i))*mu(i) ones(1,K(i)-m(i))*m(i)*mu(i) ];
    p = ctmc(ctmcbd(birth_rate, death_rate));
    p0(i) = p(1);
    pK(i) = p(1+K(i));
    j = [1:K(i)];
    Q(i) = dot( p(1+j),j );
  endfor
  ## Compute other performance measures
  X = lambda.*(1-pK);
  U = X ./ (m .* mu );
  R = Q ./ X;
endfunction
%!test
%! lambda = mu = m = 1;
%! k = 10;
%! [U R Q X p0] = qsmmmk(lambda,mu,m,k);
%! assert( Q, k/2, 1e-7 );
%! assert( U, 1-p0, 1e-7 );

%!test
%! lambda = [1 0.8 2 9.2 0.01];
%! mu = lambda + 0.17;
%! k = 12;
%! [U1 R1 Q1 X1] = qsmm1k(lambda,mu,k);
%! [U2 R2 Q2 X2] = qsmmmk(lambda,mu,1,k);
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );
%! assert( X1, X2, 1e-5 );
%! #assert( [U1 R1 Q1 X1], [U2 R2 Q2 X2], 1e-5 );

%!test
%! lambda = 0.9;
%! mu = 0.75;
%! k = 10;
%! [U1 R1 Q1 X1 p01] = qsmmmk(lambda,mu,1,k);
%! [U2 R2 Q2 X2 p02] = qsmm1k(lambda,mu,k);
%! assert( [U1 R1 Q1 X1 p01], [U2 R2 Q2 X2 p02], 1e-5 );

%!test
%! lambda = 0.8;
%! mu = 0.85;
%! m = 3;
%! k = 5;
%! [U1 R1 Q1 X1 p0] = qsmmmk( lambda, mu, m, k );
%! birth = lambda*ones(1,k);
%! death = [ mu*linspace(1,m,m) mu*m*ones(1,k-m) ];
%! q = ctmc(ctmcbd( birth, death ));
%! U2 = dot( q, min( 0:k, m )/m );
%! assert( U1, U2, 1e-4 );
%! Q2 = dot( [0:k], q );
%! assert( Q1, Q2, 1e-4 );
%! assert( p0, q(1), 1e-4 );

%!test
%! # This test comes from an example I found on the web 
%! lambda = 40;
%! mu = 30;
%! m = 3;
%! k = 7;
%! [U R Q X p0] = qsmmmk( lambda, mu, m, k );
%! assert( p0, 0.255037, 1e-6 );
%! assert( R, 0.036517, 1e-6 );

%!test
%! # This test comes from an example I found on the web 
%! lambda = 50;
%! mu = 10;
%! m = 4;
%! k = 6;
%! [U R Q X p0 pk] = qsmmmk( lambda, mu, m, k );
%! assert( pk, 0.293543, 1e-6 );

%!test
%! # This test comes from an example I found on the web 
%! lambda = 3;
%! mu = 2;
%! m = 2;
%! k = 5;
%! [U R Q X p0 pk] = qsmmmk( lambda, mu, m, k );
%! assert( p0, 0.179334, 1e-6 );
%! assert( pk, 0.085113, 1e-6 );
%! assert( Q, 2.00595, 1e-5 );
%! assert( R-1/mu, 0.230857, 1e-6 ); # waiting time in the queue

