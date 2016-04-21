## Copyright (C) 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {@var{M} =} ctmc_fpt (@var{Q})
## @deftypefnx {Function File} {@var{m} =} ctmc_fpt (@var{Q}, @var{i}, @var{j})
##
## This function is deprecated. Please use @code{ctmcfpt} instead.
##
## @seealso{ctmcfpt}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function result = ctmc_fpt( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "ctmc_fpt is deprecated. Please use ctmcfpt instead");
  endif
  result = ctmcfpt( varargin{:} );
endfunction
%!test
%! N = 10;
%! Q = reshape(1:N^2,N,N);
%! Q(1:N+1:end) = 0;
%! Q -= diag(sum(Q,2));
%! M = ctmc_fpt(Q);
%! assert( all(diag(M) < 10*eps) );
