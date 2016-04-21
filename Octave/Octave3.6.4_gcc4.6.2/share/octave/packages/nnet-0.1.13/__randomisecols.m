## Copyright (C) 2008 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
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
## @deftypefn {Function File} {} @var{retmatrix} = __randomisecols (@var{matrix})
## @code{__randomisecols} takes a matrix as input argument and changes the order
## of the columns. The rows aren't affected.
## @end deftypefn

## Author: mds

function [retmatrix] = __randomisecols(matrix)

  ## check number of inputs
  error(nargchk(1,1,nargin));

  # get number of cols
  nCols = size(matrix,2);
  
  # now create random column order
  colOrder = randperm(nCols);
  
  # now sort the matrix new
  retmatrix = matrix(:,[colOrder]);


endfunction

%!# no test possible, contains randperm which is using
%!# some randome functions
