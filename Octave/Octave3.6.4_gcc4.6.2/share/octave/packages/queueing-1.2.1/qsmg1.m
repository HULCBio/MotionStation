## Copyright (C) 2009 Dmitry Kolesnikov
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}] =} qsmg1 (@var{lambda}, @var{xavg}, @var{x2nd})
##
## @cindex @math{M/G/1} system
##
## Compute utilization, response time, average number of requests and
## throughput for a @math{M/G/1} system. The service time distribution
## is described by its mean @var{xavg}, and by its second moment
## @var{x2nd}. The computations are based on results from L. Kleinrock,
## @cite{Queuing Systems}, Wiley, Vol 2, and Pollaczek-Khinchine formula.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## Arrival rate.
##
## @item xavg
## Average service time
##
## @item x2nd
## Second moment of service time distribution
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## Service center utilization
##
## @item R
## Service center response time
##
## @item Q
## Average number of requests in the system
##
## @item X
## Service center throughput
##
## @item p0
## probability that there is not any request at system
##
## @end table
##
## @var{lambda}, @var{xavg}, @var{t2nd} can be vectors of the
## same size. In this case, the results will be vectors as well.
##
## @seealso{qsmh1}
##
## @end deftypefn

## Author: Dmitry Kolesnikov

function [U R Q X p0] = qsmg1(lambda, xavg, x2nd)
   if ( nargin != 3 )
      print_usage();
   endif
   ## bring the parameters to a common size
   [ err lambda xavg x2nd ] = common_size( lambda, xavg, x2nd );
   if ( err ) 
      error( "parameters are of incompatible size" );
   endif

   mu = 1 ./ xavg;
   rho = lambda ./ mu; 

   #coefficient of variation
   Cx = (x2nd .- xavg .* xavg) ./ (xavg .* xavg);

   #PK mean formula(s)
   Q = rho  .+ rho .* rho .* (1 .+ Cx) ./ (2 .* (1 .- rho));
   R = xavg .+ xavg .* rho .* (1 .+ Cx) ./ (2 .* (1 .- rho));

   p0 = exp(-rho);
   #General Results
   #utilization
   U = rho; 
   X = lambda;
endfunction
