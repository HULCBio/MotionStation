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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{G}] =} qncsconvld (@var{N}, @var{S}, @var{V})
##
## @cindex closed network
## @cindex normalization constant
## @cindex convolution algorithm
## @cindex load-dependent service center
##
## This function implements the @emph{convolution algorithm} for
## product-form, single-class closed queueing networks with general
## load-dependent service centers.
##
## This function computes steady-state performance measures for
## single-class, closed networks with load-dependent service centers
## using the convolution algorithm; the normalization constants are also
## computed. The normalization constants are returned as vector
## @code{@var{G}=[@var{G}(1), @dots{}, @var{G}(N+1)]} where
## @code{@var{G}(i+1)} is the value of @math{G(i)}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## Number of requests in the system (@code{@var{N}>0}).
##
## @item S
## @code{@var{S}(k,n)} is the mean service time at center @math{k}
## where there are @math{n} requests, @math{1 @leq{} n
## @leq{} N}. @code{@var{S}(k,n)} @math{= 1 / \mu_{k,n}},
## where @math{\mu_{k,n}} is the service rate of center @math{k}
## when there are @math{n} requests.
##
## @item V
## @code{@var{V}(k)} is the visit count of service center @math{k}
## (@code{@var{V}(k) @geq{} 0}). The length of @var{V} is the number of
## servers @math{K} in the network.
##
## @end table
##
## @strong{OUTPUT}
##
## @table @var
##
## @item U
## @code{@var{U}(k)} is the utilization of center @math{k}.
##
## @item R
## @code{@var{R}(k)} is the average response time at center @math{k}.
##
## @item Q
## @code{@var{Q}(k)} is the average number of customers in center @math{k}.
##
## @item X
## @code{@var{X}(k)} is the throughput of center @math{k}.
##
## @item G
## Normalization constants (vector). @code{@var{G}(n+1)}
## corresponds to @math{G(n)}, as array indexes in Octave start
## from 1.
##
## @end table
##
## @seealso{qncsconv}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X G] = qncsconvld( N, S, V )

  if ( nargin != 3 )
    print_usage();
  endif

  ( isscalar(N) && N>0 ) || \
      error( "N must be a positive scalar" );
  K = N; # To be compliant with the reference, we denote K as the population size
  ( isvector(V) && all(V>=0) ) || \
      error( "V must be a vector >=0" );
  V = V(:)'; # Make V a row vector
  N = length(V); # Number of service centers
  if ( isnumeric(S) ) 
    ( rows(S) == N && columns(S) == K) || \
        error( sprintf("S size mismatch: is %dx%d, should be %dx%d", rows(S), columns(S),K,N ) );
    all(S(:)>=0) || \
        error( "S must be >=0" );
  endif

  ## Initialization
  G_n = G_nm1 = zeros(1,K+1); G_n(1) = 1;
  F_n = zeros(N,K+1); F_n(:,1) = 1;
  for k=1:K
    G_n(k+1) = F_n(1,k+1) = F(1,k,V,S);
  endfor
  ## Main convolution loop
  for n=2:N
    G_nm1 = G_n;
    for k=2:K+1
      F_n(n,k) = F(n,k-1,V,S);
    endfor
    G_n = conv( F_n(n,:), G_nm1(:) )(1:K+1);
  endfor
  ## Done computation of G(n,k).
  G = G_n;
  G = G(:)'; # ensure G is a row vector
  ## Computes performance measures
  X = V*G(K)/G(K+1);
  Q = U = zeros(1,N);
  for i=1:N
    G_N_i = zeros(1,K+1);
    G_N_i(1) = 1;
    for k=1:K
      j=1:k;
      G_N_i(k+1) = G(k+1)-dot( F_n(i,j+1), G_N_i(k-j+1) );
    endfor
    k=0:K;
    p_i(k+1) = F_n(i,k+1)./G(K+1).*G_N_i(K-k+1);
    Q(i) = dot( k, p_i( k+1 ) );
    U(i) = 1-p_i(1);
  endfor
  R = Q ./ X;
endfunction
%!test
%! K=3;
%! S = [ 1 1 1; 1 1 1 ];
%! V = [ 1 .667 .2 ];
%! fail( "qncsconvld(K,S,V)", "size mismatch" );

%!test
%! # Example 8.1 p. 318 Bolch et al.
%! K=3;
%! S = [ 1/0.8 ./ [1 2 2];
%!       1/0.6 ./ [1 2 3];
%!       1/0.4 ./ [1 1 1] ];
%! V = [ 1 .667 .2 ];
%! [U R Q X G] = qncsconvld( K, S, V );
%! assert( G, [1 2.861 4.218 4.465], 5e-3 );
%! assert( X, [0.945 0.630 0.189], 1e-3 );
%! assert( Q, [1.290 1.050 0.660], 1e-3 );
%! assert( R, [1.366 1.667 3.496], 1e-3 );

%!test
%! # Example 8.3 p. 331 Bolch et al.
%! # compare results of convolution with those of mva
%! K = 6;
%! S = [ 0.02 0.2 0.4 0.6 ];
%! V = [ 1 0.4 0.2 0.1 ];
%! [U_mva R_mva Q_mva X_mva] = qncsmva(K, S, V);
%! [U_con R_con Q_con X_con G] = qncsconvld(K, repmat(S',1,K), V );
%! assert( U_mva, U_con, 1e-5 );
%! assert( R_mva, R_con, 1e-5 );
%! assert( Q_mva, Q_con, 1e-5 );
%! assert( X_mva, X_con, 1e-5 );

%!test
%! # Compare the results of convolution to those of mva
%! S = [ 0.02 0.2 0.4 0.6 ];
%! K = 6;
%! V = [ 1 0.4 0.2 0.1 ];
%! m = [ 1 5 2 1 ];
%! [U_mva R_mva Q_mva X_mva] = qncsmva(K, S, V);
%! [U_con R_con Q_con X_con G] = qncsconvld(K, repmat(S',1,K), V);
%! assert( U_mva, U_con, 1e-5 );
%! assert( R_mva, R_con, 1e-5 );
%! assert( Q_mva, Q_con, 1e-5 );
%! assert( X_mva, X_con, 1e-5 );

%!function r = S_function(k,n)
%! M = [ 1/0.8 ./ [1 2 2];
%!       1/0.6 ./ [1 2 3];
%!       1/0.4 ./ [1 1 1] ];
%! r = M(k,n);

%!test
%! # Example 8.1 p. 318 Bolch et al.
%! K=3;
%! V = [ 1 .667 .2 ];
%! [U R Q X G] = qncsconvld( K, @S_function, V );
%! assert( G, [1 2.861 4.218 4.465], 5e-3 );
%! assert( X, [0.945 0.630 0.189], 1e-3 );
%! assert( Q, [1.290 1.050 0.660], 1e-3 );
%! assert( R, [1.366 1.667 3.496], 1e-3 );

## result = F(i,j,v,S)
##
## Helper fuction to compute a generalization of equation F(i,j) as
## defined in Eq 7.61 p. 289 of Bolch, Greiner, de Meer, Trivedi
## "Queueing Networks and Markov Chains: Modeling and Performance
## Evaluation with Computer Science Applications", Wiley, 1998. This
## generalization is taken from Schwetman, "Some Computational Aspects
## of Queueing Network Models", Technical Report CSD-TR 354, Dept. of
## CS, Purdue University, Dec 1980 (see definition of f_i(n) on p. 7).
function result = F(i,j,v,S)
  k_i = j;
  if ( k_i == 0 )
    result = 1;
  else
    result = v(i)^k_i * prod(S(i,1:k_i));
  endif
endfunction
