## Copyright (C) 2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} isequal (@var{x1}, @var{x2}, @dots{})
## Return true if all of @var{x1}, @var{x2}, @dots{} are equal.
## @seealso{isequalwithequalnans}
## @end deftypefn

function t = isequal(x,varargin)
  if nargin < 2
    usage("isequal(x,y,...)");
  endif

  for arg = 1:length(varargin)
    y = varargin{arg};
    t = all (x (:) == y (:));
    if !t, return; endif
  endfor
endfunction
