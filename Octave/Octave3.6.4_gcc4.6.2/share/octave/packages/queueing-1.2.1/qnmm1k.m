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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}, @var{pK}] =} qnmm1k (@var{lambda}, @var{mu}, @var{K})
##
## This function is deprecated. Use @code{qsmm1k} instead.
##
## @seealso{qsmm1k}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X p0 pK] = qnmm1k( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnmm1k is deprecated. Please use qsmm1k instead");
  endif
  [U R Q X p0 pK] = qsmm1k( varargin{:} );
endfunction
%!test
%! lambda = mu = 1;
%! K = 10;
%! [U R Q X p0] = qnmm1k(lambda,mu,K);
%! assert( Q, K/2, 1e-7 );
%! assert( U, 1-p0, 1e-7 );

%!test
%! # Compare result with one obtained by solvind the CTMC
%! lambda = 0.8;
%! mu = 0.8;
%! K = 10;
%! [U1 R1 Q1 X1] = qnmm1k( lambda, mu, K );
%! birth = lambda*ones(1,K);
%! death = mu*ones(1,K);
%! q = ctmc(ctmc_bd( birth, death ));
%! U2 = 1-q(1);
%! Q2 = dot( [0:K], q );
%! assert( U1, U2, 1e-4 );
%! assert( Q1, Q2, 1e-4 );

