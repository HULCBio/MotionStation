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
## @deftypefn {Function File} {} FPL2dxoutputtimeseries ( @var{filename}, @var{p}, @var{t}, @var{u}, @var{attr_name}, @var{attr_rank}, @var{attr_shape}, @var{time} )
##
##   Outputs a time series in DX form.
##   variable must be a scalar, vector or tensor of doubles   
## @itemize @minus
##  @item @var{filename}= name of file to save (type string)
##  @item @var{p}, @var{t} = mesh
##  @item @var{u} = variable to save
##  @item @var{attr_name}  = name of the variable (type string)
##  @item @var{attr_rank}  = rank of variable data (0 for scalar, 1 for vector, etc.)
##  @item @var{attr_shape} = number of components of variable data  (assumed 1 for scalar)
##  @item @var{time} = time instants
## @end itemize
## @end deftypefn

function FPL2dxoutputtimeseries(filename,p,t,u,attr_name,attr_rank,attr_shape,time)

  Nsteps = length(time);
  if (Nsteps<=1)
    endfile = 1;
  else
    endfile = 0;
  endif

  FPL2dxoutputdata(filename,p,t,u(:,1:attr_shape),[attr_name "1"],attr_rank,attr_shape,endfile);

  for it = 2:Nsteps
    FPL2dxappenddata(filename,p,t,u(:,[1:attr_shape]+attr_shape*(it-1)),...
		     [attr_name num2str(it)],attr_rank,attr_shape,endfile);
  endfor

  fid=fopen(filename,"a");

  fprintf (fid, "object \"%s_series\" class series\n",attr_name);
  for it = 1:Nsteps
    fprintf (fid,"member %d position %g value \"%s\"\n",it-1,time(it),[attr_name num2str(it)]);
  endfor
  fprintf (fid, "\nend\n");
  fclose(fid);

endfunction