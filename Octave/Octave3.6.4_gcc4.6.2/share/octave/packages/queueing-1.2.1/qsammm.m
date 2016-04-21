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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qsammm (@var{lambda}, @var{mu})
##
## @cindex asymmetric @math{M/M/m} system
##
## Compute @emph{approximate} utilization, response time, average number
## of requests in service and throughput for an asymmetric  @math{M/M/m}
## queue. In this system there are @math{m} different service centers
## connected to a single queue. Each server has its own (possibly different)
## service rate. If there is more than one server available, requests
## are routed to a randomly-chosen one.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## Arrival rate (@code{@var{lambda}>0}).
##
## @item mu
## @code{@var{mu}(i)} is the service rate of server
## @math{i}, @math{1 @leq{} i @leq{} m}.
## The system must be ergodic (@code{@var{lambda} < sum(@var{mu})}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## Approximate service center utilization,
## @math{U = \lambda / ( \sum_i \mu_i )}.
##
## @item R
## Approximate service center response time
##
## @item Q
## Approximate number of requests in the system
##
## @item X
## Approximate service center throughput. If the system is ergodic, 
## we will always have @code{@var{X} = @var{lambda}}
##
## @end table
##
## @seealso{qsmmm}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X p0 pm] = qsammm( lambda, mu )
  if ( nargin != 2 )
    print_usage();
  endif

  ( isscalar(lambda) && isvector(mu) ) || \
      error( "the parameters must be vectors" );

  m = length(mu); # number of servers

  all( lambda < sum(mu) ) || \
      error( "Processing capacity exceeded" );

  X = lambda;
  U = rho = lambda / sum(mu);
  Q = p0 = 0;
#{
  k=[0:m-1];
  p0 = 1 / ( ...
            sum( (m*rho).^k ./ factorial(k)) + ...
            (m*rho)^m / (factorial(m)*(1-rho)) ...
            );
  pm = (m*rho)^m/(factorial(m)*(1-rho))*p0;
#}
  p0 = 1 / ( ...
            sumexpn( m*rho, m-1 ) + ...
            expn(m*rho, m) / (1-rho) ...
            );
  pm = expn(m*rho, m)*p0/(1-rho);
  Q = m*rho+rho / (1-rho) * pm;
  R = Q / X;
endfunction
%!test
%! [U R Q X] = qsammm( 73,[10,15,20,20,25] );
%! assert( U, 0.81, 1e-2 );
%! assert( Q, 6.5278, 1e-4 );


