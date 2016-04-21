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
##  @deftypefn {Function File} {} FPL3dxoutputfield( @var{filename}, @
##  @var{meshfilename}, @var{dep}, @var{u},  @var{attr_name}, @var{attr_rank},  @
##  @var{attr_shape}, @var{endfile} )
##
##   Outputs data in DX form.
##
##   Variable must be a scalar, vector or tensor of doubles   
##
## @itemize @minus
##  @item @var{filename}     = name of file to save (type string)
##  @item @var{meshfilename} = name of mesh file (type string)
##  @item @var{dep}          = "positions" for node data, "connections" for element data
##  @item @var{field}        = field data to be saved
##  @item @var{attr_name}    = name of the variable (type string)
##  @item @var{attr_rank}    = rank of variable data (0 for scalar, 1 for vector, etc.)
##  @item @var{attr_shape}   = number of components of variable data  (assumed 1 for scalar)
## @end itemize
## @end deftypefn

function FPL3dxoutputfield(filename,meshfilename,dep,field,attr_name,attr_rank,attr_shape)
  
  fid    = fopen (filename,"w");
  nnodes = size(field,1);
  
  if ((attr_rank==0) && (min(size(field))==1))
    fprintf(fid,"object ""%s.data""\nclass array type double rank 0 items %d data follows",attr_name,nnodes);
    fprintf(fid,"\n %e",field);
  else
    fprintf(fid,"object ""%s.data""\nclass array type double rank %d shape %d items %d data follows",attr_name,attr_rank,attr_shape,nnodes);
    for ii = 1:nnodes
      fprintf(fid,"\n");
      fprintf(fid,"    %e",field(ii,:));
    endfor
  endif
  fprintf(fid,"\nattribute ""dep"" string ""%s""\n\n",dep);
  fprintf(fid,"object ""%s"" class field\n",attr_name);
  fprintf(fid,"component ""positions"" file %s ""pos""\n",meshfilename);
  fprintf(fid,"component ""connections"" file %s ""con""\n",meshfilename);
  fprintf(fid,"component ""data"" value ""%s.data""\n",attr_name);

  fprintf(fid,"\nend\n");
  fclose (fid);

endfunction


