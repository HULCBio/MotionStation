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
## @deftypefn {Function File} {} __printNumLayers (@var{fid})
## @code{printMLPHeader} saves the header of a  neural network structure
## to a *.txt file with identification @code{fid}.
## @end deftypefn

## Author: Michel D. Schmid

function __printNumLayers(fid,net)

     if isfield(net,"numLayers")
        if isscalar(net.numLayers)
					 # insert enough spaces to put ":" to position 20
           # insert 2 spaces for distance between ":" and "%"
           fprintf(fid,"           numLayers:  %d\n",net.numLayers);
        # net.numLayers must be an integer... till now, 11-01-2006
        else
            error("numLayers must be a scalar value!");
        endif
     endif
     
endfunction