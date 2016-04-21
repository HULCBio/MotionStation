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
## @deftypefn {Function File} {@var{L} =} dtmc_taexps (@var{P}, @var{n}, @var{p0})
## @deftypefnx {Function File} {@var{L} =} dtmc_taexps (@var{P}, @var{p0})
##
## This function is deprecated. Please use @code{dtmctaexps} instead.
##
## @code{dtmcexps}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function M = dtmc_taexps( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "dtmc_taexps is deprecated. Please use dtmctaexps instead");
  endif
  M = dtmctaexps( varargin{:} );
endfunction
%!test
%! P = dtmc_bd([1 1 1 1], [0 0 0 0]);
%! p0 = [1 0 0 0 0];
%! L = dtmc_taexps(P,p0);
%! assert( L, [.25 .25 .25 .25 0], 10*eps );

