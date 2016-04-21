## Copyright (C) 2008-2012 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Loadable Function} {[@var{prog}, @var{args}] =} gnuplot_binary ()
## @deftypefnx {Loadable Function} {[@var{old_prog}, @var{old_args}] =} gnuplot_binary (@var{new_prog}, @var{arg1}, @dots{})
## Query or set the name of the program invoked by the plot command
## when the graphics toolkit is set to "gnuplot".  Additional arguments to
## pass to the external plotting program may also be given.
## The default value is @code{"gnuplot"} without additional arguments.
## @xref{Installation}.
## @end deftypefn

## Author: jwe

function [prog, args] = gnuplot_binary (new_prog, varargin)

  persistent gp_binary = "gnuplot";
  persistent gp_args = {};

  if (nargout > 0 || nargin == 0)
    prog = gp_binary;
    args = gp_args;
  endif

  if (nargin == 1)
    if (ischar (new_prog))
      if (! isempty (new_prog))
	gp_binary = new_prog;
      else
	error ("gnuplot_binary: value must not be empty");
      endif
    else
      error ("gnuplot_binary: expecting program to be a character string");
    endif
  endif

  if (nargin > 1)
    if (iscellstr (varargin))
      gp_args = varargin;
    else
      error ("gnuplot_binary: expecting arguments to be character strings");
    endif
  endif

endfunction
