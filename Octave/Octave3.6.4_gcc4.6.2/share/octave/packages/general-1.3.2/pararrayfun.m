## Copyright (C) 2009 Jaroslav Hajek <highegg@gmail.com>
## Copyright (C) 2009 VZLU Prague, a.s., Czech Republic
## Copyright (C) 2009 Travis Collier <travcollier@gmail.com>
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
## @deftypefn{Function File} {[@var{o1}, @var{o2}, @dots{}] =} pararrayfun (@var{nproc}, @var{fun}, @var{a1}, @var{a2}, @dots{})
## @deftypefnx{Function File} {} pararrayfun (nproc, fun, @dots{}, "UniformOutput", @var{val})
## @deftypefnx{Function File} {} pararrayfun (nproc, fun, @dots{}, "ErrorHandler", @var{errfunc})
## Evaluates a function for corresponding elements of an array. 
## Argument and options handling is analogical to @code{parcellfun}, except that
## arguments are arrays rather than cells. If cells occur as arguments, they are treated
## as arrays of singleton cells.
## Arrayfun supports one extra option compared to parcellfun: "Vectorized".
## This option must be given together with "ChunksPerProc" and it indicates
## that @var{fun} is able to operate on vectors rather than just scalars, and returns
## a vector. The same must be true for @var{errfunc}, if given.
## In this case, the array is split into chunks which are then directly served to @var{func}
## for evaluation, and the results are concatenated to output arrays.
## @seealso{parcellfun, arrayfun}
## @end deftypefn

function varargout = pararrayfun (nproc, func, varargin)

  if (nargin < 3)
    print_usage ();
  endif

  [nargs, uniform_output, error_handler, ...
  verbose_level, chunks_per_proc, vectorized] = parcellfun_opts (varargin); 

  args = varargin(1:nargs);
  opts = varargin(nargs+1:end);
  if (nargs == 0)
    print_usage ();
  elseif (nargs > 1)
    [err, args{:}] = common_size (args{:});
    if (err)
      error ("pararrayfun: arguments size must match");
    endif
  endif

  njobs = numel (args{1});

  if (vectorized && chunks_per_proc > 0 && chunks_per_proc < njobs / nproc)
    ## If "Vectorized" is on, we apply the function directly on chunks of
    ## arrays.
    [varargout{1:nargout}] = chunk_parcellfun (nproc, chunks_per_proc, ...
    func, error_handler, verbose_level, args{:});
  else
    args = cellfun (@num2cell, args, "UniformOutput", false,
    "ErrorHandler",  @arg_class_error);

    [varargout{1:nargout}] = parcellfun (nproc, func, args{:}, opts{:});
  endif

endfunction

function arg_class_error (S, X)
  error ("arrayfun: invalid argument of class %s", class (X))
endfunction
