## Copyright (C) 2008 Carlo de Falco
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA


## -*- texinfo -*- 
## @deftypefn {Function File} {} FPL2vtkoutputdata ( @var{filename}, @var{p}, @var{t}, @var{nodedata}, @var{celldata}, @var{header}, @var{vtkver})
##
## Save data in VTK ASCII format.
##
## @itemize @minus
##  @item  @var{filename} = name of file to save into
##  @item  @var{p}, @var{t} = mesh node coordinates and connectivity
##  @item  @var{name} = name of a mesh variable
##  @item  @var{nodedata}/@var{celldata} = node/cell centered data
##  fields (2xNfields cell array), @var{*data}@{:,1@} = variable names;
##  @var{*data}@{:,2@} = variable data;
##  @item @var{header} comment to add in the file header
##  @item @var{vtkver} format version (default is 3.0)
## @end itemize
##
## @seealso{FPL2dxoutputdata}
## @end deftypefn

function FPL2vtkoutputdata (filename, p, t, nodedata, celldata, header, vtkver)

  fid = fopen (filename, "w");
  if ( fid )

    ## version ID
    if (!exist("vtkver"))
      vtkver = [3 0];
    endif

    fprintf (fid, "# vtk DataFile Version %d.%d\n", vtkver(1), vtkver(2));

    ## header
    if (!exist("header"))
      header = "";
    elseif (length(header) > 255)
      header (255:end) = [];
    endif
    
    fprintf (fid, "%s\n", header);

    ## File format: only ASCII supported for the moment
    fprintf (fid, "ASCII\n");
    
    ## Mesh: only triangles suported
    fprintf (fid, "DATASET UNSTRUCTURED_GRID\n");

    Nnodes = columns(p);
    fprintf (fid,"POINTS %d double\n", Nnodes);
    fprintf (fid,"%g %g 0\n", p);

    Nelem = columns(t);
    T     = zeros(4,Nelem);
    T(1,:)= 3;
    T(2:4,:) = t(1:3,:) -1;
    fprintf (fid,"CELLS %d %d\n", Nelem, Nelem*4);
    fprintf (fid,"%d %d %d %d\n", T);
    fprintf (fid,"CELL_TYPES %d \n", Nelem);
    fprintf (fid,"%d\n", 5*ones(Nelem,1));

    ## node data
    if (exist("nodedata"))
      nfields = rows(nodedata);
      if nfields
	fprintf (fid,"POINT_DATA %d\n", Nnodes);
	for ifield = 1:nfields
	  V = nodedata {ifield, 2};
	  N = nodedata {ifield, 1};
	  if (isvector (V))
	    fprintf (fid,"SCALARS %s double\nLOOKUP_TABLE default\n", N);
	    fprintf (fid,"%g\n", V);
	  else
	    V(:,3) = 0;
	    fprintf (fid,"VECTORS %s double\nLOOKUP_TABLE default\n", N);
	    fprintf (fid,"%g %g %g\n", V);
	  endif     
	endfor
      endif
    endif

    ## cell data
    if (exist("celldata"))
      nfields = rows(celldata);
      if nfields
	fprintf (fid,"CELL_DATA %d\n", Nelem);
	for ifield = 1:nfields
	  V = celldata {ifield, 2};
	  N = celldata {ifield, 1};
	  if (isvector (V))
	    fprintf (fid,"SCALARS %s double\nLOOKUP_TABLE default\n", N);
	    fprintf (fid,"%g\n", V);
	  else
	    V(:,3) = 0;
	    fprintf (fid,"VECTORS %s double\nLOOKUP_TABLE default\n", N);
	    fprintf (fid,"%g %g %g\n", V);
	  endif
	endfor
      endif
    endif

    ## cleanup
    fclose (fid);
  else
    error(["FPL2vtkoutputdata: could not open file " filename]);
  endif
endfunction

%!test
%! msh.p =[ 0   0   0   0   1   1   1   1   2   2   2   2   3   3   3   3
%!          0   1   2   3   0   1   2   3   0   1   2   3   0   1   2   3];
%! msh.e =[1    5    9   13   14   15    4    8   12    1    2    3
%!     5    9   13   14   15   16    8   12   16    2    3    4
%!     0    0    0    0    0    0    0    0    0    0    0    0
%!     0    0    0    0    0    0    0    0    0    0    0    0
%!     1    1    1    2    2    2    3    3    3    4    4    4
%!     0    0    0    0    0    0    0    0    0    0    0    0
%!     1    1    1    1    1    1    1    1    1    1    1    1];
%! msh.t =[ 1    2    3    5    6    7    9   10   11    1    2    3    5    6    7    9   10   11
%!     5    6    7    9   10   11   13   14   15    6    7    8   10   11   12   14   15   16
%!     6    7    8   10   11   12   14   15   16    2    3    4    6    7    8   10   11   12
%!     1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1];
%! testfile = "# vtk DataFile Version 3.0\n\nASCII\nDATASET UNSTRUCTURED_GRID\nPOINTS 16 double\n0 0 0\n0 1 0\n0 2 0\n0 3 0\n1 0 0\n1 1 0\n1 2 0\n1 3 0\n2 0 0\n2 1 0\n2 2 0\n2 3 0\n3 0 0\n3 1 0\n3 2 0\n3 3 0\nCELLS 18 72\n3 0 4 5\n3 1 5 6\n3 2 6 7\n3 4 8 9\n3 5 9 10\n3 6 10 11\n3 8 12 13\n3 9 13 14\n3 10 14 15\n3 0 5 1\n3 1 6 2\n3 2 7 3\n3 4 9 5\n3 5 10 6\n3 6 11 7\n3 8 13 9\n3 9 14 10\n3 10 15 11\nCELL_TYPES 18 \n5\n5\n5\n5\n5\n5\n5\n5\n5\n5\n5\n5\n5\n5\n5\n5\n5\n5\nPOINT_DATA 16\nSCALARS u double\nLOOKUP_TABLE default\n0\n0\n0\n0\n1\n1\n1\n1\n2\n2\n2\n2\n3\n3\n3\n3\n";
%! FPL2vtkoutputdata ("__FPL2vtkoutputdata__test__.vtk", msh.p, msh.t, {"u", msh.p(1,:).'}); 
%! fid = fopen("__FPL2vtkoutputdata__test__.vtk","r"); 
%! s = fread(fid);
%! fclose(fid); 
%! assert (char(s'), testfile);
%! delete __FPL2vtkoutputdata__test__.vtk
