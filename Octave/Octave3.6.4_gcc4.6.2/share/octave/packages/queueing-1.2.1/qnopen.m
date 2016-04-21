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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopen (@var{lambda}, @var{S}, @var{V}, @dots{})
##
## @cindex open network
##
## Compute utilization, response time, average number of requests in the
## system, and throughput for open queueing networks. If @var{lambda} is
## a scalar, the network is considered a single-class QN and is solved
## using @code{qnopensingle}. If @var{lambda} is a vector, the network
## is considered as a multiclass QN and solved using @code{qnopenmulti}.
##
## @seealso{qnos, qnom}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnopen( lambda, S, V, varargin )
  if ( nargin < 3 )
    print_usage();
  endif
  if ( isscalar(lambda) )
    [U R Q X] = qnos(lambda, S, V, varargin{:});
  else
    [U R Q X] = qnom(lambda, S, V, varargin{:});
  endif
endfunction
%!test
%! # Example 34.1 p. 572
%! lambda = 3;
%! V = [16 7 8];
%! S = [0.01 0.02 0.03];
%! [U R Q X] = qnopen( lambda, S, V );
%! assert( R, [0.0192 0.0345 0.107], 1e-2 );
%! assert( U, [0.48 0.42 0.72], 1e-2 );

%!test
%! V = [1 1; 1 1];
%! S = [1 3; 2 4];
%! lambda = [3/19 2/19];
%! [U R Q] = qnopen(lambda, S, V);
%! assert( U(1,1), 3/19, 1e-6 );
%! assert( U(2,1), 4/19, 1e-6 );
%! assert( R(1,1), 19/12, 1e-6 );
%! assert( R(1,2), 57/2, 1e-6 );
%! assert( Q(1,1), .25, 1e-6 );

