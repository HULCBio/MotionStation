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

## s = vrml_faces(x,f,...) - VRML facet object (IndexedFaceSet node)
##
## x : 3xP   : The 3D points
## f : 3xQ   : The indexes of the points forming the faces. Indexes
##             should have values in 1:P.
##
## Returns a Shape -> IndexedFaceSet vrml node.
##
## No check is done on anything
##
## Options :
## 
## "col" , col  : 3   : Color,                      default = [0.3,0.4,0.9]
##             or 3xP : Color of vertices
##             or 3xQ : Color of facets   (use "colorPerVertex" below to
##                                         disambiguate the case P==Q).
## 
## "emit", em   : 3   : Emissive color of the surface
##              : 3XP : (same as color)
##              : 3xQ :
##              : 1   : Use color as emissive color too         default = 0
##
## "tran", tran : 1x1 : Transparency,                           default = 0
##
## "creaseAngle", a 
##              :  1  : vrml creaseAngle value. The browser may smoothe the
##                      crease between facets whose angle is less than a.
##                                                              default = 0
## "tex", texfile 
##              : string : Name of file containing texture.   default : none
##
## "imsz", sz   : 2   : Size of texture image 
##                                       default is determined by imginfo()
##
## "tcoord", tcoord
##              : 2x3Q : Coordinates of vertices in texture image. Each 2x3
##                       block contains coords of one facet's corners. The
##                       coordinates should be in [0,1], as in a VRML
##                       TextureCoordinate node.
##                                       default assumes faces are returned
##                                       by extex()
##
## "smooth"           : same as "creaseAngle",pi.
## "convex"
## "colorPerVertex", c: If 1, col specifies color of vertices. If 0,
##                       col specifies color of facets.         Default = 1
##
## "DEFcoord",n : string : DEF the coord VRML node with name n. Default = ''
## "DEFcol",  n : string : DEF the color VRML node with name n. Default = ''
##
## See also: vrml_surf(), vmesh(), test_vrml_faces()

function s = vrml_faces (x,f,varargin)

  ## mytic; starttime = cputime();

  if rows (x) != 3
    if columns (x) != 3
      error ("x is %i x %i, has neither 3 rows nor 3 columns.", size (x));
    else
      x = x';
    end
  end

  tran = 0 ;
  col = [0.3, 0.4, 0.9] ;
  convex = emit = 0;
  tcoord = imsz = tex = smooth = creaseAngle = nan ;
  colorPerVertex = nan;
  DEFcol = DEFcoord = "";

  ## Read options ######################################################
  opt1 = " tex DEFcoord DEFcol imsz tcoord tran col creaseAngle colorPerVertex emit " ;
  opt0 = " smooth convex " ;

  verbose = 0 ;

  i = 1;

  while numel(varargin)>=i

    tmp = varargin{i++};
    if ! ischar(tmp) ,
      error ("vrml_faces : Non-string option : \n") ;
      ## keyboard
    end

    if index(opt1,[" ",tmp," "]) ,
      
      tmp2 = varargin{i++} ;

      eval([tmp,"=tmp2;"]) ;

      if verbose , printf ("vrml_faces : Read option : %s.\n",tmp); end

    elseif index(opt0,[" ",tmp," "]) ,
      
      eval([tmp,"=1;"]) ;
      if verbose , printf ("vrml_faces : Read boolean option : %s\n",tmp); end

    else
      error ("vrml_faces : Unknown option : %s\n",tmp) ;
      ## keyboard
    end
  endwhile
  ## printf ("  Options : %f\n",mytic()); ## Just for measuring time
  ## End of reading options ############################################

  if !isempty (DEFcol), col_def_str = ["DEF ",DEFcol]; 
  else                  col_def_str = ""; 
  end


  if ! isnan (smooth), creaseAngle = pi ; end

  ## printf ("creaseAngle = %8.3f\n",creaseAngle);

  nfaces = columns (f); 
  if ismatrix(f)
    if rows (f) < 3
      error ("Faces matrix 'f' has %i < 3 rows, so it does not define faces",
	     rows (f));
    end
    if any (f > columns (x))
      error ("Faces matrix 'f' has value %i greater than number of points %i",
	     max (f(:)), columns (x));
    end
  end

  if ! isnan (tcoord)

    col_str_1 = sprintf (["  appearance Appearance {\n",...
			  "    texture ImageTexture {\n",...
			  "      url \"%s\"\n",...
			  "    }\n",...
			  "  }\n"],...
			 tex);

    texcoord_point_str = sprintf ("    %8.5f %8.5f\n", tcoord);
    
    col_str_2 = sprintf (["  texCoord TextureCoordinate {\n",\
			  "    point [\n      %s]\n",\
			  "  }\n"\
			  ],\
			 texcoord_point_str\
			 );
    
				# If texture has been provided
  elseif ischar (tex),		# Assume triangles

    ## printf ("Using texture\n");
    
    col_str_1 = sprintf (["  appearance Appearance {\n",...
			  "    texture ImageTexture {\n",...
			  "      url \"%s\"\n",...
			  "    }\n",...
			  "  }\n"],...
			 tex);
    
				# Eventually determine size of image
    if isnan(imsz), imsz = imginfo (tex); end

    if isnan (tcoord),

      nb = ceil (nfaces/2);	# n of blocks
      lo = [0:nb-1]/nb; hi = [1:nb]/nb;
      on = ones (1,nb); ze = zeros (1,nb);
      
      sm = (1/nb) /(imsz(2)+1);	
      tcoord = [lo; on; lo; ze; hi-sm; ze;  lo+sm; on; hi-sm; on; hi-sm; ze];
      tcoord = reshape (tcoord, 2, 6*nb);
      tcoord = tcoord (:,1:3*nfaces);
    end

    col_str_2 = sprintf (["  texCoord TextureCoordinate {\n",\
			  "    point [\n      %s]\n",\
			  "  }\n",\
			  "  texCoordIndex [\n      %s]\n",\
			  "  coordIndex [\n      %s]\n",\
			  ],\
			 sprintf ("%10.8f %10.8f,\n      ",tcoord),\
			 sprintf ("%-4d, %-4d, %-4d, -1,\n     ",0:3*nfaces-1),\
			 sprintf ("%-4d, %-4d, %-4d, -1,\n     ",f-1)
			 );
    
    ## TODO : f-1 abobe seems to not work if f is a cell or list (check
    ## whether this is possible here)

  elseif prod (size (col))==3,	# One color has been specified for the whole
				# surface

    col_str_1 = ["  appearance Appearance {\n",...
		 vrml_material(col, emit, tran,DEFcol),\
		 "  }\n"];

    col_str_2 = "";
  else
    if (emit)			# Color is emissive by default
      col_str_1 = "";
      

    else				# If there's a material node, it is not
				# emissive.
      if tran, ts = sprintf ("transparency %8.3f",tran);
      else     ts = "";
      end
      col_str_1 = ["appearance Appearance {\n",\
		   "    material Material {",ts,"}\n}\n"];
    end
    if isnan (colorPerVertex)
      if     prod (size (col)) == 3*columns (x), colorPerVertex = 1;
      elseif prod (size (col)) == 3*columns (f), colorPerVertex = 0;
      end
    end
    if colorPerVertex, cPVs = "TRUE"; else cPVs = "FALSE"; end

    col_str_2 = sprintf (["     colorPerVertex %s\n",\
			  "     color %s Color {\n",\
			  "       color [\n%s\n",\
			  "       ]\n",\
			  "     }"],\
			 cPVs,\
			 col_def_str,\
			 sprintf("         %8.3f %8.3f %8.3f,\n",col));
  end

  ## printf ("  Colors  : %f\n",mytic()); ## Just for measuring time

  etc_str = "" ;
  if ! isnan (creaseAngle),
    etc_str = [etc_str, sprintf("    creaseAngle    %8.3f\n",creaseAngle)];
  end

  ## TODO : s/list/cell/g; Should put this code in sometime soon
  ## Code below seems useless
				# Faces 
  if iscell (f), nfaces = length (f); else nfaces = columns (f); end


  tpl0 = sprintf ("%%%dd, ",floor (log10 (max (1, columns (x))))+1);
  ltpl0 = length (tpl0);

  ptsface = zeros (1,nfaces);

				# Determine total number of vertices, number
				# of vertices per face and indexes of
				# vertices of each face
  if iscell (f)			
    npts = 0;
    for i = 1:length (f), 
       ptsface(i) = 1+length (f{i});
       npts += ptsface(i);  
    end
    ii = [0, cumsum(ptsface)]';
    all_indexes = -ones (1,npts);
    for i = 1:length (f), all_indexes(ii(i)+1:ii(i+1)-1) = f{i} - 1; end
  else
    f = [f;-ones(1,columns(f))];
    npts = sum (ptsface = (sum (!! f)));
    all_indexes = nze (f) - 1; 
    all_indexes(find (all_indexes<0)) = -1;
  end
  ## printf ("  Indexes  : %f\n",mytic()); ## Just for measuring time

  coord_str = sprintf (tpl0, all_indexes);
  ## That's too slow coord_str = strrep (coord_str, "-1, ","-1,\n");

  ## printf ("  Faces  : %f\n",mytic()); ## Just for measuring time

  if ! convex, etc_str = [etc_str,"    convex FALSE\n"]; end

  if !isempty (DEFcoord), coord_def_str = ["DEF ",DEFcoord]; 
  else                    coord_def_str = ""; 
  end

  s = sprintf([... 			# string of indexed face set
	       "Shape {\n",...
	       col_str_1,...
	       "  geometry IndexedFaceSet {\n",...
	       "    solid FALSE     # Show back of faces too\n",...
	       col_str_2,...
	       etc_str,...
	       "    coordIndex [\n%s]\n",...
	       "    coord %s Coordinate {\n",...
	       "      point [\n%s]\n",...
	       "    }\n",...
	       "  }\n",...
	       "}\n",...
	       ],...
	      coord_str,...
	      coord_def_str,...
	      sprintf("                 %8.3f %8.3f %8.3f,\n",x)) ;
  ## printf ("  Assembly :  %f\n",mytic()); ## Just for measuring time
  ## printf ("Total Time : %f\n",cputime() - starttime);

%!demo
%! % Test the vrml_faces and vrml_browse functions with the test_vrml_faces script
%! test_vrml_faces
endfunction

