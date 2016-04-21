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
%% @deftypefn {Function File} {@var{f},@var{v}} = lennardjones (@var{dx},@var{r02},@var{v0})
%% Returns force and energy of the Lennard-Jonnes potential evaluated at @var{dx}.
%%
%% @end deftypefn

function [f V] = lennardjones (dx,r02,V0)

  r2 = sumsq(dx,2);
  dr = dx ./ r2;

  rr3 = (r02 ./ r2).^3;
  rr6 = rr3.^2;

  V = V0 * ( rr6 - 2*rr3 );

  f = bsxfun(@times, 12 * V0 * ( rr6 - rr3 ), dr);

end
