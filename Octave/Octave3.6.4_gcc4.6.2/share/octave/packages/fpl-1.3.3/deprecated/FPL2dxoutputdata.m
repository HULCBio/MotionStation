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
##  @deftypefn {Function File} {} FPL2dxoutputdata ( @var{filename}, @
##  @var{p}, @var{t}, @var{u},  @var{attr_name}, @var{attr_rank},  @
##  @var{attr_shape}, @var{endfile} )
##
##   Outputs data in DX form.
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

function FPL2dxoutputdata(filename,p,t,u,attr_name,attr_rank,attr_shape,endfile)

  p = p';
  t = t';
  t = t(:,1:3);

  fid=fopen (filename,'w');
  Nnodi = size(p,1);
  Ntriangoli = size(t,1);
  Ndati = size(u,1);

  fprintf(fid,"object ""pos""\nclass array type float rank 1 shape 2 items %d data follows",Nnodi);

  for i=1:Nnodi
    fprintf(fid,"\n");
    fprintf(fid,"    %1.7e",p(i,:));
  endfor
		  
  if (min(min(t))==1)
    t=t-1;
  elseif(min(min(t))~=0)
    disp('WARNING: check triangle structure')
  endif                    
  ## In DX format nodes are 
  ## numbered starting from zero,
  ## instead we want to number
  ## them starting from 1!
  ## Here we restore the DX
  ## format

  fprintf(fid,"\n\nobject ""con""\nclass array type int rank 1 shape 3 items %d data follows",Ntriangoli);
  for i=1:Ntriangoli
    fprintf(fid,"\n");
    fprintf(fid,"      %d",t(i,:));
  endfor
				  
  fprintf(fid,"\nattribute ""element type"" string ""triangles""\nattribute ""ref"" string ""positions""\n\n");
				  
  if ((attr_rank==0) && (min(size(u))==1))
    fprintf(fid,"object ""%s.data""\nclass array type double rank 0 items %d data follows",attr_name,Ndati);
    fprintf(fid,"\n %1.7e",u);
    
  else
    fprintf(fid,"object ""%s.data""\nclass array type double rank %d shape %d items %d data follows", ...
	    attr_name,attr_rank,attr_shape,Ndati);
    for i=1:Ndati
      fprintf(fid,"\n");
      fprintf(fid,"    %1.7e",u(i,:));
    endfor
    
  endif
  
  if Ndati==Nnodi
    fprintf(fid,["\nattribute ""dep"" string ""positions""\n\n" ...
		 "object ""%s"" class field\n"...
		 "component ""positions"" value ""pos""\n"...
		 "component ""connections"" value ""con""\n"...
		 "component ""data"" value ""%s.data""\n"],...
	    attr_name,attr_name);
  elseif Ndati==Ntriangoli
    fprintf(fid,["\nattribute ""dep"" string ""connections""\n\n" ...
		 "object ""%s"" class field\n"...
		 "component ""positions"" value ""pos""\n"...
		 "component ""connections"" value ""con""\n"...
		 "component ""data"" value ""%s.data""\n"],...
	    attr_name,attr_name);
  endif

  if(endfile)
    fprintf(fid,"\nend\n");
  endif
							  
  fclose (fid);
  
  
endfunction