%% Copyright (c) 2010 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
%% @deftypefn {Function File} {[ @var{opts}, @var{desc}] =} setpendulum ()
%% Returns the required options structure for the function pendulum and a
%% description of the fields in the structure.
%%
%% @seealso{pendulum}
%% @end deftypefn

function [opt desc] = setpendulum(varargin)

required_fields = {'Coefficients','Damping'};
reqf_default = {1;0};
reqf_description = {['Ration (g/l), relation between gravity and length of the pendulum'];...
         ['Damping coefficient, damping is proportional to angular speed.']};

optional_fields = {'Actuation'};
optf_description = {['Optional field. It defines the forcing function (source)'...
 "f(t,q,q'). It can be a handle to a function of the form f = func(t,x,opt)" ...
 'or it can be a 1xnT array.']};

opt = cell2struct(reqf_default,required_fields,1);

if nargout > 1
    cell1 = {reqf_description{:},optf_description{:}}';
    cell2 = {required_fields{:},optional_fields{:}};
    desc = cell2struct(cell1,cell2,1);
end
endfunction
