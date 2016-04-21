## Copyright (C) 2002 Etienne Grossmann <etienne@egdn.net>
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

##  p = vrml_kill ()            - Kill the current vrml browser
## 
## If a vrml browser has previously been launched with vrml_browse(), it
## will be sent a KILL signal.
##
## See also : vrml_browse.

function p = vrml_kill ()

global vrml_b_pid = 0;

if vrml_b_pid, 
  printf ("vrml_browse : Sending kill signal to browser\n");
  system (sprintf ("kill -KILL %d &> /dev/null",vrml_b_pid));
else
  printf ("vrml_browse : No live browser to kill\n");
end
vrml_b_pid = 0;
return
endfunction

