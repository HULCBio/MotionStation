%% Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{q} = } mat2quat (@var{R})
%% This function is implemented in paclage quaternions and will be deprecated.
%% @end deftypefn
function q = mat2quat(R)

  if all(R == eye(3))
    q = [1 0 0 0];
    return
  end

  %% Angle
  phi = acos((trace(R)-1)/2);

  %% Axis
  x = [R(3,2)-R(2,3) R(1,3)-R(3,1) R(2,1)-R(1,2)];
  x = x/sqrt(sumsq(x));

  q = [ cos(phi/2) sin(phi/2)*x];

endfunction
