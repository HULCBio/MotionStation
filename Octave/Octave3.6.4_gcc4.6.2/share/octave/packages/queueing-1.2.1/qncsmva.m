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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{G}] =} qncsmva (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{G}] =} qncsmva (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{G}] =} qncsmva (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex Mean Value Analysys (MVA)
## @cindex closed network, single class
## @cindex normalization constant
##
## Analyze closed, single class queueing networks using the exact Mean Value Analysis (MVA) algorithm. 
##
## The following queueing disciplines are supported: FCFS, LCFS-PR, PS
## and IS (Infinite Server). This function supports fixed-rate service
## centers or multiple server nodes. For general load-dependent service
## centers, use the function @code{qncsmvald} instead.
##
## Additionally, the normalization constant @math{G(n)}, @math{n=0,
## @dots{}, N} is computed; @math{G(n)} can be used in conjunction with
## the BCMP theorem to compute steady-state probabilities.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## Population size (number of requests in the system, @code{@var{N} @geq{} 0}).
## If @code{@var{N} == 0}, this function returns
## @code{@var{U} = @var{R} = @var{Q} = @var{X} = 0}
##
## @item S
## @code{@var{S}(k)} is the mean service time at center @math{k}
## (@code{@var{S}(k) @geq{} 0}).
##
## @item V
## @code{@var{V}(k)} is the average number of visits to service center
## @math{k} (@code{@var{V}(k) @geq{} 0}).
##
## @item Z
## External delay for customers (@code{@var{Z} @geq{} 0}). Default is 0.
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}
## (if @var{m} is a scalar, all centers have that number of servers). If
## @code{@var{m}(k) < 1}, center @math{k} is a delay center (IS);
## otherwise it is a regular queueing center (FCFS, LCFS-PR or PS) with
## @code{@var{m}(k)} servers. Default is @code{@var{m}(k) = 1} for all
## @math{k} (each service center has a single server).
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
## The @emph{Residence Time} at center @math{k} is
## @code{@var{R}(k) * @var{V}(k)}.
## The system response time @var{Rsys}
## can be computed either as @code{@var{Rsys} = @var{N}/@var{Xsys} - Z}
## or as @code{@var{Rsys} = dot(@var{R},@var{V})}
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
## @item G
## Normalization constants. @code{@var{G}(n+1)} corresponds to the value
## of the normalization constant @math{G(n)}, @math{n=0, @dots{}, N} as
## array indexes in Octave start from 1. @math{G(n)} can be used in
## conjunction with the BCMP theorem to compute steady-state
## probabilities.
##
## @end table
##
## @quotation Note
## In presence of load-dependent servers (i.e., if @code{@var{m}(i)>1}
## for some @math{i}), the MVA algorithm is known to be numerically
## unstable. Generally this problem manifests itself as negative
## response times produced by this function.
## @end quotation
##
## @seealso{qncsmvald,qncscmva}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X G] = qncsmva( varargin )

  if ( nargin < 3 || nargin > 5 ) 
    print_usage();
  endif

  [err N S V m Z] = qncschkparam( varargin{:} );
  isempty(err) || error(err);

  K = length(S); # Number of servers

  U = R = Q = X = zeros( 1, K );
  G = zeros(1,N+1); G(1) = 1;
  if ( N == 0 ) # Trivial case of empty population: just return all zeros
    return;
  endif

  i_single = find( m==1 );
  i_multi = find( m>1 );
  i_delay = find( m<1 );

  ## Initialize results
  if ( length(i_multi)>0 )
    p = zeros( K, max(m)+1 ); # p(i,j+1) is the probability that there are j jobs at server i
    p(:,1) = 1;
  endif
  X_s = 0; # System throughput

  ## Main MVA loop, iterates over the population size
  for n=1:N 

    R(i_single) = S(i_single) .* (1 + Q(i_single)); 
    for i=i_multi # I cannot easily vectorize this
      j=0:m(i)-2;
      R(i) = S(i) / m(i) * (1+Q(i)+dot( m(i)-j-1, p( i, 1+j ) ) );
    endfor
    R(i_delay) = S(i_delay);

    R_s = dot( V, R ); # System response time
    X_s = n / ( Z + R_s ); # System Throughput
    Q = X_s * ( V .* R );
    G(1+n) = G(n) / X_s;
    
    ## prepare for next iteration
    lambda_i = V * X_s; # lambda_i(i) is the node i throughput
    for i=i_multi
      j=1:m(i)-1; # range
      p(i, j+1) = lambda_i(i) .* S(i) ./ min( j,m(i) ) .* p(i,j);
      p(i,1) = 1 - 1/m(i) * ...
          (V(i)*S(i)*X_s + dot( m(i)-j, p(i,j+1)) );
    endfor

  endfor
  X = X_s * V; # Service centers throughput
  U(i_single) = X(i_single) .* S(i_single);
  U(i_delay) = X(i_delay) .* S(i_delay);
  U(i_multi) = X(i_multi) .* S(i_multi) ./ m(i_multi);
endfunction

#{

## This function is slightly faster (and more compact) than the above
## when all servers are single-server or delay centers. Improvements are
## quite small (10%-15% faster, depends on the network size), so at the
## moment it is commented out.
function [U R Q X G] = __qncsmva_fast( N, S, V, m, Z )
  U = R = Q = X = zeros( 1, length(S) );
  X_s = 0; # System throughput
  G = zeros(1,N+1); G(1) = 1;

  ## Main MVA loop
  for n=1:N 
    R = S .* (1+Q.*(m==1));
    R_s = dot( V, R ); # System response time
    X_s = n / ( Z + R_s ); # System Throughput
    Q = X_s * ( V .* R );
    G(1+n) = G(n) / X_s;    
  endfor
  X = X_s * V; # Service centers throughput
  U = X .* S;
endfunction

#}

%!test
%! fail( "qncsmva()", "Invalid" );
%! fail( "qncsmva( 10, [1 2], [1 2 3] )", "incompatible size" );
%! fail( "qncsmva( 10, [-1 1], [1 1] )", "nonnegative" );
%! fail( "qncsmva( 10.3, [-1 1], [1 1] )", "integer" );
%! fail( "qncsmva( -0.3, [-1 1], [1 1] )", "nonnegative" );

## Check if networks with only one type of server are handled correctly
%!test
%! qncsmva(1,1,1,1);
%! qncsmva(1,1,1,-1);
%! qncsmva(1,1,1,2);
%! qncsmva(1,[1 1],[1 1],[-1 -1]);
%! qncsmva(1,[1 1],[1 1],[1 1]);
%! qncsmva(1,[1 1],[1 1],[2 2]);

## Check degenerate case of N==0 (LI case)
%!test
%! N = 0;
%! S = [1 2 3 4];
%! V = [1 1 1 4];
%! [U R Q X] = qncsmva(N, S, V);
%! assert( U, 0*S );
%! assert( R, 0*S );
%! assert( Q, 0*S );
%! assert( X, 0*S );

## Check degenerate case of N==0 (LD case)
%!test
%! N = 0;
%! S = [1 2 3 4];
%! V = [1 1 1 4];
%! m = [2 3 4 5];
%! [U R Q X] = qncsmva(N, S, V, m);
%! assert( U, 0*S );
%! assert( R, 0*S );
%! assert( Q, 0*S );
%! assert( X, 0*S );

%!test
%! # Exsample 3.42 p. 577 Jain
%! S = [ 0.125 0.3 0.2 ]';
%! V = [ 16 10 5 ];
%! N = 20;
%! m = ones(1,3)';
%! Z = 4;
%! [U R Q X] = qncsmva(N,S,V,m,Z);
%! assert( R, [ .373 4.854 .300 ], 1e-3 );
%! assert( Q, [ 1.991 16.177 0.500 ], 1e-3 );
%! assert( all( U>=0 ) );
%! assert( all( U<=1 ) );
%! assert( Q, R.*X, 1e-5 ); # Little's Law

%!test
%! # Exsample 3.42 p. 577 Jain
%! S = [ 0.125 0.3 0.2 ];
%! V = [ 16 10 5 ];
%! N = 20;
%! m = ones(1,3);
%! Z = 4;
%! [U R Q X] = qncsmva(N,S,V,m,Z);
%! assert( R, [ .373 4.854 .300 ], 1e-3 );
%! assert( Q, [ 1.991 16.177 0.500 ], 1e-3 );
%! assert( all( U>=0 ) );
%! assert( all( U<=1 ) );
%! assert( Q, R.*X, 1e-5 ); # Little's Law

%!test
%! # Example 8.4 p. 333 Bolch et al.
%! S = [ .5 .6 .8 1 ];
%! N = 3;
%! m = [2 1 1 -1];
%! V = [ 1 .5 .5 1 ];
%! [U R Q X] = qncsmva(N,S,V,m);
%! assert( Q, [ 0.624 0.473 0.686 1.217 ], 1e-3 );
%! assert( X, [ 1.218 0.609 0.609 1.218 ], 1e-3 );
%! assert( all(U >= 0 ) );
%! assert( all(U( m>0 ) <= 1 ) );
%! assert( Q, R.*X, 1e-5 ); # Little's Law

%!test
%! # Example 8.3 p. 331 Bolch et al.
%! # This is a single-class network, which however nothing else than
%! # a special case of multiclass network
%! S = [ 0.02 0.2 0.4 0.6 ];
%! K = 6;
%! V = [ 1 0.4 0.2 0.1 ];
%! [U R Q X] = qncsmva(K, S, V);
%! assert( U, [ 0.198 0.794 0.794 0.595 ], 1e-3 );
%! assert( R, [ 0.025 0.570 1.140 1.244 ], 1e-3 );
%! assert( Q, [ 0.244 2.261 2.261 1.234 ], 1e-3 );
%! assert( X, [ 9.920 3.968 1.984 0.992 ], 1e-3 );

%!test
%! # Check bound analysis
%! N = 10; # max population
%! for n=1:N
%!   S = [1 0.8 1.2 0.5];
%!   V = [1 2 2 1];
%!   [U R Q X] = qncsmva(n, S, V);
%!   Xs = X(1)/V(1);
%!   Rs = dot(R,V);
%!   # Compare with balanced system bounds
%!   [Xlbsb Xubsb Rlbsb Rubsb] = qncsbsb( n, S .* V );
%!   assert( Xlbsb<=Xs );
%!   assert( Xubsb>=Xs );
%!   assert( Rlbsb<=Rs );
%!   assert( Rubsb>=Rs );
%!   # Compare with asymptotic bounds
%!   [Xlab Xuab Rlab Ruab] = qncsaba( n, S .* V );
%!   assert( Xlab<=Xs );
%!   assert( Xuab>=Xs );
%!   assert( Rlab<=Rs );
%!   assert( Ruab>=Rs );
%! endfor

%!demo
%! S = [ 0.125 0.3 0.2 ];
%! V = [ 16 10 5 ];
%! N = 20;
%! m = ones(1,3);
%! Z = 4;
%! [U R Q X] = qncsmva(N,S,V,m,Z);
%! X_s = X(1)/V(1); # System throughput
%! R_s = dot(R,V); # System response time
%! printf("\t    Util      Qlen     RespT      Tput\n");
%! printf("\t--------  --------  --------  --------\n");
%! for k=1:length(S)
%!   printf("Dev%d\t%8.4f  %8.4f  %8.4f  %8.4f\n", k, U(k), Q(k), R(k), X(k) );
%! endfor
%! printf("\nSystem\t          %8.4f  %8.4f  %8.4f\n\n", N-X_s*Z, R_s, X_s );

