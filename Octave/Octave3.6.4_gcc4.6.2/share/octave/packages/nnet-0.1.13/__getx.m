## Copyright (C) 2005 Michel D. Schmid     <michaelschmid@users.sourceforge.net>
##
##
## This program  is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program  is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program ; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} @var{x} = __getx (@var{net})
## @code{__getx} will rerange the weights in one columns vector.
##
##
## @noindent
## @end deftypefn


## Author: Michel D. Schmid

function x = __getx(net)

  ## check number of inputs
  error(nargchk(1,1,nargin));

  ## check input args
  ## check "net", must be a net structure
  if !__checknetstruct(net)
    error("Structure doesn't seem to be a neural network")
  endif

  ## inputs
  x = net.IW{1,1}(:);
  x = [x; net.b{1}(:)];

  nNumLayers = net.numLayers;
  for iLayers = 2:nNumLayers # 1 would be the input layer

    ## layers
    x = [x; net.LW{iLayers,iLayers-1}(:)];
    x = [x; net.b{iLayers}(:)];

  endfor


endfunction