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
%% @deftypefn {Function File} {@var{f1},@var{f2}} = demofunc2 (@var{x1},@var{x2},@var{v1},@var{v2})
%% function used in demos.
%%
%% @end deftypefn

function [f1 f2] = demofunc2 (x1,x2,v1,v2)
   f1 = -15 *((x1-x2) + 0.2) -0.7*(v1-v2);
   f2 = -f1;
end

