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
## @deftypefn {Function File} {pop_mix =} qncmpopmix (@var{k}, @var{N})
##
## @cindex population mix
## @cindex closed network, multiple classes
##
## Return the set of valid population mixes with exactly @var{k}
## customers, for a closed multiclass Queueing Network with population
## vector @var{N}. More specifically, given a multiclass Queueing
## Network with @math{C} customer classes, such that there are
## @code{@var{N}(i)} requests of class @math{i}, a
## @math{k}-mix @var{mix} is a @math{C}-dimensional vector with the
## following properties:
##
## @example
## @group
## all( mix >= 0 );
## all( mix <= N );
## sum( mix ) == k;
## @end group
## @end example
## 
## @noindent This function enumerates all valid @math{k}-mixes, such that
## @code{@var{pop_mix}(i)} is a @math{C} dimensional row vector representing
## a valid population mix, for all @math{i}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item k
## Total population size of the requested mix. @var{k} must be a nonnegative integer
##
## @item N
## @code{@var{N}(i)} is the number of class @math{i} requests.
## The condition @code{@var{k} @leq{} sum(@var{N})} must hold.
## 
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item pop_mix
## @code{@var{pop_mix}(i,j)} is the number of class @math{j} requests
## in the @math{i}-th population mix. The number of
## population mixes is @code{rows( @var{pop_mix} ) }.
##
## @end table
##
## Note that if you are interested in the number of @math{k}-mixes
## and you don't care to enumerate them, you can use the funcion
## @code{qnmvapop}.
##
## @seealso{qncmnpop}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function pop_mix = qncmpopmix( k, population )

  if ( nargin != 2 ) 
    print_usage();
  endif

  isvector( population ) && all( population>=0 ) || \
      error( "N must be an array >=0" );
  R = length(population); # number of classes
  ( isscalar(k) && k >= 0 && k <= sum(population) ) || \
      error( "k must be a scalar <= %d", sum(population));
  N = zeros(1, R);
  const = min(k, population);
  mp = 0;
  pop_mix = []; # Init result
  while ( N(R) <= const(R) )
    x=k-mp;
    ## Fill the current configuration
    i=1;
    while ( x>0 && i<=R )
      N(i) = min(x,const(i));
      x = x-N(i);
      mp = mp+N(i);
      i = i+1;
    endwhile

    ## here the configuration is filled. add it to the set of mixes
    assert( sum(N), k );
    pop_mix = [pop_mix; N]; ## FIXME: pop_mix is continuously resized

    ## advance to the next feasible configuration
    i = 1;
    sw = true;
    while sw
      if ( ( mp==k || N(i)==const(i)) && ( i<R ) )
        mp = mp-N(i);
        N(i) = 0;
        i=i+1;
      else
        N(i)=N(i)+1;
        mp=mp+1;
        sw = false;
      endif
    endwhile
  endwhile
endfunction
%!test
%! N = [2 3 4];
%! f = qncmpopmix( 1, N );
%! assert( f, [1 0 0; 0 1 0; 0 0 1] );
%! f = qncmpopmix( 2, N );
%! assert( f, [2 0 0; 1 1 0; 0 2 0; 1 0 1; 0 1 1; 0 0 2] );
%! f = qncmpopmix( 3, N );
%! assert( f, [2 1 0; 1 2 0; 0 3 0; 2 0 1; 1 1 1; 0 2 1; 1 0 2; 0 1 2; 0 0 3] );

%!test
%! N = [2 1];
%! f = qncmpopmix( 1, N );
%! assert( f, [1 0; 0 1] );
%! f = qncmpopmix( 2, N );
%! assert( f,  [2 0; 1 1] );

