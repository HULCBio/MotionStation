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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnmvablo (@var{N}, @var{S}, @var{M}, @var{P})
##
## This function is deprecated. Please use @code{qncsmvablo} instead.
##
## @seealso{qncsmvablo}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnmvablo( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnmvablo is deprecated. Please use qncsmvablo instead");
  endif
  [U R Q X] = qncsmvablo( varargin{:} );
endfunction
%!test
%! fail( "qnmvablo( 10, [1 1], [4 5], [0 1; 1 0] )", "capacity");
%! fail( "qnmvablo( 6, [1 1], [4 5], [0 1; 1 1] )", "stochastic");
%! fail( "qnmvablo( 5, [1 1 1], [1 1], [0 1; 1 1] )", "3 elements");

%!test
%! # This is the example on section v) p. 422 of the reference paper
%! M = [12 10 14];
%! P = [0 1 0; 0 0 1; 1 0 0];
%! S = [1/1 1/2 1/3];
%! K = 27;
%! [U R Q X]=qnmvablo( K, S, M, P );
%! assert( R, [11.80 1.66 14.4], 1e-2 );

%!test
%! # This is example 2, i) and ii) p. 424 of the reference paper
%! M = [4 5 5];
%! S = [1.5 2 1];
%! P = [0 1 0; 0 0 1; 1 0 0];
%! K = 10;
%! [U R Q X]=qnmvablo( K, S, M, P );
%! assert( R, [6.925 8.061 4.185], 1e-3 );
%! K = 12;
%! [U R Q X]=qnmvablo( K, S, M, P );
%! assert( R, [7.967 9.019 8.011], 1e-3 );

%!test
%! # This is example 3, i) and ii) p. 424 of the reference paper
%! M = [8 7 6];
%! S = [0.2 1.2 1.4];
%! P = [ 0 0.5 0.5; 1 0 0; 1 0 0 ];
%! K = 10;
%! [U R Q X] = qnmvablo( K, S, M, P );
%! assert( R, [1.674 5.007 7.639], 1e-3 );
%! K = 12;
%! [U R Q X] = qnmvablo( K, S, M, P );
%! assert( R, [2.166 5.372 6.567], 1e-3 );

%!test
%! # Network which never blocks, central server model
%! M = [50 50 50];
%! S = [1 1/0.8 1/0.4];
%! P = [0 0.7 0.3; 1 0 0; 1 0 0];
%! K = 40;
%! [U1 R1 Q1] = qnmvablo( K, S, M, P );
%! V = qncsvisits(P);
%! [U2 R2 Q2] = qnclosedsinglemva( K, S, V );
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );

