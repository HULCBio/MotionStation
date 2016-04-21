## Copyright (C) 2006 Michel D. Schmid <michaelschmid@users.sourceforge.net>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} __printAdaptFcn (@var{fid})
## @code{printMLPHeader} saves the header of a  neural network structure
## to a *.txt file with identification @code{fid}.
## @end deftypefn

## Author: Michel D. Schmid

function __printAdaptFcn(fid,net)

  if isfield(net,"adaptFcn")
    if isempty(net.adaptFcn)
      fprintf(fid,"            adaptFcn:  '%s'\n","empty");
    else
      fprintf(fid,"            adaptFcn:  '%s'\n",net.adaptFcn);
    endif
  endif

endfunction
