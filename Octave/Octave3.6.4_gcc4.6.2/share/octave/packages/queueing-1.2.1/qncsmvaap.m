## Copyright (C) 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncsmvaap (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncsmvaap (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncsmvaap (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncsmvaap (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z}, @var{tol})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncsmvaap (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z}, @var{tol}, @var{iter_max})
##
## @cindex Mean Value Analysys (MVA), approximate
## @cindex MVA, approximate
## @cindex approximate MVA
## @cindex closed network, single class
## @cindex closed network, approximate analysis
##
## Analyze closed, single class queueing networks using the Approximate
## Mean Value Analysis (MVA) algorithm. This function is based on
## approximating the number of customers seen at center @math{k} when a
## new request arrives as @math{Q_k(N) \times (N-1)/N}. This function
## only handles single-server and delay centers; if your network
## contains general load-dependent service centers, use the function
## @code{qncsmvald} instead.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## Population size (number of requests in the system, @code{@var{N} > 0}).
##
## @item S
## @code{@var{S}(k)} is the mean service time on server @math{k}
## (@code{@var{S}(k)>0}).
##
## @item V
## @code{@var{V}(k)} is the average number of visits to service center
## @math{k} (@code{@var{V}(k) @geq{} 0}).
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}
## (if @var{m} is a scalar, all centers have that number of servers). If
## @code{@var{m}(k) < 1}, center @math{k} is a delay center (IS); if
## @code{@var{m}(k) == 1}, center @math{k} is a regular queueing
## center (FCFS, LCFS-PR or PS) with one server (default). This function
## does not support multiple server nodes (@code{@var{m}(k) > 1}).
##
## @item Z
## External delay for customers (@code{@var{Z} @geq{} 0}). Default is 0.
##
## @item tol
## Stopping tolerance. The algorithm stops when the maximum relative difference
## between the new and old value of the queue lengths @var{Q} becomes
## less than the tolerance. Default is @math{10^{-5}}.
##
## @item iter_max
## Maximum number of iterations (@code{@var{iter_max}>0}.
## The function aborts if convergenge is not reached within the maximum
## number of iterations. Default is 100.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## If @math{k} is a FCFS, LCFS-PR or PS node (@code{@var{m}(k) == 1}),
## then @code{@var{U}(k)} is the utilization of center @math{k}. If
## @math{k} is an IS node (@code{@var{m}(k) < 1}), then
## @code{@var{U}(k)} is the @emph{traffic intensity} defined as
## @code{@var{X}(k)*@var{S}(k)}.
##
## @item R
## @code{@var{R}(k)} is the response time at center @math{k}.
## The system response time @var{Rsys}
## can be computed as @code{@var{Rsys} = @var{N}/@var{Xsys} - Z}
##
## @item Q
## @code{@var{Q}(k)} is the average number of requests at center
## @math{k}. The number of requests in the system can be computed
## either as @code{sum(@var{Q})}, or using the formula
## @code{@var{N}-@var{Xsys}*@var{Z}}.
##
## @item X
## @code{@var{X}(k)} is the throughput of center @math{k}. The
## system throughput @var{Xsys} can be computed as
## @code{@var{Xsys} = @var{X}(1) / @var{V}(1)}
##
## @end table
##
## @seealso{qncsmva,qncsmvald}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qncsmvaap( N, S, V, m, Z, tol, iter_max )

  if ( nargin < 3 || nargin > 7 ) 
    print_usage();
  endif

  isscalar(N) && N >= 0 || \
      error( "N must be >= 0" );
  isvector(S) || \
      error( "S must be a vector" );
  isvector(V) || \
      error( "V must be a vector" );
  S = S(:)'; # make S a row vector
  V = V(:)'; # make V a row vector

  K = length(S); # Number of servers

  if ( nargin < 4 ) 
    m = ones(1,K);
  else
    isvector(m) || \
	error( "m must be a vector" );
    m = m(:)'; # make m a row vector
  endif

  [err S V m] = common_size(S, V, m);
  (err == 0) || \
      error( "S, V and m are of incompatible size" );
  all(S>=0) || \
      error( "S must be a vector >= 0" );
  all(V>=0) || \
      error( "V must be a vector >= 0" );
  all(m<=1) || \
      error( "Vector m must be <= 1 (this function supports IS and single-server nodes only)" );

  if ( nargin < 5 )
    Z = 0;
  else
    (isscalar(Z) && Z >= 0) || \
        error( "Z must be >= 0" );
  endif

  if ( nargin < 6 )
    tol = 1e-5;
  else
    ( isscalar(tol) && tol>0 ) || \
	error("tol must be a positive scalar");
  endif

  if ( nargin < 7 )
    iter_max = 100;
  else
    ( isscalar(iter_max) && iter_max > 0 ) || \
	error("iter_max must be a positive integer");
  endif

  U = R = Q = X = zeros( 1, K );
  ## Trivial case of empty population: just return all zeros
  if ( N == 0 )
    return;
  endif

  Q = N/K * ones(1,K); # initialize queue lengths
  iter = 0;
  do
    iter++;
    Qold = Q;
    A = (N-1)/N * Q;
    R = S.*(1+A.*(m==1));
    Rs = dot(V,R);
    Xs = N/(Z+Rs);
    Q = Xs*(V.*R);
    err = norm((Q-Qold)./Qold, "inf");
  until (err < tol || iter>iter_max);
  if ( iter > iter_max ) 
    warning( "qncsmvaap(): Convergence not reached after %d iterations", iter_max );
  endif
  X = Xs * V;
  U = X .* S;  
endfunction
%!test
%! fail( "qncsmvaap()", "Invalid" );
%! fail( "qncsmvaap( 10, [1 2], [1 2 3] )", "S, V and m" );
%! fail( "qncsmvaap( 10, [-1 1], [1 1] )", ">= 0" );
%! fail( "qncsmvaap( 10, [1 2], [1 2], [1 2] )", "supports");
%! fail( "qncsmvaap( 10, [1 2], [1 2], [1 1], 0, -1)", "tol");

%!test
%! # Example p. 117 Lazowska et al.
%! S = [0.605 2.1 1.35];
%! V = [1 1 1];
%! N = 3;
%! Z = 15;
%! m = 1;
%! [U R Q X] = qncsmvaap(N, S, V, m, Z);
%! Rs = dot(V,R);
%! Xs = N/(Z+Rs);
%! assert( Q, [0.0973 0.4021 0.2359], 1e-3 );
%! assert( Xs, 0.1510, 1e-3 );
%! assert( Rs, 4.87, 1e-3 );

%!demo
%! S = [ 0.125 0.3 0.2 ];
%! V = [ 16 10 5 ];
%! N = 30;
%! m = ones(1,3);
%! Z = 4;
%! Xmva = Xapp = Rmva = Rapp = zeros(1,N);
%! for n=1:N
%!   [U R Q X] = qncsmva(n,S,V,m,Z);
%!   Xmva(n) = X(1)/V(1);
%!   Rmva(n) = dot(R,V);
%!   [U R Q X] = qncsmvaap(n,S,V,m,Z);
%!   Xapp(n) = X(1)/V(1);
%!   Rapp(n) = dot(R,V);
%! endfor
%! subplot(2,1,1);
%! plot(1:N, Xmva, ";Exact;", "linewidth", 2, 1:N, Xapp, "x;Approximate;", "markersize", 7);
%! legend("location","southeast");
%! ylabel("Throughput X(n)");
%! subplot(2,1,2);
%! plot(1:N, Rmva, ";Exact;", "linewidth", 2, 1:N, Rapp, "x;Approximate;", "markersize", 7);
%! legend("location","southeast");
%! ylabel("Response Time R(n)");
%! xlabel("Number of Requests n");
