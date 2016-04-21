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
## @deftypefn {Function File} {} @var{net} = __setx (@var{net},@var{X2})
## @code{__setx} sets the new weights to the neural network structure
## @end deftypefn

## @seealso{getx}

## Author: Michel D. Schmid

function net = __setx(net,xx)

  ## check number of inputs
  error(nargchk(2,2,nargin));

  ## check input args
  ## check "net", must be a net structure
  if !__checknetstruct(net)
    error("Structure doesn't seem to be a neural network")
  endif

  ## inputs
  [nRows, nColumns] = size(net.IW{1,1});
  nElementsIW = nRows*nColumns;
  net.IW{1,1}(:) = xx(1:nElementsIW);

  [nRows, nColumns] = size(net.b{1,1});
  nElementsB1 = nRows*nColumns;
  net.b{1,1}(:) = xx(1+nElementsIW:nElementsIW+nElementsB1);
  start = nElementsIW + nElementsB1;

  ## layers
  nLayers = net.numLayers;
  for i = 2:nLayers
    [nRows, nColumns] = size(net.LW{i,i-1});
    nElementsLW = nRows*nColumns;
    net.LW{i,i-1}(:) = xx(1+start:start+nElementsLW);

    [nRows, nColumns] = size(net.b{i,1});
    nElementsBx = nRows*nColumns;
    net.b{i,1}(:) = xx(1+start+nElementsLW:start+nElementsLW+nElementsBx);
    start = start + nElementsLW + nElementsBx;
  endfor

endfunction