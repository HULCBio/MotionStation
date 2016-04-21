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
## @deftypefn {Function File} {} FPL2pdesurf (@var{mesh}, @
## @var{u} [ @var{property}, @var{value} ...])
## 
## plots the scalar field @var{u}
## defined on the triangulation @var{mesh} using opendx.
##
## options (default value):
## @itemize @minus
## @item data_dep ("positions") defines wether data depends on
## positions or connections
## @item plot_field ("scalar") defines wether to plot the scalar field
## itself or its gradient
## @end itemize
##
## @seealso{MSH2Mgmsh, MSH2Mstructmesh}
## @end deftypefn
 
function FPL2pdesurf(varargin)

  data_dep   = "positions";
  plot_field = "scalar";

  if nargin == 1
    FPL2showmesh(varargin{1}); 
  elseif nargin == 2
    mesh = varargin{1};
    u = varargin{2};
  elseif ( (nargin > 2) && (rem(nargin,2)==0) )
    mesh = varargin{1};
    u = varargin{2};
    for ii=3:2:nargin
      eval([ varargin{ii} " = """ varargin{ii+1} """;" ]);
    endfor
  else  
    keyboard ,error(["wrong number of parameters " num2str (nargin)])
  endif

  dataname = mktemp("/tmp",".dx");
  scriptname = mktemp("/tmp",".net");

  FPL2dxoutputdata(dataname,mesh.p,mesh.t,u,'u',0,1,1);

  switch plot_field
    case {"scalar","scal"}
      showmesh = file_in_path(path,"FPL2coloredrubbersheet.net");
    case {"gradient","grad"}
      showmesh = file_in_path(path,"FPL2coloredgradient.net");
    otherwise
      error ([ "incorrect value " plot_field " for option plot_field "])
  endswitch

  system (["cp " showmesh " " scriptname]);
  system (["sed -i \'s|__FILE__DX__|" dataname "|g\' " scriptname]);

  switch data_dep
    case {"positions","continuous","interpolate","P1"}
      system (["sed -i \'s|__DATA_DEPENDENCY__|positions|g\' " scriptname]);
    case {"connections","discontinuous","P0"}
      system (["sed -i \'s|__DATA_DEPENDENCY__|positions|g\' " scriptname]);
    otherwise 
      error ([ "incorrect value " data_dep " for option data_dep "])
  endswitch

  ##command = ["dx -noConfirmedQuit  -noImageRWNetFile -program " scriptname " -execute -image  >& /dev/null & "];
  command  = ["dx -noConfirmedQuit  -program " scriptname " -execute -image  >& /dev/null & "];
  
  system(command);

endfunction 

function filename = mktemp (direct,ext);

  if (~exist(direct,"dir"))
    error("trying to save temporary file to non existing directory")
  endif

  done=false;

  while ~done
    filename = [direct,"/FPL.",num2str(floor(rand*1e7)),ext];
    if ~exist(filename,"file")
      done =true;
    endif
  endwhile
  
endfunction

%!shared msh
%!test
%! msh.p = [0 0; 1 0; 1 1; 0 1].';
%! msh.t = [1 2 3 1; 1 3 4 1].';
%! msh.e = [1 2 0 0 1 0 1; 2 3 0 0 2 0 1; 3 4 0 0 3 0 1; 4 1 0 0 4 0 1].';
%! u = [0 1].';
%! FPL2pdesurf (msh, u, "data_dep", "connections");
%! s = input ("do you see a square divided into two triangles with a diagonal red-to-blue gradient color (if you see an empty plot try ctrl-F)? (y/n): " ,"s");
%! assert(s, "y")
%!test
%! v = [0 0 1 1].';
%! FPL2pdesurf (msh, v);
%! s = input ("do you see a square divided into two triangles with a vertical red-to-blue gradient color (if you see an empty plot try ctrl-F)? (y/n): " ,"s");
