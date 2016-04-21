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

## s = vrml_lines(x,f,...)
##
## x : 3xP   : The 3D points
## f : 3xQ   : The indexes of the points forming the lines. Indexes
##             should be in 1:P.
##
## Returns a Shape -> IndexedLineSet vrml node.
##
## No check is done on anything
##
## Options :
## 
## "col" , col  : 3x1 : Color, default = [1,0,0]

function s = vrml_lines(x,f,varargin)

if nargin < 2, f = ones (1,columns(x)); end
col = [1, 0, 0] ;

opt1 = " col " ;
opt0 = " " ;

verbose = 0 ;

i=1;

while (nargin -2) >=i ,

  tmp = varargin{i++} ;	# pos 2.1.39
  if ! ischar(tmp) ,
    error ("vrml_lines : Non-string option : \n") ;
    ## keyboard

  end
  if index(opt1,[" ",tmp," "]) ,
    

    tmp2 = varargin{i++}; # pos 2.1.39
    ## args-- ;
    eval([tmp,"=tmp2;"]) ;

    if verbose , printf ("vrml_lines : Read option : %s.\n",tmp); end

  elseif index(opt0,[" ",tmp," "]) ,
    
    eval([tmp,"=1;"]) ;
    if verbose , printf ("vrml_lines : Read boolean option : %s\n",tmp); end

  else
    error ("vrml_lines : Unknown option : %s\n",tmp) ;
    ## keyboard
  end
endwhile

if exist("col")!=1,  col = [0.5, 0.5, 0.8]; end

s = sprintf([... 			# string of indexed face set
	     "Shape {\n",...
	     "  appearance Appearance {\n",...
	     "    material Material {\n",...
	     "      diffuseColor %8.3f %8.3f %8.3f \n",...
	     "      emissiveColor %8.3f %8.3f %8.3f\n",...
	     "    }\n",...
	     "  }\n",...
	     "  geometry IndexedLineSet {\n",...
	     "    coordIndex [\n%s]\n",...
	     "    coord Coordinate {\n",...
	     "      point [\n%s]\n",...
	     "    }\n",...
	     "  }\n",...
	     "}\n",...
	     ],...
	    col,col,...
	    sprintf("                    %4d, %4d, %4d, -1,\n",f-1),...
	    sprintf("                 %8.3f %8.3f %8.3f,\n",x)) ;


endfunction

