## Copyright (C) 2004 Josep Mones i Teixidor
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
## @deftypefn {Function File} {@var{B} = } blkproc (@var{A}, [@var{m},@var{n}], @var{fun})
## This function has been deprecated. Please use @code{blockproc} instead which
## has exactly the same syntax.
## @end deftypefn

function B = blkproc(A, varargin)
  persistent warned = false;
  if (! warned)
    warned = true;
    warning ("Octave:deprecated-function",
             "blkproc has been deprecated, and will be removed from future versions of the image package. Please use blockproc instead.")
  endif
  B = blockproc (A, varargin);
endfunction
