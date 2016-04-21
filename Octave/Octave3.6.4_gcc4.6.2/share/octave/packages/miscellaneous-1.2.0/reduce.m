## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{x} =} reduce (@var{function}, @var{sequence},@var{initializer})
## @deftypefnx {Function File} {@var{x} =} reduce (@var{function}, @var{sequence})
## Implements the 'reduce' operator like in Lisp, or Python.
## Apply function of two arguments cumulatively to the items of sequence, 
## from left to right, so as to reduce the sequence to a single value. For example,
## reduce(@@(x,y)(x+y), [1, 2, 3, 4, 5]) calculates ((((1+2)+3)+4)+5).
## The left argument, x, is the accumulated value and the right argument, y, is the 
## update value from the sequence. If the optional initializer is present, it is 
## placed before the items of the sequence in the calculation, and serves as
## a default when the sequence is empty. If initializer is not given and sequence
## contains only one item, the first item is returned.
##
## @example
##  reduce(@@add,[1:10])
##  @result{} 55
##      reduce(@@(x,y)(x*y),[1:7]) 
##  @result{} 5040  (actually, 7!)
## @end example
## @end deftypefn

## Parts of documentation copied from the "Python Library Reference, v2.5"

function rv = reduce (func, lst, init)
  if (nargin < 2) || nargin > 3 || (class(func)!='function_handle') || (nargin == 2 && length(lst)<2)
    print_usage();
  end

  l=length(lst);

  if (l<2 && nargin==3)
    if(l==0)
      rv=init;
    elseif (l==1)
      rv=func(init,lst(1));
    end
    return;
  end

  if(nargin == 3)
    rv=func(init,lst(1));
    start=2;
  else
    rv=func(lst(1),lst(2));
    start=3;
  end

  for i=start:l
    rv=func(rv,lst(i));
  end
end

%!assert(reduce(@(x,y)(x+y),[],-1),-1)
%!assert(reduce(@(x,y)(x+y),[+1],-1),0)
%!assert(reduce(@(x,y)(x+y),[-10:-1]),-55)
%!assert(reduce(@(x,y)(x+y),[-10:-1],+55),0)
%!assert(reduce(@(x,y)(y*x),[1:4],5),120)
