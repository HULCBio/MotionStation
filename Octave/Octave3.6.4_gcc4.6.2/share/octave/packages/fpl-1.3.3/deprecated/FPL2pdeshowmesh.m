## Copyright (C) 2004-2008,2009  Carlo de Falco, Massimiliano Culpo
##
##  This file is part of 
##
##                   FPL - Fem PLotting package for octave
## 
##  FPL is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 3 of the License, or
##  (at your option) any later version.
## 
##  FPL is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
## 
##  You should have received a copy of the GNU General Public License
##  along with FPL; If not, see <http://www.gnu.org/licenses/>.
##
##
##  AUTHORS:
##  Carlo de Falco <cdf _AT_ users.sourceforge.net>
##
##  Culpo Massimiliano
##  Bergische Universitaet Wuppertal
##  Fachbereich C - Mathematik und Naturwissenschaften
##  Arbeitsgruppe fuer Angewandte MathematD-42119 Wuppertal  Gaussstr. 20 
##  D-42119 Wuppertal, Germany

## -*- texinfo -*-
##
## @deftypefn {Function File} {} FPL2pdeshowmesh (@var{mesh},@var{color})
## 
## Displays one 2-D triangulations using opendx
##
## Examples:
## @example
##
## FPL2pdeshowmesh(mesh)
## FPL2pdeshowmesh(mesh,"blue")
##
## @end example
##
## @seealso{FPL2ptcshowmesh}
## @end deftypefn

function FPL2pdeshowmesh (varargin)

  if nargin == 1
    colorname = "red";
  else
    colorname = varargin{2};
  endif

  dataname = mktemp("/tmp",".dx");
  FPL2dxoutputdata(dataname,varargin{1}.p,varargin{1}.t,varargin{1}.p(1,:)','x',0,1,1);
  
  scriptname = mktemp("/tmp",".net");
  
  showmesh = file_in_path(path,"FPL2pdeshowmesh.net");
  
  system (["cp " showmesh " " scriptname]);
  system (["sed -i \'s|FILENAME|" dataname "|g\' " scriptname]);
  system (["sed -i \'s|COLORNAME|" colorname "|g\' " scriptname]);

  command = ["dx  -noConfirmedQuit -program " scriptname " -execute -image  >& /dev/null & "];  
  system(command);
  
endfunction
  
function filename = mktemp (direct,ext);

  if (~exist(direct,"dir"))
    error("trying to save temporary file to non existing directory")
  end

  done=false;

  while ~done
    filename = [direct,"/FPL.",num2str(floor(rand*1e7)),ext];
    if ~exist(filename,"file")
      done =true;
    endif
  endwhile

endfunction

%!test
%! msh.p = [0 0; 1 0; 1 1; 0 1].';
%! msh.t = [1 2 3 1; 1 3 4 1].';
%! msh.e = [1 2 0 0 1 0 1; 2 3 0 0 2 0 1; 3 4 0 0 3 0 1; 4 1 0 0 4 0 1].';
%! FPL2pdeshowmesh (msh, "red");
%! s = input ("do you see a red outlined square divided in two triangles (if you see an empty plot try ctrl-F)? (y/n): " ,"s");
%! assert(s, "y")