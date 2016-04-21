## Copyright (C) 2005 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
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
## @deftypefn {Function File} {}@var{perf} = __mse (@var{E})
## @code{__mse} returns the Mean-Square-Error of a vector E
##
## @example
##
## This function is used to calculate the network performance
## @end example
##
## @end deftypefn

## @seealso{__mae}

## Author: Michel D. Schmid

function perf = __mse(E)

  ## check number of inputs
  error(nargchk(1,1,nargin));

  if iscell(E)
    perf = 0;
    elements = 0;
    for i=1:size(E,1)
      for j=1:size(E,2)
        perf = perf + sum(sum(E{i,j}.^2));
        elements = elements + prod(size(E{i,j}));
      endfor
    endfor
    perf = perf / elements;
  else
    error("Error vector should be a cell array!")
  endif


endfunction