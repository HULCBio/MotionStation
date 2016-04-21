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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmmvaap (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmmvaap (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmmvaap (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmmvaap (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z}, @var{tol})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmmvaap (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z}, @var{tol}, @var{iter_max})
##
## @cindex Mean Value Analysys (MVA), approximate
## @cindex MVA, approximate
## @cindex closed network, multiple classes
## @cindex multiclass network, closed
##
## Analyze closed, multiclass queueing networks with @math{K} service
## centers and @math{C} customer classes using the approximate Mean
## Value Analysys (MVA) algorithm.
##
## This implementation uses Bard and Schweitzer approximation. It is based
## on the assumption that
## @iftex
## @tex
## $$Q_i({\bf N}-{\bf 1}_c) \approx {n-1 \over n} Q_i({\bf N})$$
## @end tex
## @end iftex
## @ifnottex
## the queue length at service center @math{k} with population
## set @math{{\bf N}-{\bf 1}_c} is approximately equal to the queue length 
## with population set @math{\bf N}, times @math{(n-1)/n}:
##
## @example
## @group
## Q_i(N-1c) ~ (n-1)/n Q_i(N)
## @end group
## @end example
## @end ifnottex
##
## where @math{\bf N} is a valid population mix, @math{{\bf N}-{\bf 1}_c}
## is the population mix @math{\bf N} with one class @math{c} customer
## removed, and @math{n = \sum_c N_c} is the total number of requests.
##
## This implementation works for networks made of infinite server (IS)
## nodes and single-server nodes only.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## @code{@var{N}(c)} is the number of
## class @math{c} requests in the system (@code{@var{N}(c)>0}).
##
## @item S
## @code{@var{S}(c,k)} is the mean service time for class @math{c}
## customers at center @math{k} (@code{@var{S}(c,k) @geq{} 0}).
##
## @item V
## @code{@var{V}(c,k)} is the average number of visits of class @math{c}
## requests to center @math{k} (@code{@var{V}(c,k) @geq{} 0}).
##
## @item m
## @code{@var{m}(k)} is the number of servers at service center
## @math{k}. If @code{@var{m}(k) < 1}, then the service center @math{k}
## is assumed to be a delay center (IS). If @code{@var{m}(k) == 1},
## service center @math{k} is a regular queueing center (FCFS, LCFS-PR
## or PS) with a single server node. If omitted, each service center has
## a single server. Note that multiple server nodes are not supported.
## 
## @item Z
## @code{@var{Z}(c)} is the class @math{c} external delay. Default
## is 0.
##
## @item tol
## Stopping tolerance (@code{@var{tol}>0}). The algorithm stops if
## the queue length computed on two subsequent iterations are less than
## @var{tol}. Default is @math{10^{-5}}.
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
## If @math{k} is a FCFS, LCFS-PR or PS node, then @code{@var{U}(c,k)}
## is the utilization of class @math{c} requests on service center
## @math{k}. If @math{k} is an IS node, then @code{@var{U}(c,k)} is the
## class @math{c} @emph{traffic intensity} at device @math{k},
## defined as @code{@var{U}(c,k) = @var{X}(c)*@var{S}(c,k)}
##
## @item R
## @code{@var{R}(c,k)} is the response
## time of class @math{c} requests at service center @math{k}.
##
## @item Q
## @code{@var{Q}(c,k)} is the average number of
## class @math{c} requests at service center @math{k}.
##
## @item X
## @code{@var{X}(c,k)} is the class @math{c}
## throughput at service center @math{k}.
##
## @end table
##
## @seealso{qncmmva}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qncmmvaap( N, S, V, m, Z, tol, iter_max )

  if ( nargin < 3 || nargin > 7 )
    print_usage();
  endif

  isvector(N) && all( N>=0 ) || \
      error( "N must be a vector of positive integers" );
  N = N(:)'; # make N a row vector
  C = length(N); ## Number of classes
  K = columns(S); ## Number of service centers
  size(S) == [C,K] || \
      error( "S size mismatch" );
  size(V) == [C,K] || \
      error( "V size mismatch" );

  if ( nargin < 4 || isempty(m) )
    m = ones(1,K);
  else
    isvector(m) || \
	error( "m must be a vector");
    m = m(:)'; # make m a row vector
    ( length(m) == K && all( m <= 1 ) ) || \
        error( "m must be <= 1 and have %d elements", K );
  endif

  if ( nargin < 5 || isempty(Z) )
    Z = zeros(1,C);
  else
    isvector(Z) || \
	error( "Z must be a vector" );
    Z = Z(:)'; # make Z a row vector
    ( length(Z) == C && all(Z >= 0 ) ) || \
	error( "Z must be >= 0 and have %d elements", C );
  endif

  if ( nargin < 6 || isempty(tol) )
    tol = 1e-5;
  endif

  if ( nargin < 7 || isempty(iter_max) )
    iter_max = 100;
  endif

  ## Check consistency of parameters
  all(S(:) >= 0) || \
      error( "S contains negative values" );
  all(V(:) >= 0) || \
      error( "V contains negative values" );

  ## Initialize results
  R = zeros( C, K );
  Xc = zeros( 1, C ); # Xc(c) is the class c throughput
  Q = zeros( C, K );
  D = V .* S;

  ## Initialization of temporaries
  iter = 0;
  A = zeros( C, K );
  Q = diag(N/K)*ones(C,K); # Q(c,k) = N(c) / K

  i_single=find(m==1);
  i_multi=find(m<1);
  ## Main loop
  N(N==0)=1;
  do
    iter++;
    Qold = Q;
  
    ## A(c,k) = (N(c)-1)/N(c) * Q(c,k) + sum_{j=1, j|=c}^C Qold(j,k)
    A = diag( (N-1) ./ N )*Q + ( (1 - eye(C)) * Qold ); 

    ## R(c,k) = 
    ##  S(c,k)                  is k is a delay center
    ##  S(c,k) * (1+A(c,k))     if k is a queueing center; 
    R(:,i_multi) = S(:,i_multi);
    R(:,i_single) = S(:,i_single) .* ( 1 + A(:,i_single));

    ## X(c) = N(c) / (sum_k R(c,k) * V(c,k))
    Xc = N ./ (Z .+ sum(R.*V,2)'); 

    ## Q(c,k) = X(c) * R(c,k) * V(c,k)
    Q = (diag(Xc)*R).*V;

    ## err = norm(Q-Qold);
    err = norm((Q-Qold)./Qold, "inf");
  until (err<tol || iter>iter_max);

  if ( iter > iter_max ) 
    warning( "qncmmvaap(): Convergence not reached after %d iterations", iter_max );
  endif
  X = diag(Xc)*V; # X(c,k) = X(c) * V(c,k)
  U = diag(Xc)*D; # U(c,k) = X(c) * D(c,k)

  # U(N==0,:) = R(N==0,:) = Q(N==0,:) = X(N==0,:) = 0;

endfunction
%!test
%! S = [ 1 3 3; 2 4 3];
%! V = [ 1 1 3; 1 1 3];
%! N = [ 1 1 ];
%! m = [1 ; 1 ];
%! Z = [2 2 2];
%! fail( "qncmmvaap(N,S,V,m,Z)", "m must be" );
%! m = [1 ; 1 ; 1];
%! fail( "qncmmvaap(N,S,V,m,Z)", "Z must be" );

%!test
%! S = [ 1 3; 2 4];
%! V = [ 1 1; 1 1];
%! N = [ 1 1 ];
%! m = ones(1,2);
%! [U R Q X] = qncmmvaap(N,S,V,m);
%! assert( Q, [ .192 .808; .248 .752 ], 1e-3 );
%! Xc = ( X(:,1)./V(:,1) )';
%! assert( Xc, [ .154 .104 ], 1e-3 );
%! # Compute the (overall) class-c system response time
%! R_c = N ./ Xc;
%! assert( R_c, [ 6.508 9.614 ], 5e-3 );

%!demo
%! S = [ 1, 1, 1, 1; 2, 1, 3, 1; 4, 2, 3, 3 ];
%! V = ones(3,4);
%! N = [10 5 1];
%! m = [1 0 1 1];
%! [U R Q X] = qncmmvaap(N,S,V,m);
