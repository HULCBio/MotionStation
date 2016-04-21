##  Copyright (C) 2011  Carlo de Falco
##
##  This file is part of:
##         FPL - Fem PLotting package for octave
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
##  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} {} fpl_vtk_assemble_series (@var{collection}, @var{basenanme}, @var{format}, @var{idx}, @var{time})
## 
## Assemble a ParaView collection file (pvd) from a set of files representing data at different time-steps.
##
## @var{collection} is a string containing the base-name of the pvd file
## where the data will be saved.
##
## @var{basename}, @var{format}, @var{idx} are two strings and a set of integers, the name of the i-th file in the collection  
## will be computed as @code{sprintf ([basename, format, ".vtu"], idx(i))}.  
##
## @var{time} is the set of time-steps to which data correspond
##
## @seealso{fpl_vtk_write_field, fpl_dx_write_series} 
##
## @end deftypefn


function fpl_vtk_assemble_series (collection, basenanme, format, idx, time)

  fid = fopen (strcat (collection, ".pvd"), "w");
  
  ## Header
  fprintf (fid, "<?xml version=""1.0""?>\n");
  fprintf (fid, "<VTKFile type=""Collection"" ");
  fprintf (fid, " version=""0.1"">\n");
  fprintf (fid, "<Collection>\n");

  ## Series
  for ii = 1:ntpoints
    fprintf (fid, "<DataSet timestep=""%#17.17g"" group=""%s"" ", time(ii), basename);
    fprintf (fid, strcat ("file=""%s.", format, ".vtu""/>\n"), basename, idx(ii));
  endfor
  
  ## Footer
  fprintf (fid, "</Collection>\n");
  fprintf (fid, "</VTKFile>\n");
  fclose (fid);

endfunction