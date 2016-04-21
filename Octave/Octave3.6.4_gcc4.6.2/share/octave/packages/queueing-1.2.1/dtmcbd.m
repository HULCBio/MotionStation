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
## @deftypefn {Function File} {@var{P} =} dtmcbd (@var{b}, @var{d})
##
## @cindex Markov chain, discrete time
## @cindex DTMC
## @cindex discrete time Markov chain
## @cindex birth-death process, DTMC
##
## Returns the transition probability matrix @math{P} for a discrete
## birth-death process over state space @math{1, 2, @dots{}, N}.
## @code{@var{b}(i)} is the transition probability from state
## @math{i} to @math{i+1}, and @code{@var{d}(i)} is the transition
## probability from state @math{i+1} to state @math{i}, @math{i=1, 2,
## @dots{}, N-1}.
##
## Matrix @math{\bf P} is therefore defined as:
##
## @iftex
## @tex
## $$ \pmatrix{ (1-\lambda_1) & \lambda_1 & & & & \cr
##              \mu_1 & (1 - \mu_1 - \lambda_2) & \lambda_2 & & \cr
##              & \mu_2 & (1 - \mu_2 - \lambda_3) & \lambda_3 & & \cr
##              \cr
##              & & \ddots & \ddots & \ddots & & \cr
##              \cr
##              & & & \mu_{N-2} & (1 - \mu_{N-2}-\lambda_{N-1}) & \lambda_{N-1} \cr
##              & & & & \mu_{N-1} & (1-\mu_{N-1}) }
## $$
## @end tex
## @noindent where @math{\lambda_i} and @math{\mu_i} are the birth and
## death probabilities, respectively.
## @end iftex
## @ifnottex
## @example
## @group
## /                                                             \
## | 1-b(1)     b(1)                                             |
## |  d(1)  (1-d(1)-b(2))     b(2)                               |
## |            d(2)      (1-d(2)-b(3))     b(3)                 |
## |                                                             |
## |                 ...           ...          ...              |
## |                                                             |
## |                         d(N-2)   (1-d(N-2)-b(N-1))  b(N-1)  |
## |                                        d(N-1)      1-d(N-1) |
## \                                                             /
## @end group
## @end example
## @end ifnottex
##
## @seealso{ctmcbd}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function P = dtmcbd( b, d )

  if ( nargin != 2 ) 
    print_usage();
  endif

  ( isvector( b ) && isvector( d ) ) || \
      error( "birth and death must be vectors" );
  b = b(:); # make b a column vector
  d = d(:); # make d a column vector
  size_equal( b, d ) || \
      error( "birth and death vectors must have the same length" );
  all( b >= 0 ) || \
      error( "birth probabilities must be >= 0" );
  all( d >= 0 ) || \
      error( "death probabilities must be >= 0" );
  all( ([b; 0] + [0; d]) <= 1 ) || \
      error( "d(i)+b(i+1) must be <= 1");

  P = diag( b, 1 ) + diag( d, -1 );
  P += diag( 1-sum(P,2) );
endfunction
%!test
%! birth = [.5 .5 .3];
%! death = [.6 .2 .3];
%! fail("dtmcbd(birth,death)","must be");

%!demo
%! birth = [ .2 .3 .4 ];
%! death = [ .1 .2 .3 ];
%! P = dtmcbd( birth, death );
%! disp(P)

