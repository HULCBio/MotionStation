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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}, @var{pK}] =} qsmm1k (@var{lambda}, @var{mu}, @var{K})
##
## @cindex @math{M/M/1/K} system
##
## Compute utilization, response time, average number of requests and
## throughput for a @math{M/M/1/K} finite capacity system. In a
## @math{M/M/1/K} queue there is a single server; the maximum number of
## requests in the system is @math{K}, and the maximum queue length is
## @math{K-1}.
##
## @iftex
## The steady-state probability @math{\pi_k} that there are @math{k}
## jobs in the system, @math{0 @leq{} k @leq{} K}, can be computed as:
##
## @tex
## $$
## \pi_k = {(1-a)a^k \over 1-a^{K+1}}
## $$
## @end tex
## where @math{a = \lambda/\mu}.
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
## @item K
## Maximum number of requests allowed in the system (@code{@var{K} @geq{} 1}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## Service center utilization, which is defined as @code{@var{U} = 1-@var{p0}}
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
## Steady-state probability that there are no requests in the system
##
## @item pK
## Steady-state probability that there are @math{K} requests in the system
## (i.e., that the system is full)
##
## @end table
##
## @var{lambda}, @var{mu} and @var{K} can be vectors of the
## same size. In this case, the results will be vectors as well.
##
## @seealso{qsmm1,qsmminf,qsmmm}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X p0 pK] = qsmm1k( lambda, mu, K )
  if ( nargin != 3 )
    print_usage();
  endif

  ( isvector(lambda) && isvector(mu) && isvector(K) ) || \
      error( "lambda, mu, K must be vectors of the same size" );

  [err lambda mu K] = common_size( lambda, mu, K );
  if ( err ) 
    error( "Parameters are not of common size" );
  endif

  all( K>0 ) || \
      error( "K must be >0" );
  ( all( lambda>0 ) && all( mu>0 ) ) || \
      error( "lambda and mu must be >0" );

  U = R = Q = X = p0 = pK = 0*lambda;
  a = lambda./mu;
  ## persistent tol = 1e-7;
  ## if a!=1
  ## i = find( abs(a-1)>tol );
  i = find( a != 1 );
  p0(i) = (1-a(i))./(1-a(i).^(K(i)+1));
  pK(i) = (1-a(i)).*(a(i).^K(i))./(1-a(i).^(K(i)+1));
  Q(i) = a(i)./(1-a(i)) - (K(i)+1)./(1-a(i).^(K(i)+1)).*(a(i).^(K(i)+1));
  ## if a==1
  ## i = find( abs(a-1)<=tol );
  i = find( a == 1 );
  p0(i) = pK(i) = 1./(K(i)+1);
  Q(i) = K(i)/2;   
  ## Compute other performance measures
  U = 1-p0;
  X = lambda.*(1-pK);
  R = Q ./ X;
endfunction
%!test
%! lambda = mu = 1;
%! K = 10;
%! [U R Q X p0] = qsmm1k(lambda,mu,K);
%! assert( Q, K/2, 1e-7 );
%! assert( U, 1-p0, 1e-7 );

%!test
%! # Compare result with one obtained by solvind the CTMC
%! lambda = 0.8;
%! mu = 0.8;
%! K = 10;
%! [U1 R1 Q1 X1] = qsmm1k( lambda, mu, K );
%! birth = lambda*ones(1,K);
%! death = mu*ones(1,K);
%! q = ctmc(ctmc_bd( birth, death ));
%! U2 = 1-q(1);
%! Q2 = dot( [0:K], q );
%! assert( U1, U2, 1e-4 );
%! assert( Q1, Q2, 1e-4 );

