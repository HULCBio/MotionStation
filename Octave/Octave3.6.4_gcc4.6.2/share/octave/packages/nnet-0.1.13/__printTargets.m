## Copyright (C) 2006 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
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
## @deftypefn {Function File} {} __printTargets (@var{fid})
## @code{printMLPHeader} saves the header of a  neural network structure
## to a *.txt file with identification @code{fid}.
## @end deftypefn

## Author: Michel D. Schmid 

function __printTargets(fid,net)

  if isfield(net,"targets")
    # check if it's cell array
    if iscell(net.targets)
      [nRows, nColumns] = size(net.targets);
      # insert enough spaces to put ":" to position 20
      # insert 2 spaces for distance between ":" and "%"
      fprintf(fid,"             targets: {%dx%d cell} containing %d targets\n",nRows,nColumns,net.numTargets);
    else
      fprintf(fid,"unsure if this is possible\n");
    endif
  endif

endfunction