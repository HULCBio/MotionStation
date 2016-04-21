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
## @deftypefn {Function File} {@var{Q} =} ctmcbd (@var{b}, @var{d})
##
## @cindex Markov chain, continuous time
## @cindex continuous time Markov chain
## @cindex CTMC
## @cindex birth-death process, CTMC
##
## Returns the infinitesimal generator matrix @math{Q} for a continuous
## birth-death process over state space @math{1, 2, @dots{}, N}.
## @code{@var{b}(i)} is the transition rate from state @math{i} to
## @math{i+1}, and @code{@var{d}(i)} is the transition rate from state
## @math{i+1} to state @math{i}, @math{i=1, 2, @dots{}, N-1}.
##
## Matrix @math{\bf Q} is therefore defined as:
##
## @iftex
## @tex
## $$ \pmatrix{ -\lambda_1 & \lambda_1 & & & & \cr
##              \mu_1 & -(\mu_1 + \lambda_2) & \lambda_2 & & \cr
##              & \mu_2 & -(\mu_2 + \lambda_3) & \lambda_3 & & \cr
##              \cr
##              & & \ddots & \ddots & \ddots & & \cr
##              \cr
##              & & & \mu_{N-2} & -(\mu_{N-2}+\lambda_{N-1}) & \lambda_{N-1} \cr
##              & & & & \mu_{N-1} & -\mu_{N-1} }
## $$
## @end tex
## @noindent where @math{\lambda_i} and @math{\mu_i} are the birth and
## death rates, respectively.
## @end iftex
## @ifnottex
## @example
## @group
## /                                                          \
## | -b(1)     b(1)                                           |
## |  d(1) -(d(1)+b(2))     b(2)                              |
## |           d(2)     -(d(2)+b(3))        b(3)              |
## |                                                          |
## |                ...           ...          ...            |
## |                                                          |
## |                       d(N-2)    -(d(N-2)+b(N-1))  b(N-1) |
## |                                       d(N-1)     -d(N-1) |
## \                                                          /
## @end group
## @end example
## @end ifnottex
##
## @seealso{dtmcbd}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function Q = ctmcbd( birth, death )

  if ( nargin != 2 ) 
    print_usage();
  endif

  ( isvector( birth ) && isvector( death ) ) || \
      error( "birth and death must be vectors" );
  birth = birth(:); # make birth a column vector
  death = death(:); # make death a column vector
  size_equal( birth, death ) || \
      error( "birth and death rates must have the same length" );
  all( birth >= 0 ) || \
      error( "birth rates must be >= 0" );
  all( death >= 0 ) || \
      error( "death rates must be >= 0" );

  ## builds the infinitesimal generator matrix
  Q = diag( birth, 1 ) + diag( death, -1 );
  Q -= diag( sum(Q,2) );
endfunction
%!test
%! birth = [ 1 1 1 ];
%! death = [ 2 2 2 ];
%! Q = ctmcbd( birth, death );
%! assert( ctmc(Q), [ 8/15 4/15 2/15 1/15 ], 1e-5 );
