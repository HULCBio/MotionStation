## Copyright (C) 2007, Muthiah Annamalai <muthiah.annamalai@uta.edu>
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
## @deftypefn {Loadable Function} {@var{return_value} =} apply (@var{@@function_handle},@var{cell_array_of_args})
## @deftypefnx {Loadable Function} {@var{return_value} =} apply (@var{@@function_handle})
## Apply calls the function @var{function_handle} with the arguments of the cell
## array @var{cell_array_of_args} which contains the actual arguments arg1,arg2,..., argn
## to the function, in that order. Apply invokes the function as
## @var{function_handle}(arg1, arg2, ... ,argn), where the arguments are 
## extracted from each elements of the 1-row cell array @var{cell_array_of_args}. 
##
## @emph{warning}: @code{apply} has been deprecated in favor of @code{arrayfun}
## and @code{cellfun} for arrays and cells respectively. This function will be
## removed from future versions of the 'miscellaneous' package".
##
## Apply also works on array of function handles if
## @var{function_handle} is passed as a cell array of a handles; in this
## case apply, evaluates each function (using the handle) with the same
## arguments.
##
## The cell-array argument is optional second argument, in the form
## of a 1-row with multiple elements. The elements of the cell-array 
## form the actual arguments supplied when invoking the  function @var{function_handle}.
##
## The return value depends on the function invoked, and the validity of
## the arguments.
##
## @example
##   z=apply(@@sqrt,cell([1,2; 3,4]));
##   z=apply(@@apply,cell(@@sqrt,cell([1,2; 3,4])));
##   apply(@@sum,cell([1,2,3,4]))
##   apply(@@max,cell([1,2,3,4]))
##   apply(@@min,cell([1,2,3,4]))
## @end example
##
##
## In first case, apply computes the sqrt of the matrix [1,2; 3,4];
## The second example is meta-apply, using apply on itself.
## The rest of the examples invoke sum, max, min respectively.
## @end deftypefn
##

function rval=apply(fun_handle,cell_array)

  persistent warned = false;
  if (! warned)
    warned = true;
    warning ("Octave:deprecated-function",
             "apply has been deprecated, and will be removed in the future. Use `arrayfun' or `cellfun' instead.");
  endif

  if (nargin == 0)
    print_usage();
    error("apply(): needs at least 1 argument, see usage");
  elseif( nargin < 2)
    if iscell(fun_handle)
      for idx=1:length(fun_handle)
        rval(idx)=feval(@feval,fun_handle{idx});
      end
    else
      rval=feval(@feval,fun_handle);
    end
    return
  elseif(!iscell(cell_array))
    error("apply(): needs second argument, to be a cell-array");
  end

  
  if iscell(fun_handle)
    for idx=1:length(fun_handle)
      rval(idx)=feval(@feval,fun_handle{idx},cell_array{:});
    end
    return
  end

  rval=feval(@feval,fun_handle,cell_array{:});
end
%!
%!assert(apply({@min, @max, @mean},{[1:10]}),[ 1.0000 ,10.0000 ,5.5000])
%!assert(apply(@min,{[1,2,3,4]}),1)
%!assert(apply(@dot,{[1,2],[3,4]}),11)
%!assert(apply(@min,{[1, 3]}),1)
%!assert(apply(@sum,{[1:10]}),55)
%!assert(apply(@sqrt,{[1,2; 3,4]}),sqrt([1,2;3,4]))
%!assert(apply(@apply,{@sqrt,{[1,2; 3,4]}}),sqrt([1,2;3,4]))
%!assert(apply(@sum,{[1,2,3,4]}),10)
%!assert(apply(@max,{[1,2,3,4]}),4)
%!assert(apply(@min,{[1,2,3,4]}),1)
%!
