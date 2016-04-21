## Copyright (C) 2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsaba (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsaba (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsaba (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsaba (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex bounds, asymptotic
## @cindex asymptotic bounds
## @cindex closed network, single class
##
## Compute Asymptotic Bounds for throughput and response time of closed, single-class networks.
##
## Single-server and infinite-server nodes are supported.
## Multiple-server nodes and general load-dependent servers are not
## supported.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## number of requests in the system (scalar, @code{@var{N}>0}).
##
## @item D
## @code{@var{D}(k)} is the service demand at center @math{k}
## (@code{@var{D}(k) @geq{} 0}).
##
## @item S
## @code{@var{S}(k)} is the mean service time at center @math{k}
## (@code{@var{S}(k) @geq{} 0}).
##
## @item V
## @code{@var{V}(k)} is the average number of visits to center
## @math{k} (@code{@var{V}(k) @geq{} 0}).
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}
## (if @var{m} is a scalar, all centers have that number of servers). If
## @code{@var{m}(k) < 1}, center @math{k} is a delay center (IS);
## if @code{@var{m}(k) = 1}, center @math{k} is a M/M/1-FCFS server.
## This function does not support multiple-server nodes. Default
## is 1.
##
## @item Z
## External delay (@code{@var{Z} @geq{} 0}). Default is 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @itemx Xu
## Lower and upper system throughput bounds.
##
## @item Rl
## @itemx Ru
## Lower and upper response time bounds.
##
## @end table
##
## @seealso{qncmaba}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qncsaba( varargin ) #N, S, V, m, Z )
  
  if (nargin<2 || nargin>5)
    print_usage();
  endif

  [err N S V m Z] = qncschkparam( varargin{:} );
  isempty(err) || error(err);

  all(m<=1) || \
      error( "multiple server nodes are not supported" );

  D = S.*V;

  Dtot_single = sum(D(m==1)); # total demand at single-server nodes
  Dtot_delay = sum(D(m<1)); # total demand at IS nodes
  Dtot = sum(D); # total demand
  Dmax = max(D); # max demand

  Xl = N/(N*Dtot_single + Dtot_delay + Z);
  Xu = min( N/(Dtot+Z), 1/Dmax );
  Rl = max( Dtot, N*Dmax - Z );
  Ru = N*Dtot_single + Dtot_delay;
endfunction

%!test
%! fail("qncsaba(-1,0)", "N must be");
%! fail("qncsaba(1,[])", "nonempty");
%! fail("qncsaba(1,[-1 2])", "nonnegative");
%! fail("qncsaba(1,[1 2],[1 2 3])", "incompatible size");
%! fail("qncsaba(1,[1 2 3],[1 2 -1])", "nonnegative");
%! fail("qncsaba(1,[1 2 3],[1 2 3],[1 2])", "incompatible size");
%! fail("qncsaba(1,[1 2 3],[1 2 3],[1 2 1])", "not supported");
%! fail("qncsaba(1,[1 2 3],[1 2 3],[1 1 1],-1)", "nonnegative");
%! fail("qncsaba(1,[1 2 3],[1 2 3],1,[0 0])", "scalar");

## Example 9.6 p. 913 Bolch et al.
%!test
%! N = 20;
%! S = [ 4.6*2 8 ];
%! Z = 120;
%! [X_l X_u R_l R_u] = qncsaba(N, S, ones(size(S)), ones(size(S)), Z);
%! assert( [X_u R_l], [0.109 64], 1e-3 );

