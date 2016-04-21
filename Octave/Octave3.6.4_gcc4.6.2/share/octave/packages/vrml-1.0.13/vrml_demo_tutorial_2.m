## Copyright (C) 2002-2012 Etienne Grossmann <etienne@egdn.net>
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

printf("vrml_select_points does not work any more. Sorry\n");
return

printf (["\n",\
	 "     VRML Mini-HOWTO's second listing\n",\
	 "     Show 3D points and select some with the mouse\n\n"]);

printf (["    Reminder of FreeWRL keystrokes and mouse actions :\n"\
	 "      q : quit\n",\
	 "      w : switch to walk mode\n",\
	 "      e : switch to examine mode\n",\
	 "      drag left mouse : rotate (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "      drag right mouse : zoom (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "      click on box : toggle selection\n",\
	 "\n"]);

## Listing 2

N = 30;

x = [randn(3,N) .* ([1,3,6]'*ones(1,N)), [5 5;-1 1;0 0]];

s = select_3D_points (x);

printf ("The selected points are : \n");
s


