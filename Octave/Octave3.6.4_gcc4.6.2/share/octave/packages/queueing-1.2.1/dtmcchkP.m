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
## @deftypefn {Function File} {[@var{r} @var{err}] =} dtmcchkP (@var{P})
##
## @cindex Markov chain, discrete time
## @cindex DTMC
## @cindex discrete time Markov chain
##
## Check whether @var{P} is a valid transition probability matrix. 
##
## If @var{P} is valid, @var{r} is the size (number of rows or columns)
## of @var{P}. If @var{P} is not a transition probability matrix,
## @var{r} is set to zero, and @var{err} to an appropriate error string.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [result err] = dtmcchkP( P )

  if ( nargin != 1 )
    print_usage();
  endif

  result = 0;
  err = "";

  if ( !issquare(P) )
    err = "P is not a square matrix";
    return;
  endif
  
  if (  any(P(:)<-eps) || norm( sum(P,2) - 1, "inf" ) > columns(P)*eps )
    err = "P is not a stochastic matrix";
    return;
  endif

  result = rows(P);
endfunction
%!test
%! [r err] = dtmcchkP( [1 1 1; 1 1 1] );
%! assert( r, 0 );
%! assert( index(err, "square") > 0 );

%!test
%! [r err] = dtmcchkP( [1 0 0; 0 0.5 0; 0 0 0] );
%! assert( r, 0 );
%! assert( index(err, "stochastic") > 0 );

%!test
%! P = [0 1; 1 0];
%! assert( dtmcchkP(P), 2 );

%!test
%! P = dtmcbd( linspace(0.1,0.4,10), linspace(0.4,0.1,10) );
%! assert( dtmcchkP(P), rows(P) );

%!test
%! N = 1000;
%! P = reshape( 1:N^2, N, N );
%! P(1:N+1:end) = 0;
%! P = P ./ repmat(sum(P,2),1,N);
%! assert( dtmcchkP(P), N );