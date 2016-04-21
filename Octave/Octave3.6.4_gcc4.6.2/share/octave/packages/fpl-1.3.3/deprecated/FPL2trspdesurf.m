## Copyright (C) 2004-2008  Carlo de Falco, Massimiliano Culpo
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
## @deftypefn {Function File} {} FPL2trspdesurf (@var{mesh}, @
## @var{color}, @var{data})
## 
## Plots the transient scalar field @var{u} defined on the triangulation
## @var{mesh} using opendx. Connections are rendered as defined by
## @var{color}
##
## Example:
## @example
##
## FPL2trspdesurf(mesh,"blue",data)
##
## @end example
## @seealso{FPL2pdesurf, FPL2ptcsurf, FPL2trsptcsurf}
## @end deftypefn
  
function FPL2trspdesurf(varargin)
  
  seriesend = columns(varargin{3});
  dataname  = mktemp("/tmp",".dx");
  colorname = varargin{2};
  FPL2dxoutputtimeseries(dataname, varargin{1}.p, varargin{1}.t, \
			 varargin{3}, "dataseries", 0, 1, 1:seriesend);

  scriptname = mktemp("/tmp",".net");

  view       = file_in_path(path,"FPL2trspdesurf.net");
  
  system (["cp " view " " scriptname]);
  system (["sed -i \'s|FILENAME|" dataname "|g\' " scriptname]);
  system (["sed -i \'s|COLORNAME|" colorname "|g\' " scriptname]);
  
  command = ["dx  -noConfirmedQuit -program " scriptname " -execute -image  >& /dev/null & "];  
  system(command);

endfunction
  
function filename = mktemp (direct,ext);
  
  if (~exist(direct,"dir"))
    error("Trying to save temporary file to non existing directory")
  endif
  
  done = false;
  
  while ~done
    filename = [direct,"/FPL.",num2str(floor(rand*1e7)),ext];
    if ~exist(filename,"file")
      done = true;
    endif
  endwhile
  
endfunction