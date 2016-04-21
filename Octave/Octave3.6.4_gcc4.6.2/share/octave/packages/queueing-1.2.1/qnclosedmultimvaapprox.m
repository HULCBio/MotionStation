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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedmultimvaapprox (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedmultimvaapprox (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedmultimvaapprox (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedmultimvaapprox (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z}, @var{tol})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedmultimvaapprox (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z}, @var{tol}, @var{iter_max})
##
## This function is deprecated. Please use @code{qncmmvaap} instead.
##
## @seealso{qncmmvaap}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnclosedmultimvaapprox( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qqnclosedmultimvaapprox is deprecated. Please use qncmmvaap instead");
  endif
  [U R Q X] = qncmmvaap( varargin{:} );
endfunction
%!test
%! S = [ 1 3 3; 2 4 3];
%! V = [ 1 1 3; 1 1 3];
%! N = [ 1 1 ];
%! m = [1 ; 1 ];
%! Z = [2 2 2];
%! fail( "qnclosedmultimvaapprox(N,S,V,m,Z)", "m must be" );
%! m = [1 ; 1 ; 1];
%! fail( "qnclosedmultimvaapprox(N,S,V,m,Z)", "Z must be" );

%!test
%! S = [ 1 3; 2 4];
%! V = [ 1 1; 1 1];
%! N = [ 1 1 ];
%! m = ones(1,2);
%! [U R Q X] = qnclosedmultimvaapprox(N,S,V,m);
%! assert( Q, [ .192 .808; .248 .752 ], 1e-3 );
%! Xc = ( X(:,1)./V(:,1) )';
%! assert( Xc, [ .154 .104 ], 1e-3 );
%! # Compute the (overall) class-c system response time
%! R_c = N ./ Xc;
%! assert( R_c, [ 6.508 9.614 ], 5e-3 );

