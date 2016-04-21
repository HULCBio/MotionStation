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
##
## @deftypefn {Function File} {} FPL2ptcsurf (@var{mesh1}, @
## @var{color1}, @var{data1} @ [@var{mesh2}, @var{color2},@var{data2}])
## 
## Plots the scalar fields @var{data} over the triangulation
## @var{mesh} using opendx. Connections will be displayed as defined
## in @var{color}.
##
## @end deftypefn

function FPL2ptcsurf(varargin)
  
  colorlist = "";
  datalist  = "";
  
  for ii=1:3:nargin
    dataname{ii} = mktemp("/tmp",".dx");
    FPL2dxoutputdata(dataname{ii},varargin{ii}.p,varargin{ii}.t,varargin{ii+2},"var",0,1,1);
    datalist = strcat (datalist, """", dataname{ii} ,"""");
    colorlist= strcat (colorlist, """", varargin{ii+1} ,"""");
  endfor
  
  scriptname = mktemp("/tmp",".net");
  
  ptcview    = file_in_path(path,"FPL2ptcsurf.net");
  
  system (["cp " ptcview " " scriptname]);
  system (["sed -i \'s|""FILELIST""|" datalist "|g\' " scriptname]);
  system (["sed -i \'s|""COLORLIST""|" colorlist "|g\' " scriptname]);
  
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