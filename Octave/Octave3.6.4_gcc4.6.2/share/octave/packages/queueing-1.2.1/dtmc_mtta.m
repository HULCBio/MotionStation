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
## @deftypefn {Function File} {[@var{t} @var{N} @var{B}] =} dtmc_mtta (@var{P})
## @deftypefnx {Function File} {[@var{t} @var{N} @var{B}] =} dtmc_mtta (@var{P}, @var{p0})
##
## This function is deprecated. Please use @code{dtmcmtta} instead.
##
## @seealso{ctmcmtta}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [t N B] = dtmc_mtta( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function", 
	    "dtmc_mtta is deprecated. Please use dtmcmtta instead");
  endif
  [t N B] = dtmcmtta( varargin{:} );
endfunction
%!test
%! fail( "dtmc_mtta(1,2,3)" );
%! fail( "dtmc_mtta()" );

%!test
%! P = dtmcbd([0 .5 .5 .5], [.5 .5 .5 0]);
%! [t N B] = dtmc_mtta(P);
%! assert( t, [0 3 4 3 0], 10*eps );
%! assert( B([2 3 4],[1 5]), [3/4 1/4; 1/2 1/2; 1/4 3/4], 10*eps );
%! assert( B(1,1), 1 );
%! assert( B(5,5), 1 );

%!test
%! P = dtmcbd([0 .5 .5 .5], [.5 .5 .5 0]);
%! [t N B] = dtmc_mtta(P);
%! assert( t(3), 4, 10*eps );
%! assert( B(3,1), 0.5, 10*eps );
%! assert( B(3,5), 0.5, 10*eps );

## Example on p. 422 of [GrSn97]
%!test
%! P = dtmcbd([0 .5 .5 .5 .5], [.5 .5 .5 .5 0]);
%! [t N B] = dtmc_mtta(P);
%! assert( t(2:5), [4 6 6 4], 100*eps );
%! assert( B(2:5,1), [.8 .6 .4 .2]', 100*eps );
%! assert( B(2:5,6), [.2 .4 .6 .8]', 100*eps );

## "Rat maze" problem (p. 453 of [GrSn97]);
%!test
%! P = zeros(9,9);
%! P(1,[2 4]) = .5;
%! P(2,[1 5 3]) = 1/3;
%! P(3,[2 6]) = .5;
%! P(4,[1 5 7]) = 1/3;
%! P(5,:) = 0; P(5,5) = 1;
%! P(6,[3 5 9]) = 1/3;
%! P(7,[4 8]) = .5;
%! P(8,[7 5 9]) = 1/3;
%! P(9,[6 8]) = .5;
%! t = dtmc_mtta(P);
%! assert( t, [6 5 6 5 0 5 6 5 6], 10*eps );

