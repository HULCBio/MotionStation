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

## save_vrml(outname,[options],s1,...)    - Save vrml code
## 
## Makes a vrml2 file from strings of vrml code. A "background" node is
## added.
## 
## Options :
## "nobg"
## "nolight"
## 
## Bugs :
## - "outname" should not contain the substring ".wrl" anywhere else
##   than as a suffix.
## - "outname" should only contain the character ">" as ">>" at the
##   beginning , to indicate append rather than overwriting the
##   file.

function save_vrml(outname, varargin)

verbose = 0;
append = 0;

if ! ischar(outname) ,
  error "save_vrml wants a string as first arg"
end

if strcmp(outname(1:2),">>"),
  append = 1;
end
outname = strrep(outname,">","");

outname = strrep(outname,".wrl",'');			# No suffix.

fname = sprintf("%s.wrl",outname);			# Add suffix.
bg_col = [0.4 0.4 0.7];
## bg_col = [1 1 1];
l_intensity = 0.3 ;
l_ambientIntensity = 0.5 ;
l_direction = [0.57735  -0.57735   0.57735] ;

bg_node = sprintf (["Background {\n",...
		    "  skyColor    %8.3g %8.3g %8.3g\n",...
		    "}\n"],\
		   bg_col);
bg_node = "";

lightstr = sprintf (["PointLight {\n",\
		     "  intensity         %8.3g\n",\
		     "  ambientIntensity  %8.3g\n",\
		     "  direction         %8.3g %8.3g %8.3g\n",\
		     "}\n"],\
		    l_intensity, l_ambientIntensity, l_direction);
lightstr = "";

				# Read eventual options
ninit = nargin;

i = 1;
args = nargin; # nargin is now a function
while --args,

  tmp = varargin{i++};
  if     strcmp (tmp, "nobg"),
    bg_node = "";
  elseif strcmp (tmp, "nolight"),
    lightstr = "";
  else				# Reached non-options
    ## beginpre 2.1.39
    # va_start ();
    # n = ++args ;
    # while n++ < ninit, va_arg (); end
    ## args, ninit
    ## endpre 2.1.39
    i--; 			# pos 2.1.39
    break;
  end
end
bg_node = [bg_node, lightstr];
## No path.
if findstr(outname,"/"),
  outname = outname(max(findstr(outname,"/"))+1:size(outname,2)) ;
end

if append, fid = fopen(fname,"at");		# Saving.
else       fid = fopen(fname,"wt"); 
end ;

if fid == -1 , error(sprintf("save_vrml : unable to open %s",fname)); end
 
## Put header.
fprintf(fid,"#VRML V2.0 utf8 \n# %s , created by save_vrml.m on %s \n%s",
	fname,datestr(now),bg_node);

while i <= length (varargin) ,

  if verbose, printf ("save_vrml : %i'th string\n",i); end

  fprintf (fid,"%s", varargin{i}) ;
  i++ ;
end

fprintf(fid,"\n");
fclose(fid);
endfunction

