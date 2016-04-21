%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{val} =} has(@var{cgi},@var{name})
%% Returns true if a CGI parameter with the given name exists (otherwise false).
%% @end deftypefn
%% @seealso{cgi,@@cgi/getlist}

function val = has(cgi,name)

val = ~isempty(getlist(cgi,name));



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
