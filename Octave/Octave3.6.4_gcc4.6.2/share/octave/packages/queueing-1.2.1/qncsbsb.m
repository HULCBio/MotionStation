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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsbsb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsbsb (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsbsb (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncsbsb (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex bounds, balanced system
## @cindex closed network, single class
## @cindex balanced system bounds
##
## Compute Balanced System Bounds on system throughput and response time for closed, single-class networks.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## number of requests in the system (scalar).
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
## @math{k} (@code{@var{V}(k) @geq{} 0}). Default is 1.
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}. This
## function supports @code{@var{m}(k) = 1} only (sing-eserver FCFS
## nodes). This option is left for compatibility with
## @code{qncsaba}, Default is 1.
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
## Lower and upper bound on the system throughput.
##
## @item Rl
## @itemx Ru
## Lower and upper bound on the system response time.
##
## @end table
##
## @seealso{qncmbsb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qncsbsb( varargin )

  if (nargin<2 || nargin>5)
    print_usage();
  endif

#{
  ( isscalar(N) && N > 0 ) || \
      error( "N must be a positive integer" );
  (isvector(S) && length(S)>0) || \
      error( "S/D must be a nonempty vector" );
  all(S>=0) || \
      error( "S/D must contain nonnegative values");
  S = S(:)';
  K = length(S);

  if ( nargin < 3 || isempty(V) )
    D = S;
  else
    (isvector(V) && length(V) == K) || \
	error( "V must be a vector with %d elements", K );
    all(V>=0) || \
	error( "V must contain nonnegative values" );
    V = V(:)';
    D = S .* V;
  endif

  if ( nargin < 4 || isempty(m) )
    ## not used
  else
    (isvector(m) && length(m) == K) || \
	error( "m must be a vector with %d elements", K );
    all(m==1) || \
	error( "this function supports M/M/1 servers only" );
  endif

  if ( nargin < 5 || isempty(Z) )
    Z = 0;
  else
    ( isscalar(Z) && Z >= 0 ) || \
        error( "Z must be a nonnegative scalar" );
  endif
#}

  [err N S V m Z] = qncschkparam( varargin{:} );
  isempty(err) || error(err);

  all(m==1) || \
      error( "this function supports M/M/1 servers only" );

  D = S .* V;

  D_max = max(D);
  D_tot = sum(D);
  D_ave = mean(D);
  Xl = N/(D_tot+Z+( (N-1)*D_max )/( 1+Z/(N*D_tot) ) );
  Xu = min( 1/D_max, N/( D_tot+Z+( (N-1)*D_ave )/(1+Z/D_tot) ) );
  Rl = max( N*D_max-Z, D_tot+( (N-1)*D_ave )/( 1+Z/D_tot) );
  Ru = D_tot + ( (N-1)*D_max )/( 1+Z/(N*D_tot) );
endfunction

%!test
%! fail("qncsbsb(-1,0)", "N must be");
%! fail("qncsbsb(1,[])", "nonempty");
%! fail("qncsbsb(1,[-1 2])", "nonnegative");
%! fail("qncsbsb(1,[1 2],[1 2 3])", "incompatible size");
%! fail("qncsbsb(1,[1 2 3],[1 2 3],[1 2])", "incompatible size");
%! fail("qncsbsb(1,[1 2 3],[1 2 3],[1 2 1])", "M/M/1 servers");
%! fail("qncsbsb(1,[1 2 3],[1 2 3],[1 1 1],-1)", "nonnegative");
%! fail("qncsbsb(1,[1 2 3],[1 2 3],[1 1 1],[0 0])", "scalar");

