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
## @deftypefn {Function File} {@var{L} =} ctmc_exps (@var{Q}, @var{t}, @var{p} )
## @deftypefnx {Function File} {@var{L} =} ctmc_exps (@var{Q}, @var{p})
##
## This function is deprecated. Please use @code{ctmcexps} instead.
##
## @seealso{ctmcexps}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function L = ctmc_exps( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "ctmc_exps is deprecated. Please use ctmcexps instead");
  endif
  L = ctmcexps( varargin{:} );
endfunction
%!test
%! Q = [-1 1; 1 -1];
%! L = ctmc_exps(Q,10,[1 0]);
%! L = ctmc_exps(Q,linspace(0,10,100),[1 0]);

%!test
%! Q = ctmc_bd( [1 2 3], [3 2 1] );
%! p0 = [1 0 0 0];
%! t = linspace(0,10,10);
%! L1 = L2 = zeros(length(t),4);
%! # compute L using the differential equation formulation
%! ff = @(x,t) (x(:)'*Q+p0);
%! fj = @(x,t) (Q);
%! L1 = lsode( {ff, fj}, zeros(size(p0)), t );
%! # compute L using ctmc_exps (integral formulation)
%! for i=1:length(t)
%!   L2(i,:) = ctmc_exps(Q,t(i),p0);
%! endfor
%! assert( L1, L2, 1e-5);

