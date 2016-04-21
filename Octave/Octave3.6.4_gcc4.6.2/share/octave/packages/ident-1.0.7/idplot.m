## Copyright (C) 2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} idplot (@var{z}, @var{idx}, @var{dT}, @var{outputs}, @var{shape})
## 
## Plot inputs and ouputs defined by the system @var{z}. Other inputs are 
## optional.
## @end deftypefn
## @seealso{idsim}

function idplot(z, idx, dT, outputs, shape)

  if nargin<1 || nargin>5
    usage("y = idplot(z, idx, dT, outputs, shape)");
  endif
  if nargin<2 || isempty(idx), idx = 1:size(z,1); endif
  if nargin<3 || isempty(dT), dT=1;endif
  if nargin<4 || isempty(outputs), outputs=1; endif
  if nargin<5 || isempty(shape), shape='pc'; endif

  subplot(211);
  title("system outputs");
  auplot(z(idx,1:outputs), 1/dT, idx(1)-1);
  subplot(212);
  title("system inputs");
  auplot(z(idx,outputs+1:size(z,2)), 1/dT, idx(1)-1);
  title("");
  subplot(111);
end
