## Copyright (C) 2009, 2010, 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncsmvald (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncsmvald (@var{N}, @var{S}, @var{V}, @var{Z})
##
## @cindex Mean Value Analysys (MVA)
## @cindex MVA
## @cindex closed network, single class
## @cindex load-dependent service center
##
## Exact MVA algorithm for closed, single class queueing networks
## with load-dependent service centers. This function supports
## FCFS, LCFS-PR, PS and IS nodes. For networks with only fixed-rate
## service centers and multiple-server nodes, the function
## @code{qncsmva} is more efficient.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## Population size (number of requests in the system, @code{@var{N} @geq{} 0}).
## If @code{@var{N} == 0}, this function returns @code{@var{U} = @var{R} = @var{Q} = @var{X} = 0}
##
## @item S
## @code{@var{S}(k,n)} is the mean service time at center @math{k}
## where there are @math{n} requests, @math{1 @leq{} n
## @leq{} N}. @code{@var{S}(k,n)} @math{= 1 / \mu_{k,n}},
## where @math{\mu_{k,n}} is the service rate of center @math{k}
## when there are @math{n} requests.
##
## @item V
## @code{@var{V}(k)} is the average number
## of visits to service center @math{k} (@code{@var{V}(k) @geq{} 0}).
##
## @item Z
## external delay ("think time", @code{@var{Z} @geq{} 0}); default 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## @code{@var{U}(k)} is the utilization of service center @math{k}. The
## utilization is defined as the probability that service center
## @math{k} is not empty, that is, @math{U_k = 1-\pi_k(0)} where
## @math{\pi_k(0)} is the steady-state probability that there are 0
## jobs at service center @math{k}.
##
## @item R
## @code{@var{R}(k)} is the response time on service center @math{k}.
##
## @item Q
## @code{@var{Q}(k)} is the average number of requests in service center
## @math{k}.
##
## @item X
## @code{@var{X}(k)} is the throughput of service center @math{k}.
##
## @end table
##
## @quotation Note
## In presence of load-dependent servers,
## the MVA algorithm is known to be numerically
## unstable. Generally this problem manifests itself as negative
## response times produced by this function.
## @end quotation
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qncsmvald( N, S, V, Z )

  if ( nargin < 3 || nargin > 4 ) 
    print_usage();
  endif

  isvector(V) && all(V>=0) || \
      error( "V must be a vector >= 0" );
  V = V(:)'; # make V a row vector
  K = length(V); # Number of servers
  isscalar(N) && N >= 0 || \
      error( "N must be >= 0" );
  ( ismatrix(S) && rows(S) == K && columns(S) >= N ) || \
      error( "S size mismatch: is %dx%d, should be %dx%d", rows(S), columns(S), K, N );
  all(S(:)>=0) || \
      error( "S must be >= 0" );

  if ( nargin < 4 ) 
    Z = 0;
  else
    isscalar(Z) && Z>=0 || \
        error( "Z must be >= 0" );
  endif

  ## Initialize results
  p = zeros( K, N+1 ); # p(k,i+1) is the probability that there are i jobs at server k, given that the network population is j
  p(:,1) = 1;
  U = R = Q = X = zeros( 1, K );
  X_s = 0;              # System throughput

  ## Main MVA loop, iterates over the population size
  for n=1:N # over population size

    j=1:n;
    ## for i=1:K
    ##   R(i) = sum( j.*S(i,j).*p(i,j) );
    ## endfor
    R = sum( repmat(j,K,1).*S(:,1:n).*p(:,1:n), 2)';

    R_s = dot( V, R ); # System response time
    X_s = n / (Z+R_s); # System Throughput
    ## G_N = G_Nm1 / X_s; G_Nm1 = G_N;

    ## prepare for next iteration
    for i=1:K
      p(i, 1+j) = X_s * S(i,j) .* p(i,j) * V(i);      
      p(i, 1) = 1-sum(p(i,1+j));
    endfor    
  endfor
  Q = X_s * ( V .* R );
  U = 1-p(:,1)'; # Service centers utilization
  X = X_s * V; # Service centers throughput
endfunction

## Check degenerate case of N==0 (general LD case)
%!test
%! N = 0;
%! S = [1 2; 3 4; 5 6; 7 8];
%! V = [1 1 1 4];
%! [U R Q X] = qncsmvald(N, S, V);
%! assert( U, 0*V );
%! assert( R, 0*V );
%! assert( Q, 0*V );
%! assert( X, 0*V );

%!test
%! # Exsample 3.42 p. 577 Jain
%! V = [ 16 10 5 ];
%! N = 20;
%! S = [ 0.125 0.3 0.2 ];
%! Sld = repmat( S', 1, N );
%! Z = 4;
%! [U1 R1 Q1 X1] = qncsmvald(N,Sld,V,Z);
%! [U2 R2 Q2 X2] = qncsmva(N,S,V,ones(1,3),Z);
%! assert( U1, U2, 1e-3 );
%! assert( R1, R2, 1e-3 );
%! assert( Q1, Q2, 1e-3 );
%! assert( X1, X2, 1e-3 );

%!test
%! # Example 8.7 p. 349 Bolch et al.
%! N = 3;
%! Sld = 1 ./ [ 2 4 4; \
%!              1.667 1.667 1.667; \
%!              1.25 1.25 1.25; \
%!              1 2 3 ];
%! V = [ 1 .5 .5 1 ];
%! [U R Q X] = qncsmvald(N,Sld,V);
%! assert( Q, [0.624 0.473 0.686 1.217], 1e-3 );
%! assert( R, [0.512 0.776 1.127 1], 1e-3 );
%! assert( all( U<=1) );

%!test
%! # Example 8.4 p. 333 Bolch et al.
%! N = 3;
%! S = [ .5 .6 .8 1 ];
%! m = [2 1 1 N];
%! Sld = zeros(3,N);
%! Sld(1,:) = .5 ./ [1 2 2];
%! Sld(2,:) = [.6 .6 .6];
%! Sld(3,:) = [.8 .8 .8];
%! Sld(4,:) = 1 ./ [1 2 3];
%! V = [ 1 .5 .5 1 ];
%! [U1 R1 Q1 X1] = qncsmvald(N,Sld,V);
%! [U2 R2 Q2 X2] = qncsmva(N,S,V,m);
%! ## Note that qncsmvald computes the utilization in a different
%! ## way as qncsmva; in fact, qncsmva knows that service
%! ## center i has m(i)>1 servers, but qncsmvald does not. Thus,
%! ## utilizations for multiple-server nodes cannot be compared
%! assert( U1([2,3]), U2([2,3]), 1e-3 );
%! assert( R1, R2, 1e-3 );
%! assert( Q1, Q2, 1e-3 );
%! assert( X1, X2, 1e-3 );

