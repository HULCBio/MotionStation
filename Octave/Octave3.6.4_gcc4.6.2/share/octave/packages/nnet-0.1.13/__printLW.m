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
## @deftypefn {Function File} {} __printLW (@var{fid})
## @code{printMLPHeader} saves the header of a  neural network structure
## to a *.txt file with identification @code{fid}.
## @end deftypefn

## Author: Michel D. Schmid

function __printLW(fid,net)

  if isfield(net,"LW")
    nLayers = 0;
    # check if it's cell array
    if iscell(net.LW)
      [nRows, nColumns] = size(net.LW);
      for i=1:nRows
        for k=1:nColumns
          if !isempty(net.LW{i,k})
            nLayers = nLayers+1;
          endif
        endfor
      endfor
      # insert enough spaces to put ":" to position 20
      # insert 2 spaces for distance between ":" and "%"
      fprintf(fid,"                  LW: {%dx%d cell} containing %d layer weight matrix\n",nRows,nColumns,nLayers);
    else
      fprintf(fid,"unsure if this is possible\n");
    endif
  endif

endfunction