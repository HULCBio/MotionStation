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
## @deftypefn {Function File} {@var{vec}} = ind2vec (@var{ind})
## @code{vec2ind} convert indices to vector
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

## @seealso{vec2ind}

function [vector]=ind2vec(ind)
  # Converts indices to vectors
  #
  #
  vectors = length(ind);
  vector = sparse(ind,1:vectors,ones(1,vectors));
endfunction
