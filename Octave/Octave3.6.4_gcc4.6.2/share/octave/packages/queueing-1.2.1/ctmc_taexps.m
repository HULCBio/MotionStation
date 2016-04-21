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
## @deftypefn {Function File} {@var{M} =} ctmc_taexps (@var{Q}, @var{t}, @var{p})
## @deftypefnx {Function File} {@var{M} =} ctmc_taexps (@var{Q}, @var{p})
##
## This function is deprecated. Please use @code{ctmctaexps} instead.
##
## @seealso{ctmctaexps}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function M = ctmc_taexps( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "ctmc_taexps is deprecated. Please use ctmctaexps instead");
  endif
  M = ctmctaexps( varargin{:} );
endfunction
%!test
%! Q = [ 0 0.1 0 0; \
%!       0.9 0 0.1 0; \
%!       0 0.9 0 0.1; \
%!       0 0 0 0 ];
%! Q -= diag( sum(Q,2) );
%! M = ctmc_taexps(Q, [1 0 0 0]);
%! assert( sum(M), 1, 10*eps );
