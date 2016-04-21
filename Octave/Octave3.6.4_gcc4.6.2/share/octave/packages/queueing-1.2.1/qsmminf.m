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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}] =} qsmminf (@var{lambda}, @var{mu})
##
## Compute utilization, response time, average number of requests and throughput for a @math{M/M/\infty} queue.
##
## The @math{M/M/\infty} system has an infinite number of identical
## servers; this kind of system is always stable for every arrival and
## service rates.
##
## @cindex @math{M/M/}inf system
##
## @iftex
## The steady-state probability @math{\pi_k} that there are @math{k}
## requests in the system, @math{k @geq{} 0}, can be computed as:
##
## @tex
## $$
## \pi_k = {1 \over k!} \left( \lambda \over \mu \right)^k e^{-\lambda / \mu}
## $$
## @end tex 
## @end iftex
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## Arrival rate (@code{@var{lambda}>0}).
##
## @item mu
## Service rate (@code{@var{mu}>0}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## Traffic intensity (defined as @math{\lambda/\mu}). Note that this is
## different from the utilization, which in the case of @math{M/M/\infty}
## centers is always zero.
##
## @cindex traffic intensity
##
## @item R
## Service center response time.
##
## @item Q
## Average number of requests in the system (which is equal to the
## traffic intensity @math{\lambda/\mu}).
##
## @item X
## Throughput (which is always equal to @code{@var{X} = @var{lambda}}).
##
## @item p0
## Steady-state probability that there are no requests in the system
##
## @end table
##
## @var{lambda} and @var{mu} can be vectors of the same size. In this
## case, the results will be vectors as well.
##
## @seealso{qsmm1,qsmmm,qsmmmk}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X p0] = qsmminf( lambda, mu )
  if ( nargin != 2 )
    print_usage();
  endif
  ( isvector(lambda) && isvector(mu) ) || \
      error( "lambda and mu must be vectors" );
  [ err lambda mu ] = common_size( lambda, mu );
  if ( err ) 
    error( "Parameters are of incompatible size" );
  endif  
  lambda = lambda(:)';
  mu = mu(:)';
  ( all( lambda>0 ) && all( mu>0 ) ) || \
      error( "lambda and mu must be >0" );
  U = Q = lambda ./ mu; # Traffic intensity.
  p0 = exp(-lambda./mu); # probability that there are 0 requests in the system
  R = 1 ./ mu;
  X = lambda;
endfunction
%!test
%! fail( "qsmminf( [1 2], [1 2 3] )", "incompatible size");
%! fail( "qsmminf( [-1 -1], [1 1] )", ">0" );
