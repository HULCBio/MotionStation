## Copyright (C) 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## Copyright (C) 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}, @var{pK}] =} qnmmmk (@var{lambda}, @var{mu}, @var{m}, @var{K})
##
## This function is deprecated. Please use @code{qsmmmk} instead.
##
## @seealso{qsmmmk}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X p0 pK] = qnmmmk( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnmmmk is deprecated. Please use qsmmmk instead");
  endif
  [U R Q X p0 pK] = qsmmmk( varargin{:} );
endfunction
%!test
%! lambda = mu = m = 1;
%! k = 10;
%! [U R Q X p0] = qnmmmk(lambda,mu,m,k);
%! assert( Q, k/2, 1e-7 );
%! assert( U, 1-p0, 1e-7 );

%!test
%! lambda = [1 0.8 2 9.2 0.01];
%! mu = lambda + 0.17;
%! k = 12;
%! [U1 R1 Q1 X1] = qnmm1k(lambda,mu,k);
%! [U2 R2 Q2 X2] = qnmmmk(lambda,mu,1,k);
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );
%! assert( X1, X2, 1e-5 );
%! #assert( [U1 R1 Q1 X1], [U2 R2 Q2 X2], 1e-5 );

%!test
%! lambda = 0.9;
%! mu = 0.75;
%! k = 10;
%! [U1 R1 Q1 X1 p01] = qnmmmk(lambda,mu,1,k);
%! [U2 R2 Q2 X2 p02] = qnmm1k(lambda,mu,k);
%! assert( [U1 R1 Q1 X1 p01], [U2 R2 Q2 X2 p02], 1e-5 );

%!test
%! lambda = 0.8;
%! mu = 0.85;
%! m = 3;
%! k = 5;
%! [U1 R1 Q1 X1 p0] = qnmmmk( lambda, mu, m, k );
%! birth = lambda*ones(1,k);
%! death = [ mu*linspace(1,m,m) mu*m*ones(1,k-m) ];
%! q = ctmc(ctmc_bd( birth, death ));
%! U2 = dot( q, min( 0:k, m )/m );
%! assert( U1, U2, 1e-4 );
%! Q2 = dot( [0:k], q );
%! assert( Q1, Q2, 1e-4 );
%! assert( p0, q(1), 1e-4 );

%!test
%! # This test comes from an example I found on the web 
%! lambda = 40;
%! mu = 30;
%! m = 3;
%! k = 7;
%! [U R Q X p0] = qnmmmk( lambda, mu, m, k );
%! assert( p0, 0.255037, 1e-6 );
%! assert( R, 0.036517, 1e-6 );

%!test
%! # This test comes from an example I found on the web 
%! lambda = 50;
%! mu = 10;
%! m = 4;
%! k = 6;
%! [U R Q X p0 pk] = qnmmmk( lambda, mu, m, k );
%! assert( pk, 0.293543, 1e-6 );

%!test
%! # This test comes from an example I found on the web 
%! lambda = 3;
%! mu = 2;
%! m = 2;
%! k = 5;
%! [U R Q X p0 pk] = qnmmmk( lambda, mu, m, k );
%! assert( p0, 0.179334, 1e-6 );
%! assert( pk, 0.085113, 1e-6 );
%! assert( Q, 2.00595, 1e-5 );
%! assert( R-1/mu, 0.230857, 1e-6 ); # waiting time in the queue

