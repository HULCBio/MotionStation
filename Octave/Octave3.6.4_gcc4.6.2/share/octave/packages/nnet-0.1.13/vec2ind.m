## Copyright (C) 2009 Luiz Angelo Daros de Luca <luizluca@gmail.com>
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
## @deftypefn {Function File} {@var{ind}} = vec2ind (@var{vector})
## @code{vec2ind} convert vectors to indices
##
##
## @example
## EXAMPLE 1
## vec = [1 2 3; 4 5 6; 7 8 9];
##
## ind = vec2ind(vec)
## The prompt output will be:
## ans = 
##    1 2 3 1 2 3 1 2 3
## @end example
##
## @end deftypefn

## @seealso{ind2vec}


function [ind]=vec2ind(vector)
  # Convert vectors to indices
  #
  #
  [ind,col,vals] = find(vector);
  ind=ind';
endfunction
