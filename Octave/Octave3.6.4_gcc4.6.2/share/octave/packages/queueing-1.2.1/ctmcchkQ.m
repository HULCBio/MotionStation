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
## @deftypefn {Function File} {[@var{result} @var{err}] =} ctmcchkQ (@var{Q})
##
## @cindex Markov chain, continuous time
##
## If @var{Q} is a valid infinitesimal generator matrix, return
## the size (number of rows or columns) of @var{Q}. If @var{Q} is not
## an infinitesimal generator matrix, set @var{result} to zero, and
## @var{err} to an appropriate error string.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [result err] = ctmcchkQ( Q )

  persistent epsilon = 100*eps;

  if ( nargin != 1 )
    print_usage();
  endif

  result = 0;
  err = "";

  if ( !issquare(Q) )
    err = "P is not a square matrix";
    return;
  endif
  
  if (any(Q(~logical(eye(size(Q))))<0) || \ # there is any negative non-diagonal element
      norm( sum(Q,2), "inf" ) > epsilon )
    err = "Q is not an infinitesimal generator matrix";
    return;
  endif

  result = rows(Q);
endfunction
%!test
%! Q = [0];
%! [result err] = ctmcchkQ(Q);
%! assert( result, 1 );
%! assert( err, "" );

%!test
%! N = 10;
%! Q = ctmcbd(rand(1,N-1),rand(1,N-1));
%! [result err] = ctmcchkQ(Q);
%! assert( result, N );
%! assert( err, "" );

%!test
%! Q = [1 2 3; 4 5 6];
%! [result err] = ctmcchkQ(Q);
%! assert( result, 0 );
%! assert( index(err, "square") > 0 );

%!test
%! N = 10;
%! Q = ctmcbd(rand(1,N-1),rand(1,N-1));
%! Q(2,1) = -1;
%! [result err] = ctmcchkQ(Q);
%! assert( result, 0 );
%! assert( index(err, "infinitesimal") > 0 );

%!test
%! N = 10;
%! Q = ctmcbd(linspace(1,N-1,N-1),linspace(1,N-1,N-1));
%! Q(1,1) += 7;
%! [result err] = ctmcchkQ(Q);
%! assert( result, 0 );
%! assert( index(err, "infinitesimal") > 0 );
