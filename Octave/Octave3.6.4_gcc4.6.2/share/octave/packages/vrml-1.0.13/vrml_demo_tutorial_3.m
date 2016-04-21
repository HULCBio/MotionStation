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

printf (["\n",\
	 "     VRML Mini-HOWTO's second listing\n",\
	 "     Show a XYZ frame with a background\n\n"]);

printf (["    Reminder of FreeWRL keystrokes and mouse actions :\n"\
	 "      q : quit\n",\
	 "      w : switch to walk mode\n",\
	 "      e : switch to examine mode\n",\
	 "      drag left mouse : rotate (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "      drag right mouse : zoom (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "\n"]);

## Listing 3

s1 = vrml_frame ("scale",[1 2 3],"col",eye (3), "hcol",0.5*[1 1 1]);

## One possible variant that uses a two-color sky. I don't refer to it in
## the tutorial because I am not sure that freewrl behaves correctly with
## background nodes.

## s2 = vrml_Background ("skyColor",[3 3 9; 9 9 9]'/10,"groundColor",[3 8 3]/10);
s2 = vrml_Background ("skyColor",[3 3 9]/10,"groundColor",[3 8 3]/10);

vrml_browse ([s1,s2]);






