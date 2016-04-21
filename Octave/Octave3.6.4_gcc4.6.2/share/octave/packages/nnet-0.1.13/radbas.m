## Copyright (C) 2009 Luca Favatella <slackydeb@gmail.com>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} radbas (@var{n})
## Radial basis transfer function.
##
## @code{radbas(n) = exp(-n^2)}
##
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 0.1

function retval = radbas (n)

  if (nargin != 1)
    print_usage ();
  else
    retval = exp (-n^2);
  endif
endfunction


%!assert (radbas (3), exp (-3^2));
