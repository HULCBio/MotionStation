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
## @deftypefn {Function File} {} FPL2ptcquiver (@var{mesh1}, @var{color1}
## @var{vx1}, @var{vy1}, [ @var{mesh2}, @var{color2}, @var{vx2}, @var{vy2} ...])
## 
## Plots the 2D vector fields @var{vx}, @var{vy} 
## defined on the triangulations @var{mesh} using opendx.
##
##
## @seealso{FPL2pdesurf, FPL2ptcsurf, FPL2pdequiver}
## @end deftypefn

function FPL2ptcquiver(varargin) 
  
  colorlist = "";
  datalist  = "";
  
  for ii = 1:4:nargin
    dataname{ii} = mktemp("/tmp",".dx");
    JX = sum(varargin{ii+2},1)'/3;
    JY = sum(varargin{ii+3},1)'/3;
    FPL2dxoutputdata(dataname{ii},varargin{ii}.p,varargin{ii}.t,[ JX JY],'J',1,2,1);
    datalist = strcat (datalist, """", dataname{ii} , """");
    colorlist= strcat (colorlist, """", varargin{ii+1} , """");
  endfor
  
  scriptname = mktemp("/tmp",".net");
  
  view       = file_in_path(path,"FPL2ptcquiver.net");
  
  system (["cp " view " " scriptname]);
  system (["sed -i \'s|""FILELIST""|" datalist "|g\' " scriptname]);
  system (["sed -i \'s|""COLORLIST""|" colorlist "|g\' " scriptname]);

  command = ["dx  -noConfirmedQuit -program " scriptname " -execute -image  >& /dev/null & "];  
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
