## Copyright (C) 2003 Tomer Altman <taltman@lbl.gov>
## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
## Copyright (C) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
## @deftypefn{Function File} {@var{result} =} map (@var{function}, @var{iterable}, @dots{})
## Apply @var{function} to every item of @var{iterable} and return the results.
##
## @code{map}, like Lisp's ( & numerous other language's ) function for
## iterating the result of a function applied to each of the data
## structure's elements in turn. The results are stored in the
## corresponding input's place. For now, just will work with cells and
## matrices, but support for structs are intended for future versions.
## Also, only "prefix" functions ( like @code{min (a, b, c, ...)} ) are
## supported. FUN_HANDLE can either be a function name string or a
## function handle (recommended).
##
## Example:
## @example
##
## octave> A
## A
## @{
##   [1,1] = 0.0096243
##   [2,1] = 0.82781
##   [1,2] = 0.052571
##   [2,2] = 0.84645
## @}
## octave> B
## B =
## @{
##   [1,1] = 0.75563
##   [2,1] = 0.84858
##   [1,2] = 0.16765
##   [2,2] = 0.85477
## @}
## octave> map(@@min,A,B)
## ans =
## @{
##   [1,1] = 0.0096243
##   [2,1] = 0.82781
##   [1,2] = 0.052571
##   [2,2] = 0.84645
## @}
## @end example
## @seealso{reduce, match}
## @end deftypefn

function return_type = map (fun_handle, data_struct, varargin)

  persistent warned = false;
  if (! warned)
    warned = true;
    warning ("Octave:deprecated-function",
             "map has been deprecated, and will be removed in the future. Use `arrayfun' or `cellfun' instead.");
  endif

  if (nargin < 2)
    print_usage;
  elseif (!(isnumeric (data_struct) || iscell (data_struct)))
    error ("second argument must be either a matrix or a cell object");
  endif

  if (isa (fun_handle, "function_handle"))
    ##do nothing
  elseif (ischar (fun_handle))
    fun_handle = str2func (fun_handle);
  else
    error ("fun_handle must either be a function handle or the name of a function");
  endif

  if (iscell (data_struct))
    return_type = cellfun (fun_handle, data_struct,varargin{:});
  else
    return_type = arrayfun (fun_handle, data_struct,varargin{:});
  endif

endfunction

%!assert(map(@min,[1 2 3 4 5],[5 4 3 2 1]), [1 2 3 2 1])
%!assert(map(@min,rand(1,5),[0 0 0 0 0]), [0 0 0 0 0])
%!assert(map(@(x,y) (sin(x).^2 + cos(y).^2),-pi:0.5:+pi,-pi:0.5:+pi),ones(1,13))
