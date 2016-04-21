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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}, @var{Ql}, @var{Qu}] =} qncsgb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}, @var{Ql}, @var{Qu}] =} qncsgb (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}, @var{Ql}, @var{Qu}] =} qncsgb (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}, @var{Ql}, @var{Qu}] =} qncsgb (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex bounds, geometric
## @cindex geometric bounds
## @cindex closed network
##
## Compute Geometric Bounds (GB) on system throughput, system response time and server queue lenghts for closed, single-class networks.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## number of requests in the system (scalar, @code{@var{N} > 0}).
##
## @item D
## @code{@var{D}(k)} is the service demand of service center @math{k}
## (@code{@var{D}(k) @geq{} 0}).
##
## @item S
## @code{@var{S}(k)} is the mean service time at center @math{k}
## (@code{@var{S}(k) @geq{} 0}).
##
## @item V
## @code{@var{V}(k)} is the visit ratio to center @math{k}
## (@code{@var{V}(k) @geq{} 0}).
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}.
## This function only supports @math{M/M/1} queues, therefore
## @var{m} must be @code{ones(size(S))}. 
##
## @item Z
## external delay (think time, @code{@var{Z} @geq{} 0}). Default 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @itemx Xu
## Lower and upper bound on the system throughput. If @code{@var{Z}>0},
## these bounds are computed using @emph{Geometric Square-root Bounds}
## (GSB). If @code{@var{Z}==0}, these bounds are computed using @emph{Geometric Bounds} (GB)
##
## @item Rl
## @itemx Ru
## Lower and upper bound on the system response time. These bounds
## are derived from @var{Xl} and @var{Xu} using Little's Law:
## @code{@var{Rl} = @var{N} / @var{Xu} - @var{Z}}, 
## @code{@var{Ru} = @var{N} / @var{Xl} - @var{Z}}
##
## @item Ql
## @itemx Qu
## @code{@var{Ql}(i)} and @code{@var{Qu}(i)} are the lower and upper
## bounds respectively of the queue length for service center @math{i}.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_lower X_upper R_upper R_lower Q_lower Q_upper] = qncsgb( varargin ) 

  ## This implementation is based on the paper: G.Casale, R.R.Muntz,
  ## G.Serazzi. Geometric Bounds: a Noniterative Analysis Technique for
  ## Closed Queueing Networks IEEE Transactions on Computers,
  ## 57(6):780-794, Jun 2008.
  ## http://doi.ieeecomputersociety.org/10.1109/TC.2008.37

  ## The original paper uses the symbol "L" instead of "D" to denote the
  ## loadings of service centers. In this function we adopt the same
  ## notation as the paper.
  if ( nargin < 2 || ( nargin > 5 && nargin != 7 ) )
    print_usage();
  endif

  [err N S V m Z] = qncschkparam( varargin{:} );
  isempty(err) || error(err);

  ## This function requires N>0
  N > 0 || \
      error( "N must be >0" );

  all(m==1) || \
      error("this function only supports single server nodes");

  L = S .* V;

  L_tot = sum(L);
  L_max = max(L);
  M = length(L);
  if ( nargin < 6 ) 
    [X_minus X_plus] = qncsaba(N,L,ones(size(L)),m,Z);
  else
    X_minus = varargin{6};
    X_plus = varargin{7};
  endif
  ##[X_minus X_plus] = [0 1/L_max];
  [Q_lower Q_upper] = __compute_Q( N, L, Z, X_plus, X_minus);
  [Q_lower_Nm1 Q_upper_Nm1] = __compute_Q( N-1, L, Z, X_plus, X_minus);
  if ( Z > 0 )
    ## Use Geometric Square-root Bounds (GSB)
    i = find(L<L_max);
    bN = Z+L_tot+L_max*(N-1)-sum( (L_max-L(i)).*Q_lower_Nm1(i) );
    X_lower = 2*N/(bN+sqrt(bN^2-4*Z*L_max*(N-1)));
    bN = Z+L_tot+L_max*(N-1)-sum( (L_max-L(i)).*Q_upper_Nm1(i) );
    X_upper = 2*N/(bN+sqrt(bN^2-4*Z*L_max*N));
  else
    ## Use Geometric Bounds (GB). FIXME: given that this branch is
    ## executed when Z=0, the expressions below can be simplified.
    X_lower = N/(Z+L_tot+L_max*(N-1-Z*X_minus) - ...
                 sum( (L_max - L) .* Q_lower_Nm1 ) );
    X_upper = N/(Z+L_tot+L_max*(N-1-Z*X_plus) - ...
                 sum( (L_max - L) .* Q_upper_Nm1 ) );
  endif
  R_lower = N / X_upper - Z;
  R_upper = N / X_lower - Z;
endfunction

## [ Q_lower Q_uppwer ] = __compute_Q( N, D, Z, X_plus, X_minus )
##
## compute Q_lower(i) and Q_upper(i), the lower and upper bounds
## respectively for queue length at service center i, for a closed
## network with N customers, service demands D and think time Z. This
## function uses Eq. (8) and (13) from the reference paper.
function [ Q_lower Q_upper ] = __compute_Q( N, L, Z, X_plus, X_minus )
  isscalar(X_plus) || error( "X_plus must be a scalar" );
  isscalar(X_minus) || error( "X_minus must be a scalar" );
  ( isscalar(N) && (N>=0) ) || error( "N is not valid" );
  L_tot = sum(L);
  L_max = max(L);
  M = length(L);
  m_max = sum( L == L_max );
  y = Y = zeros(1,M);
  ## first, handle the case of servers with loading less than the
  ## maximum that is, L(i) < L_max
  i=find(L<L_max);
  y(i) = L(i)*N./(Z+L_tot+L_max*N);
  Q_lower(i) = y(i)./(1-y(i)) .- (y(i).^(N+1))./(1-y(i)); # Eq. (8)
  Y(i) = L(i)*X_plus;
  Q_upper(i) = Y(i)./(1-Y(i)) .- (Y(i).^(N+1))./(1-Y(i)); # Eq. (13)
  ## now, handle the case of servers with demand equal to the maximum
  i=find(L==L_max);
  Q_lower(i) = 1/m_max*(N-Z*X_plus - sum( Q_upper( L<L_max ))); # Eq. (8)
  Q_upper(i) = 1/m_max*(N-Z*X_minus - sum( Q_lower( L<L_max ))); # Eq. (13)
endfunction

%!test
%! fail( "qncsgb( 1, [] )", "vector" );
%! fail( "qncsgb( 1, [0 -1])", "nonnegative" );
%! fail( "qncsgb( 0, [1 2] )", ">0" );
%! fail( "qncsgb( -1, [1 2])", "nonnegative" );
%! fail( "qncsgb( 1, [1 2],1,[1 -1])", "single server" );

%!# shared test function
%!function test_gb( D, expected, Z=0 )
%! for i=1:rows(expected)
%!   N = expected(i,1);
%!   [X_lower X_upper Q_lower Q_upper] = qncsgb(N,D,1,1,Z);
%!   X_exp_lower = expected(i,2);
%!   X_exp_upper = expected(i,3);
%!   assert( [N X_lower X_upper], [N X_exp_lower X_exp_upper], 1e-4 )
%! endfor

%!xtest
%! # table IV
%! D = [ 0.1 0.1 0.09 0.08 ];
%! #            N  X_lower  X_upper
%! expected = [ 2  4.3040   4.3174; ...
%!              5  6.6859   6.7524; ...
%!              10 8.1521   8.2690; ...
%!              20 9.0947   9.2431; ...
%!              80 9.8233   9.8765 ];
%! test_gb(D, expected);

%!xtest
%! # table V
%! D = [ 0.1 0.1 0.09 0.08 ];
%! Z = 1;
%! #            N  X_lower  X_upper
%! expected = [ 2  1.4319   1.5195; ...
%!              5  3.3432   3.5582; ...
%!              10 5.7569   6.1410; ...
%!              20 8.0856   8.6467; ...
%!              80 9.7147   9.8594];
%! test_gb(D, expected, Z);

%!test
%! P = [0 0.3 0.7; 1 0 0; 1 0 0];
%! S = [1 0.6 0.2];
%! m = ones(1,3);
%! V = qncsvisits(P);
%! Z = 2;
%! Nmax = 20;
%! tol = 1e-5; # compensate for numerical errors
%! ## Test case with Z>0
%! for n=1:Nmax
%!   [X_gb_lower X_gb_upper NC NC Q_gb_lower Q_gb_upper] = qncsgb(n, S.*V, 1, 1, Z);
%!   [U R Q X] = qnclosed( n, S, V, m, Z );
%!   X_mva = X(1)/V(1);
%!   assert( X_gb_lower <= X_mva+tol );
%!   assert( X_gb_upper >= X_mva-tol );
%!   assert( Q_gb_lower <= Q+tol ); # compensate for numerical errors
%!   assert( Q_gb_upper >= Q-tol ); # compensate for numerical errors
%! endfor

%!test
%! P = [0 0.3 0.7; 1 0 0; 1 0 0];
%! S = [1 0.6 0.2];
%! V = qncsvisits(P);
%! Nmax = 20;
%! tol = 1e-5; # compensate for numerical errors
%!
%! ## Test case with Z=0
%! for n=1:Nmax
%!   [X_gb_lower X_gb_upper NC NC Q_gb_lower Q_gb_upper] = qncsgb(n, S.*V);
%!   [U R Q X] = qnclosed( n, S, V );
%!   X_mva = X(1)/V(1);
%!   assert( X_gb_lower <= X_mva+tol );
%!   assert( X_gb_upper >= X_mva-tol );
%!   assert( Q_gb_lower <= Q+tol );
%!   assert( Q_gb_upper >= Q-tol );
%! endfor
