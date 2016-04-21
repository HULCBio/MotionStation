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
## @deftypefn {Function File} {} __printOutputConnect (@var{fid})
## @code{printMLPHeader} saves the header of a  neural network structure
## to a *.txt file with identification @code{fid}.
## @end deftypefn

## Author: Michel D. Schmid

function __printOutputConnect(fid,net)

  if isfield(net,"outputConnect")
    # net.outputConnect can be a matrix..!
    # check if it's a matrix
    if isscalar(net.outputConnect)
      error("unsure if this is possible..")
    elseif isnumeric(net.outputConnect)
      if ismatrix(net.outputConnect)
        if issquare(net.outputConnect)
          fprintf(fid,"       outputConnect:  [");
          [nRows nColumns] = size(net.outputConnect);
          for k = 1:1:nRows
            for i = 1:1:nColumns
              if i<nColumns
                fprintf(fid,"%d ",net.outputConnect(i*k));
              else
                fprintf(fid,"%d",net.outputConnect(i*k));
              endif
            endfor
            if k!=nRows
              #print ; for newline in matrix
              fprintf(fid,";");
            endif
          endfor
          # print last bracket
          fprintf(fid,"]\n");
        elseif isvector(net.outputConnect)
          # insert enough spaces to put ":" to position 20
          # insert 2 spaces for distance between ":" and "%"
          # print bracket for open
          fprintf(fid,"       outputConnect:  [");
          [nRows nColumns] = size(net.outputConnect);
             for k = 1:1:nRows
               for i = 1:1:nColumns
                 if (i<nColumns)
                   fprintf(fid,"%d ",net.outputConnect(i*k));
                 else
                   fprintf(fid,"%d",net.outputConnect(i*k));
                 endif
               endfor
               if k!=nRows
                 #print ; for newline in matrix
                 fprintf(fid,";");
               endif
             endfor
             # print last bracket
             fprintf(fid,"] not yet used item\n");
           endif  # if issquare..
         endif #if ismatrix
      endif
    else
      fprintf(fid," ERROR...");
    endif

endfunction