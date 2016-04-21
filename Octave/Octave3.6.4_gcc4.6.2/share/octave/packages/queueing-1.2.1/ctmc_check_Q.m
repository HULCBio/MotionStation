## Copyright (C)2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{result} @var{err}] =} ctmc_check_Q (@var{Q})
##
## This function is deprecated. Please use @code{ctmcchkQ} instead
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [result err] = ctmc_check_Q( Q )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "ctmc_check_Q is deprecated. Please use ctmcchkQ instead");
  endif
  [result err] = ctmcchkQ( Q );
endfunction
%!test
%! Q = [0];
%! [result err] = ctmc_check_Q(Q);
%! assert( result, 1 );
%! assert( err, "" );

%!test
%! N = 10;
%! Q = ctmc_bd(rand(1,N-1),rand(1,N-1));
%! [result err] = ctmc_check_Q(Q);
%! assert( result, N );
%! assert( err, "" );

%!test
%! Q = [1 2 3; 4 5 6];
%! [result err] = ctmc_check_Q(Q);
%! assert( result, 0 );
%! assert( index(err, "square") > 0 );

%!test
%! N = 10;
%! Q = ctmc_bd(rand(1,N-1),rand(1,N-1));
%! Q(2,1) = -1;
%! [result err] = ctmc_check_Q(Q);
%! assert( result, 0 );
%! assert( index(err, "infinitesimal") > 0 );

%!test
%! N = 10;
%! Q = ctmc_bd(rand(1,N-1),rand(1,N-1));
%! Q(1,1) += 7;
%! [result err] = ctmc_check_Q(Q);
%! assert( result, 0 );
%! assert( index(err, "infinitesimal") > 0 );
