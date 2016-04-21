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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}] =} qsmh1 (@var{lambda}, @var{mu}, @var{alpha})
##
## @cindex @math{M/H_m/1} system
##
## Compute utilization, response time, average number of requests and
## throughput for a @math{M/H_m/1} system. In this system, the customer
## service times have hyper-exponential distribution:
##
## @iftex
## @tex
## $$ B(x) = \sum_{j=1}^m \alpha_j(1-e^{-\mu_j x}),\quad x>0 $$
## @end tex
## @end iftex
##
## @ifnottex
## @example
## @group
##        ___ m
##        \
## B(x) =  >  alpha(j) * (1-exp(-mu(j)*x))   x>0
##        /__ 
##            j=1
## @end group
## @end example
## @end ifnottex
##
## where @math{\alpha_j} is the probability that the request is served
## at phase @math{j}, in which case the average service rate is
## @math{\mu_j}. After completing service at phase @math{j}, for
## some @math{j}, the request exits the system.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## Arrival rate.
##
## @item mu
## @code{@var{mu}(j)} is the phase @math{j} service rate. The total
## number of phases @math{m} is @code{length(@var{mu})}.
##
## @item alpha
## @code{@var{alpha}(j)} is the probability that a request
## is served at phase @math{j}. @var{alpha} must have the same size
## as @var{mu}.
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
## @end table
##
## @end deftypefn

## Author: Dmitry Kolesnikov

function [U R Q X p0] = qsmh1(lambda, mu, alpha)
   if ( nargin != 3 )
      print_usage();
   endif
   if ( size(mu) != size(alpha) )
      error( "parameters are of incompatible size" );
   endif
   [n c] = size(mu);

   if (!is_scalar(lambda) && (n != length(lambda)) ) 
      error( "parameters are of incompatible size" );
   endif
   for i=1:n
      avg  = sum( alpha(i,:) .* (1 ./ mu(i,:)) );
      m2nd = sum( alpha(i,:) .* (1 ./ (mu(i,:) .* mu(i,:))) );
      if (is_scalar(lambda))
         xavg = avg;
         x2nd = m2nd;  
      else
         xavg(i) = avg;
         x2nd(i) = m2nd;
      endif
   endfor
   [U R Q X p0] = qsmg1(lambda, xavg, x2nd);
endfunction
