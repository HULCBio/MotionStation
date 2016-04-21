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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedsinglemvaapprox (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedsinglemvaapprox (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedsinglemvaapprox (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedsinglemvaapprox (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z}, @var{tol})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedsinglemvaapprox (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z}, @var{tol}, @var{iter_max})
##
## This function is deprecated. Please use @code{qncsmvaap} instead.
##
## @seealso{qncsmvaap}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnclosedsinglemvaapprox( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnclosedsinglemvaapprox is deprecated. Please use qncsmvaap instead");
  endif
  [U R Q X] = qncsmvaap( varargin{:} );
endfunction
%!test
%! fail( "qnclosedsinglemvaapprox()", "Invalid" );
%! fail( "qnclosedsinglemvaapprox( 10, [1 2], [1 2 3] )", "S, V and m" );
%! fail( "qnclosedsinglemvaapprox( 10, [-1 1], [1 1] )", ">= 0" );
%! fail( "qnclosedsinglemvaapprox( 10, [1 2], [1 2], [1 2] )", "supports");
%! fail( "qnclosedsinglemvaapprox( 10, [1 2], [1 2], [1 1], 0, -1)", "tol");

%!test
%! # Example p. 117 Lazowska et al.
%! S = [0.605 2.1 1.35];
%! V = [1 1 1];
%! N = 3;
%! Z = 15;
%! m = 1;
%! [U R Q X] = qnclosedsinglemvaapprox(N, S, V, m, Z);
%! Rs = dot(V,R);
%! Xs = N/(Z+Rs);
%! assert( Q, [0.0973 0.4021 0.2359], 1e-3 );
%! assert( Xs, 0.1510, 1e-3 );
%! assert( Rs, 4.87, 1e-3 );

