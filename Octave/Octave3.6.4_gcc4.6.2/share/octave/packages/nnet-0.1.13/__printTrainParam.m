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
## @deftypefn {Function File} {} __printTrainParam (@var{fid})
## @code{printMLPHeader} saves the header of a  neural network structure
## to a *.txt file with identification @code{fid}.
## @end deftypefn

## Author: Michel D. Schmid

function __printTrainParam(fid,net)

  if isfield(net,"trainParam")
    str2 = "";
    str3 = "";
    if isempty(net.trainParam)
      fprintf(fid,"          trainParam:  '%s'\n","not yet used item");
    else
      cellFieldNames = fieldnames(net.trainParam);
      [nRows, nColumns] = size(cellFieldNames);
      if (nRows<4)
      else
        for iRuns = 1:nRows
          if (iRuns==1)
            str1 =  ["." char(cellFieldNames(iRuns,1)) ", "];
          endif
          if (iRuns<=4 & iRuns>1)
            str1 = [str1 "." char(cellFieldNames(iRuns,1)) ", "];
          endif
          if (iRuns>4 & iRuns<=8)
            str2 = [str2 "." char(cellFieldNames(iRuns,1)) ", "];
          endif
          if (iRuns>8)
            str3 = [str3 "." char(cellFieldNames(iRuns,1)) ", "];
          endif
        endfor
        fprintf(fid,"          trainParam:  %s\n",str1);
        fprintf(fid,"                       %s\n",str2);
        fprintf(fid,"                       %s\n",str3);
      endif
    endif
  else
    fprintf(fid,"field trainparam not found\n");
  endif

endfunction