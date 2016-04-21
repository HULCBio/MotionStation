## Copyright (C) 2002-2009 Etienne Grossmann <etienne@egdn.net>
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
	 "    VRML Mini-HOWTO's first listing\n",\
	 "    Display a quadratic surface w/ 31 x 31 points\n\n"]);

printf (["    Reminder of FreeWRL keystrokes and mouse actions :\n"\
	 "      q : quit\n",\
	 "      w : switch to walk mode\n",\
	 "      e : switch to examine mode\n",\
	 "      h : toggle headlights on or off\n",\
	 "      drag left mouse : rotate (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "      drag right mouse : zoom (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "\n"]);

## Listing 1

x = linspace (-1,1,31);

[xx,yy] = meshgrid (x,x);

zz = xx.^2 + yy.^2;

vmesh (zz);

## Variant of listing 1

printf ("    Hit a key to see the variant of listing 1\n\n");

pause

vmesh (zz,"checker",[5,-2],"col",[1 0 0;0.7 0.7 0.7]', "emit",0);

vmesh (zz,"checker",[5,-2],"col",[1 0 0;0.7 0.7 0.7]', "emit",0);

printf ("    Another one, just with 7 x 7 points\n");

x = linspace (-1,1,7);

[xx,yy] = meshgrid (x,x);

zz = 2 - xx.^2 - yy.^2;

printf ("    Now, with steps, then barss\n");

vmesh (zz);

vmesh (zz,"steps");

vmesh (zz,"bars");
