%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{vals} =} getlist(@var{cgi},@var{name})
%% Returns all CGI parameters with the given name. The object @var{cgi} was 
%% created using the cgi() constructor. @var{vals} is a cell array of strings.
%% @end deftypefn
%% @seealso{cgi,@@cgi/getfirst}

function vals = getlist(cgi,name)

i = find(strcmp(cgi.params,name));
vals = cgi.vals(i);


% Copyright (C) 2012 Alexander Barth <barth.alexander@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; If not, see <http://www.gnu.org/licenses/>.