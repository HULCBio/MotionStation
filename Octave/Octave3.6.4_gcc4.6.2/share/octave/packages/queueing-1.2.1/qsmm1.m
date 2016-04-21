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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}] =} qsmm1 (@var{lambda}, @var{mu})
##
## @cindex @math{M/M/1} system
##
## Compute utilization, response time, average number of requests and throughput for a @math{M/M/1} queue.
##
## @iftex
## The steady-state probability @math{\pi_k} that there are @math{k}
## jobs in the system, @math{k \geq 0}, can be computed as:
##
## @tex
## $$
## \pi_k = (1-\rho)\rho^k
## $$
## @end tex
##
## where @math{\rho = \lambda/\mu} is the server utilization.
##
## @end iftex
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## Arrival rate (@code{@var{lambda} > 0}).
##
## @item mu
## Service rate (@code{@var{mu} > @var{lambda}}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## Server utilization
##
## @item R
## Service center response time
##
## @item Q
## Average number of requests in the system
##
## @item X
## Service center throughput. If the system is ergodic, 
## we will always have @code{@var{X} = @var{lambda}}
##
## @item p0
## Steady-state probability that there are no requests in the system.
##
## @end table
##
## @var{lambda} and @var{mu} can be vectors of the same size. In this
## case, the results will be vectors as well.
##
## @seealso{qsmmm, qsmminf, qsmmmk}
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X p0] = qsmm1( lambda, mu )
  if ( nargin != 2 )
    print_usage();
  endif
  ( isvector(lambda) && isvector(mu) ) || \
      error( "lambda and mu must be vectors" );
  [ err lambda mu ] = common_size( lambda, mu );
  if ( err ) 
    error( "parameters are of incompatible size" );
  endif
  lambda = lambda(:)';
  mu = mu(:)';
  all( lambda > 0 ) || \
      error( "lambda must be >0" );
  all( mu > lambda ) || \
      error( "The system is not ergodic" );
  U = rho = lambda ./ mu; # utilization
  p0 = 1-rho;
  Q = rho ./ (1-rho);
  R = 1 ./ ( mu .* (1-rho) );
  X = lambda;
endfunction
%!test
%! fail( "qsmm1(10,5)", "not ergodic" );
%! fail( "qsmm1([2 2], [1 1 1])", "incompatible size");
