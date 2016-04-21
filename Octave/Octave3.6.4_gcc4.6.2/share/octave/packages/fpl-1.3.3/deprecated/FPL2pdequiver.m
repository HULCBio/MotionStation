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
## @deftypefn {Function File} {} FPL2pdequiver (@var{mesh}, @
## @var{vx}, @var{vy}, [ @var{property}, @var{value} ...])
## 
## Plots the 2D vector field @var{vx}, @var{vy} 
## defined on the triangulation @var{mesh} using opendx.
##
## Options (default values):
## @var{sample_density} (100)
##
## @seealso{FPL2pdesurf, FPL2ptcsurf, FPL2ptcquiver}
## @end deftypefn

function FPL2pdequiver(mesh,vecfieldx,vecfieldy,varargin); 
  
  sample_density = "100";

  if( (nargin >= 3) && (rem(nargin,2)==1) )
    for ii=1:2:length(varargin)
      [ varargin{ii} " = " varargin{ii+1} ";" ]
      eval([ varargin{ii} " = """ varargin{ii+1} """;" ]);
    endfor
  else  
    error(["wrong number of parameters " num2str (nargin)])
  endif

  JX = sum(vecfieldx,1)'/3;
  JY = sum(vecfieldy,1)'/3;

  dataname = mktemp("/tmp",".dx");
  scriptname = mktemp("/tmp",".net");

  FPL2dxoutputdata(dataname,mesh.p,mesh.t,[ JX JY],'J',1,2,1);

  showmesh = file_in_path(path,"FPL2pdequiver.net");

  system (["cp " showmesh " " scriptname]);
  system (["sed -i \'s|__FILE__DX__|" dataname "|g\' " scriptname]);
  system (["sed -i \'s|__SAMPLE__DENSITY__|" sample_density "|g\' " scriptname]);

  command = ["dx -noConfirmedQuit -program " scriptname " -execute -image  >& /dev/null & "];

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
