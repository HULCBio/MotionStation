## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

function shapet = shapetranslate (shape, v);

  shapet = cellfun(@(x)polytranslate(x,v), shape, 'UniformOutput', false);

endfunction

function pp = polytranslate(polynom,v)
  pp = polynom;
  pp(:,end) = pp(:,end) + v(:);
endfunction
