## Copyright (C) 2005-2012 Etienne Grossmann <etienne@egdn.net>
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

## s = vrml_anim (typ, val, eventin, time)
##
## Assemble 
## - an interpolator of type typ, with values val
## - a TimeSensor with period time
## and route the event to eventin
## 
function [s,tname] = vrml_anim (typ, val, eventin, key, period)

if nargin < 4, key = [0 1]; end
if nargin < 5, period = 5; end

iname = vrml_newname ();

si = vrml_interp (typ, val,"key",key, "DEF",iname);
if isnumeric (period)
  tname = vrml_newname ();
  st = vrml_TimeSensor ("cycleInterval",period,"loop",1,"DEF",tname);

else				# Use previously declared TimeSensor
  tname = period;
  st = "";
end

sr = vrml_ROUTE ([tname,".fraction_changed"],[iname,".set_fraction"]);
sr2 = vrml_ROUTE ([iname,".value_changed"],eventin);

s = [si, st, sr, sr2];
endfunction

