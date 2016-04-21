## Copyright (C) 2008 Grzegorz Timoszuk <gtimoszuk@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.
##

## -*- texinfo -*-
## @deftypefn {Function File} {} @var{err} = system_dependent (@var{property}, @var{value})
## This function is intentionally left undocumented. 
## @end deftypefn

function err = system_dependent(property, value)
err = -1;
switch property
# the interface for "setround" and "setprecision" follows 
# the examples from W.Kahan's article
# http://www.cs.berkeley.edu/~wkahan/Mindless.pdf
case "setround"
	err = fesetround(value);
case "setprecision"
	err = fesetprec(value);
otherwise
	err = -1;
endswitch
endfunction
