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
## @deftypefn {Function File} {@var{P} =} dtmc_bd (@var{b}, @var{d})
##
## This function is deprecated. Please use @code{dtmcbd} instead.
##
## @seealso{dtmcbd}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function P = dtmc_bd( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "dtmc_bd is deprecated. Please use dtmcbd instead");
  endif
  P = dtmcbd( varargin{:} );
endfunction
%!test
%! birth = [.5 .5 .3];
%! death = [.6 .2 .3];
%! fail("dtmc_bd(birth,death)","must be");
