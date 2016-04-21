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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncspb (@var{N}, @var{D} )
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncspb (@var{N}, @var{S}, @var{V} )
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncspb (@var{N}, @var{S}, @var{V}, @var{m} )
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncspb (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z} )
##
## @cindex bounds, PB
## @cindex PB bounds
## @cindex closed network, single class
##
## Compute PB Bounds (C. H. Hsieh and S. Lam, 1987) for single-class,
## closed networks.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## number of requests in the system (scalar). Must be @code{@var{N} > 0}.
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
## Lower and upper bounds on the system throughput.
##
## @item Rl
## @itemx Ru
## Lower and upper bounds on the system response time.
##
## @end table
##
## @seealso{qncsaba, qbcsbsb, qncsgb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_lower X_upper R_lower R_upper] = qncspb( varargin )
  if ( nargin < 2 || nargin > 5 )
    print_usage();
  endif

  [err N S V m Z] = qncschkparam( varargin{:} );
  isempty(err) || error(err);

  ( N>0 ) || \
      error("N must be positive");
  all(m==1) || \
      error("qncspb only supports single server nodes");

  D = S .* V;

  D_tot = sum(D);
  X_max = 1/max(D);
  X_min = 0;
  X_lower = N/( Z + D_tot + ...
               ( sum( D .^ N * (N-1-Z*X_min) ) / sum( D .^ (N-1) ) ) );
  X_upper = N/( Z + D_tot + ...
               ( sum( D .^ 2 * (N-1-Z*X_max) ) / sum( D ) ) );
  X_upper = min( X_upper, X_max ); # cap X upper bound to 1/max(D)
  R_lower = N/X_upper-Z;
  R_upper = N/X_lower-Z;
endfunction

%!test
%! fail( "qncspb( 1, [] )", "vector" );
%! fail( "qncspb( 1, [0 -1])", "nonnegative" );
%! fail( "qncspb( 0, [1 2] )", "positive" );
%! fail( "qncspb( -1, [1 2])", "nonnegative" );
%! fail( "qncspb( 1, [1 2], [1,1], [2, 2])", "single server" );
%! fail( "qncspb( 1, [1 2], [1,1], [1, 1], -1)", "nonnegative" );

%!# shared test function
%!function test_pb( D, expected, Z=0 )
%! for i=1:rows(expected)
%!   N = expected(i,1);
%!   [X_lower X_upper] = qncspb(N,D,ones(size(D)),ones(size(D)),Z);
%!   X_exp_lower = expected(i,2);
%!   X_exp_upper = expected(i,3);
%!   assert( [N X_lower X_upper], [N X_exp_lower X_exp_upper], 1e-4 )
%! endfor

%!test
%! # table IV
%! D = [ 0.1 0.1 0.09 0.08 ];
%! #            N  X_lower  X_upper
%! expected = [ 2  4.3174   4.3174; ... 
%!              5  6.6600   6.7297; ...
%!              10 8.0219   8.2700; ...
%!              20 8.8672   9.3387; ...
%!              80 9.6736   10.000 ];
%! test_pb(D, expected);
