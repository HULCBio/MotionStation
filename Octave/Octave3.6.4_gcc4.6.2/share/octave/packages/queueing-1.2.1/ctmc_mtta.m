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
## @deftypefn {Function File} {@var{t} =} ctmc_mtta (@var{Q}, @var{p})
##
## This function is deprecated. Please use @code{ctmcmtta} instead.
##
## @seealso{ctmcmtta}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function t = ctmc_mtta( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "ctmc_mtta is deprecated. Please use ctmcmtta instead");
  endif
  t = ctmcmtta( varargin{:} );
endfunction
%!test
%! Q = [0 1 0; 1 0 1; 0 1 0 ]; Q -= diag( sum(Q,2) );
%! fail( "ctmc_mtta(Q,[1 0 0])", "no absorbing");

%!test
%! Q = [0 1 0; 1 0 1; 0 0 0; 0 0 0 ];
%! fail( "ctmc_mtta(Q,[1 0 0])", "square matrix");

%!test
%! Q = [0 1 0; 1 0 1; 0 0 0 ];
%! fail( "ctmc_mtta(Q,[1 0 0])", "infinitesimal");

%!test
%! Q = [ 0 0.1 0 0; \
%!       0.9 0 0.1 0; \
%!       0 0.9 0 0.1; \
%!       0 0 0 0 ];
%! Q -= diag( sum(Q,2) );
%! assert( ctmc_mtta( Q,[0 0 0 1] ), 0 ); # state 4 is absorbing

%!test
%! Q = [-1 1; 0 0];
%! assert( ctmc_mtta( Q, [0 1] ), 0 ); # state 2 is absorbing
%! assert( ctmc_mtta( Q, [1 0] ), 1 ); # the result has been computed by hand

