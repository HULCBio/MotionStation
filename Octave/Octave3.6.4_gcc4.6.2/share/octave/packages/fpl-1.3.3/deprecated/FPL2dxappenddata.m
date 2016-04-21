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
##  @deftypefn {Function File} {} FPL2dxappenddata ( @var{filename},
##  @var{p}, @var{t}, @var{u}, @var{attr_name}, @var{attr_rank},
##  @var{attr_shape}, @var{endflie} )
##
##   Apends data to a file in DX form.
##   Only one variable can be written to the file
##   variable must be a scalar, vector or tensor of doubles   
##   mesh data in the file must be consistent with this variable
##
##   Variable must be a scalar, vector or tensor of doubles   
##
## @itemize @minus
##  @item @var{filename}= name of file to save (type string)
##  @item @var{p}, @var{t} = mesh
##  @item @var{u} = variable to save
##  @item @var{attr_name}  = name of the variable (type string)
##  @item @var{attr_rank}  = rank of variable data (0 for scalar, 1 for vector, etc.)
##  @item @var{attr_shape} = number of components of variable data  (assumed 1 for scalar)
##  @item @var{endfile} = 0 if you want to add other variables to the
##  same file, 1 otherwise
## @end itemize
## @end deftypefn

function FPL2dxappenddata(filename,p,t,u,attr_name,attr_rank,attr_shape,endfile)

  p = p';
  t = t';
  t = t(:,1:3);

  fid=fopen (filename,'a');
  Nnodi = size(p,1);
  Ntriangoli = size(t,1);

  fprintf(fid,'\nattribute "element type" string "triangles"\nattribute "ref" string "positions"\n\n');

  if ((attr_rank==0) && (min(size(u))==1))
    fprintf(fid,'object "%s.data"\nclass array type double rank 0 items %d data follows',attr_name,Nnodi);
	    fprintf(fid,'\n %1.7e',u);
		  else
		    fprintf(fid,'object "%s.data"\nclass array type double rank %d shape %d items %d data follows', ...
			    attr_name,attr_rank,attr_shape,Nnodi);
		    for i=1:Nnodi
                    fprintf(fid,'\n');
                    fprintf(fid,'    %1.7e',u(i,:));
		    endfor
  endif
  fprintf(fid,['\nattribute "dep" string "positions"\n\n' ...
               'object "%s" class field\n'...
               'component "positions" value "pos"\n'...
               'component "connections" value "con"\n'...
               'component "data" value "%s.data"\n'],...
          attr_name,attr_name);
  
  if(endfile)
    fprintf(fid,'\nend\n');
  endif
  
  fclose (fid);
  
endfunction