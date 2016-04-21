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

##        s = vrml_points(x,options)
## 
## x : 3xP  : 3D points
##
## Makes a vrml2 "point [ ... ]" node from a 3xP matrix x.
## 
## OPTIONS (name and size/type, if applicable):
## ---------------------------------------
## "balls"      : Displays spheres rather than points. Overrides the
##                "hide" options and no Coordinate node is defined;makes
##                "name" ineffective.
##
## "boxes" or
## "cubes"      : Displays cubes rather than points. Overrides the "hide"
##                options and no Coordinate node is defined;makes "name"
##                ineffective. 
##
## "rad", 1 or P: Radius of balls/size of cubes.              default = 0.1
##
## "nums"       : Displays numbers rather than points. Overrides the
##                "hide" options and no Coordinate node is defined;
##                makes "name" ineffective.
##
##       WARNING : This option seems to make freewrl 0.34 hang, so that it
##                 is necessary to kill it (do vrml_browse ("-kill")). Other
##                 browsers can can view the code produced by this option.
##
##  "col", 3x1  : Points will have RGB col.          default = [0.3,0.4,0.9]
##      or 3xP  : The color of each point.
##  "tran", 1x1 : Transparency                                   default = 0
##  "emit", e   : Use or not emissiveColor                       default = 1
##
## "name", str  : The Coordinate node will be called name
##                (default="allpoints").
## "hide"       : The points will be defined, but not showed.

function s = vrml_points(x,varargin)
## varargin
hide = 0;
cubes = balls = nums = 0;
rad = 0.1 ;
name = "allpoints" ;
col = [0.3 0.4 0.9];
emit = 1;
tran = 0;

i = 1; 			# pos 2.1.39

while i <= nargin-1

  tmp = varargin{i++};
  if strcmp(tmp,"hide") ,
    hide = 1;
  elseif strcmp(tmp,"balls") ,
    balls = 1;
  elseif strcmp(tmp,"cubes") || strcmp(tmp,"boxes") ,
    cubes = 1;
  elseif strcmp(tmp,"rad") ,

    rad = varargin{i++};
  elseif strcmp(tmp,"nums") ,
    nums = 1;
  elseif strcmp(tmp,"emit") ,

    emit = varargin{i++};
  elseif strcmp(tmp,"col") ,

    col = varargin{i++};
  elseif strcmp(tmp,"name") ,

    name = varargin{i++};
  elseif strcmp(tmp,"tran") ,
    tran = varargin{i++};
  end
end

if rows (x) != 3,
  if columns (x) == 3,
    x = x' ;
  else
    error ("vrml_points : input is neither 3xP or Px3\n");
    ## keyboard
  end
end
P = columns (x) ;
				# Produce a PointSet
if !balls && !cubes && !nums,

  if prod (size (col)) == 3*P	# One color per point
    smat = "";
    scol = sprintf ("  color Color { color [\n   %s]\n   }\n",\
		    sprintf ("      %8.3f %8.3f %8.3f\n", col));
  else				# One color
    smat = ["  appearance Appearance {\n",\
	    vrml_material(col, emit),"\n",\
	    "  }\n"];
    scol = "";
  end

  s = sprintf(["Shape {\n",\
	       smat,\
	       "  geometry PointSet {\n",\
	       scol,\
	       "  coord DEF %s Coordinate {\n  point [\n  " ],name); # ] 
  
  
  s0 = sprintf("%10.6g %10.6g %10.6g ,\n  ",x);
  
  s = sprintf("%s%s]\n  }\n  }\n  }\n",s,s0); # [
  
  if hide, s = ["Switch {\nchoice\n[\n",s,"\n]\n}"]; end

				# Use numbers
elseif nums,
  printf ("Foo\n");
  s = "";
  if prod (size (col)) == 3, col = col(:) * ones (1,P); end
  for i = 1:P,
    s0 = sprintf([\
		  "Transform {\n",\
		  "  translation %10.6g %10.6g %10.6g\n",\
		  "  children [\n",\ # ]
		  "    Billboard {\n",\
		  "      children [\n",\ # ]
		  "        Shape {\n",\
		  "          appearance Appearance {\n",\
		  vrml_material(col(:,i), emit, tran),"\n",\
		  "          }\n",\
		  "          geometry Text {\n",\
		  "            string \"%s\"\n",\
		  "            fontStyle FontStyle { size 0.25 }\n",\
		  "          }\n",\
		  "        }\n",\
		  "      ]\n",\
		  "    }\n",\
		  "  ]\n",\
		  "}\n"],\ # [
		 x(:,i),sprintf("%d",i-1));
		 ## x(:,i),col,col,sprintf("%d",i-1));
    ## "              emissiveColor %8.3f %8.3f %8.3f\n",\
    ## "      axisOfRotation 0.0 0.0 0.0\n",\ 

    s = sprintf("%s%s",s,s0);
  end
else
				# If all radiuses are the same, do a single
				# geometry node for all points
  if all (size (rad) == 1) || ! any (abs (diff (rad))>eps)
    all_same_rad = 1;
    if balls, shapestr = sprintf("Sphere { radius %8.3f}",rad) ; 
    else      shapestr = sprintf("Box { size %8.3f %8.3f %8.3f}",rad,rad,rad) ;
    end
  else
    all_same_rad = 0;
  end

				# If all colors are the same, do a single
				# geometry node for all points
  if prod (size (col)) == 3 || ! any (abs (diff (col'))>eps)
    all_same_col = 1;  
    colorstr = vrml_material (col(1:3), emit);
  else
    all_same_col = 0;
  end

  s = "";
  for i = 1:P
				# If some radiuses differ, I must do
				# geometry nodes individually
    if ! all_same_rad
				# Skip zero-sized objects
      if ! rad(:,i), continue; end

      if balls
	shapestr = sprintf("Sphere { radius %8.3f}",rad(:,i));
      else
	shapestr = sprintf("Box { size %8.3f %8.3f %8.3f}",rad(:,[i,i,i]));
      end
    end
				# If some colors differ, I must do material
				# nodes individually
    if ! all_same_col, colorstr = vrml_material (col(:,i), emit); end

    s0 = sprintf([\
		  "Transform {\n",\
		  "  translation %10.6g %10.6g %10.6g\n",\
		  "  children [\n",\ # ]
		  "    Shape {\n",\
		  "      appearance Appearance {\n",\
		  colorstr,"\n",\
		  "      }\n",\
		  "      geometry ",shapestr,"\n",\
		  "    }\n",\
		  "  ]\n",\
		  "}\n"],\
		 x(:,i));
    ## "          emissiveColor %8.3f %8.3f %8.3f\n",\
    ##		 x(:,i),col,col,shape);
    s = sprintf("%s%s",s,s0);
  end
end
endfunction


