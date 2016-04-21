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
## @deftypefn {Function File} {[@var{Xu}, @var{Rl}, @var{Ru}] =} qnopenbsb (@var{lambda}, @dots{})
##
## @cindex bounds, balanced system
## @cindex open network
##
## This function is deprecated. Please use @code{qnosbsb} instead.
##
## @seealso{qnosbsb}
## 
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xu Rl Ru] = qnopenbsb( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnopenbsb is deprecated. Please use qnosbsb instead");
  endif
  [Xl Xu Rl Ru] = qnosbsb( varargin{:} );
endfunction

%!test
%! fail( "qnopenbsb( 0.1, [] )", "vector" );
%! fail( "qnopenbsb( 0.1, [0 -1])", "nonnegative" );
%! fail( "qnopenbsb( 0, [1 2] )", "lambda" );
%! fail( "qnopenbsb( -1, [1 2])", "lambda" );


