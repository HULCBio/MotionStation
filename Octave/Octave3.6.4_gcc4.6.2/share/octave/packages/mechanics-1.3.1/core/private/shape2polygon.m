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

function polygon = shape2polygon (shape, N=16)

  polygon = cell2mat ( ...
             cellfun(@(x) func (x,N), shape,'UniformOutput',false) );

endfunction

function y = func(x,N)

  if size(x,2) > 2
    t = linspace(0,1-1/N,N).';
    y(:,1) = polyval(x(1,:),t);
    y(:,2) = polyval(x(2,:),t);
  else
    y = x(:,2).';
  end

endfunction

