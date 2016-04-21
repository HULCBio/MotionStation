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
%% @deftypefn {Function File} {@var{R} = } quat2mat (@var{q})
%% This function is implemented in the quaternion package and will be deprecated.
%% @end deftypefn

function R = quat2mat (q)

R = [ q(1)^2+q(2)^2-q(3)^2-q(4)^2  2*(q(2)*q(3)-q(1)*q(4))  2*(q(2)*q(4) + q(1)*q(3)); ...
      2*(q(2)*q(3)+q(1)*q(4))   q(1)^2-q(2)^2+q(3)^2-q(4)^2  2*(q(3)*q(4) - q(1)*q(2)); ...
      2*(q(2)*q(4)-q(1)*q(3))   2*(q(3)*q(4)+q(1)*q(2))  q(1)^2-q(2)^2-q(3)^2+q(4)^2 ];

endfunction
