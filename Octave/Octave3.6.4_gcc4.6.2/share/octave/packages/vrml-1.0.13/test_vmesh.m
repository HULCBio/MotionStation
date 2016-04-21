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

###key test_vmesh
##
## Test vmesh.m

printf ("test_vmesh : \nDisplay a surface.\n");

R = 41;
C = 26;

[x,y] = meshgrid (linspace (-1,1,C), linspace (-1,1,R));

z = (cos (x*2*pi) + y.^2)/3;

vmesh (z);
printf ("Press a key.\n"); pause;


printf ("The same surface, with holes in it.\n");

z(3,3) = nan;			# Bore a hole
				# Bore more holes
z(1+floor(rand(1,5+R*C/30)*R*C)) = nan;

				# Try texture as a file, an "ims" or a
				# matrix. 
## tex = "octave-mylib/tools/imgio/test_images/test_col.xpm";
## tex = ims_load ("octave-mylib/tools/imgio/test_images/test_col.jpg");
## tex = kron (ones (4),eye(2));

vmesh (z);

printf ("Press a key.\n"); pause;

printf (["The same surface, with checkered stripes ",\
	 "(see the 'checker' option).\n"]);

vmesh (z,"checker",-[6,5]);

printf ("Press a key.\n"); pause;

printf (["The same surface, with z-dependent coloring (see 'zrb', 'zgrey'\n",\
	 "  and 'zcol' options)\n"]);

vmesh (z,"zrb");

printf ("That's it!\n");



