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

## Test that vrml_faces works with "tex" option

1;

## Tetrahedron : Vertices
x = [ 1  1 -1  0;
     -1  1  0  0;
     -1 -1 -1  1];

## Tetrahedron : Faces
trg = [1 2 3 1;
       2 3 1 2;
       4 4 4 3];

trgl = {[1 2 4],[2 3 4],[3 1 4],[1 2 3]};

slight = vrml_PointLight ("location", [0,5,0]);

if 1
  s1 = vrml_faces (x, trg);

  printf ("Going to show a tetrahedron\n");

  printf (["\n     If nothing appears, it may be due to problems",\
	   "\n     with your FreeWRL installation\n"]);
  vrml_browse ([slight, s1]);
  printf ("Press a key in this terminal when done\n");pause;
end

if 1
  s1 = vrml_faces (x, trgl,"col",[1,0.5,0.5]);

  printf ("Going to show almost the same tetrahedron\n");

  printf (["\n     If nothing appears, it may be due to problems",\
	   "\n     with your FreeWRL installation\n"]);
  vrml_browse ([slight, s1]);
  printf ("Press a key in this terminal when done\n");pause;
end

if 1
  s1 = vrml_faces (x, trg, "col",[1 0 0 1;0 1 0 1;0 0 1 1]);

  printf ("Coloring the vertices\n");
  vrml_browse ([slight, s1]);
  printf ("Press a key in this terminal when done\n");pause;
end
if 1
  s1 = vrml_faces (x, trg, "col",[1 0 0 1;0 1 0 1;0 0 1 1],"colorPerVertex",0);

  printf ("Coloring the faces\n");
  vrml_browse ([slight, s1]);
  printf ("Press a key in this terminal when done\n");pause;
end

## Texture :
H = 50;
W = 100;			# Texture width
w = floor (W/2);
h = floor (H/2);
tr = tg = tb = zeros (H,W+1);
[j,i] = meshgrid (1:W+1,1:H);

tr(find (i<=h & i*W>=j*H       )) = 1;
tg(find (i> h & i*W>=(j+w)*H     )) = 1;
tb(find (i> h & i*W>=j*H     & j> w)) = 1;


if 0

  if 1
    whiten = find(!(tr | tg | tb));
    tr(whiten) = 1;
    tg(whiten) = 1;
    tb(whiten) = 1;
  end
  
  t0 = reshape (255*[tr;tg;tb], H,(W+1)*3);
  t0 = t0 + 0.75 * rot90 (t0,2);
  t0 = [t0, 0.5*t0];
  tex = mat2ims (t0,1);

## ims_show (tex);


  texfile = [pwd(),"/mytexfile.ppm"];
  ims_save (tex, texfile);

  s1 = vrml_faces (x, trg, "tex",texfile,"imsz",[H,W]);
  s2 = vrml_faces (x, trg, "tex",texfile);

  printf (["Tetrahedrons should appear like (R=red, G=green, B=blue)\n\n",\
	   "              R 2\n",\
	   "               /\n",\
	   "              / G\n",\
	   "     G     B /\n",\
	   "   3--------4 B\n",\
	   "     R     B \\\n",\
	   "              \\ R\n",\
	   "             G \\\n",\
	   "                 1\n"]);
  
  vrml_browse ([slight, s1, vrml_transfo(s2,[2,0,0])]);
end






