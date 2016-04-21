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
## @deftypefn {Function File} {@var{L} =} dtmc_exps (@var{P}, @var{n}, @var{p0})
## @deftypefnx {Function File} {@var{L} =} dtmc_exps (@var{P}, @var{p0})
##
## This function is deprecated. Please use @code{dtmcexps} instead.
##
## @seealso{dtmcexps}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function L = dtmc_exps ( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "dtmc_exps is deprecated. Please use dtmcexps instead");
  endif
  L = dtmcexps( varargin{:} );
endfunction
%!test
%! P = dtmc_bd([1 1 1 1], [0 0 0 0]);
%! L = dtmc_exps(P,[1 0 0 0 0]);
%! t = dtmc_mtta(P,[1 0 0 0 0]);
%! assert( L, [1 1 1 1 0] );
%! assert( sum(L), t );

%!test
%! P = dtmc_bd(linspace(0.1,0.4,5),linspace(0.4,0.1,5));
%! p0 = [1 0 0 0 0 0];
%! L = dtmc_exps(P,0,p0);
%! assert( L, p0 );