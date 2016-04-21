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
## @deftypefn {Function File} {@var{H} =} qncmnpop (@var{N})
##
## @cindex population mix
## @cindex closed network, multiple classes
##
## Given a network with @math{C} customer classes, this function
## computes the number of valid population mixes @code{@var{H}(r,n)} that can
## be constructed by the multiclass MVA algorithm by allocating @math{n}
## customers to the first @math{r} classes.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## Population vector. @code{@var{N}(c)} is the number of class-@math{c}
## requests in the system. The total number of requests in the network
## is @code{sum(@var{N})}.
## 
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item H
## @code{@var{H}(r,n)} is the number of valid populations that can be
## constructed allocating @math{n} customers to the first @math{r} classes.
##
## @end table
##
## @seealso{qncmmva,qncmpopmix}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function H = qncmnpop( N )
  (isvector(N) && all( N > 0 ) ) || \
      error( "N must be a vector of strictly positive integers" );
  N = N(:)'; # make N a row vector
  Ns = sum(N);
  R = length(N);
  
  ## Please note that the algorithm as described in the reference (see
  ## documentation in PDF format) seems incorrect: in the implementation
  ## above the @code{TOTAL_POP} variable is initialized with
  ## @code{@var{N}(1)}, instead of 0 as in the paper. Moreover, here the
  ## @code{TOTAL_POP} variable is incremented by @code{@var{N}(r)} at
  ## each iteration (instead of @code{@var{N}(r-1)} as in the paper)
  
  total_pop = N(1);
  H = zeros(R, Ns+1);
  H(1,1:N(1)+1) = 1;
  for r=2:R
    total_pop += N(r);
    for n=0:total_pop
      range = max(0,n-N(r)) : n;
      H(r,n+1) = sum( H(r-1, range+1 ) );
    endfor
  endfor
endfunction
%!test
%! H = qncmnpop( [1 2 2] );
%! assert( H, [1 1 0 0 0 0; 1 2 2 1 0 0; 1 3 5 5 3 1] );
