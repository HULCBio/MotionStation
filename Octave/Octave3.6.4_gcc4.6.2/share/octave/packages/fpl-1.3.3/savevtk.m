## Copyright (C) 2010 Kurnia Wano, Levente Torok
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [@var{status}] = savevtk ( @var{X}, @var{Y}, @var{Z}, @var{filename} )
##
##  Save a 3-D scalar array @var{array} to the file @var{filename} in VTK structured-grid format. 
##
##  This file format is used by Mayavi2 or ParaView for example.
##  If no write errors occurred, output argument @var{status} is set to 1, otherwise 0.
##
##  Example:
##
##  @example
##    n = 30;
##    X = zeros (n, n, n);
##    for x = 1:n
##      for y = 1:n
##        for z = 1:n
##            X(x, y, z) = 1 / sqrt (x*x + y*y + z*z);
##        endfor
##      endfor
##    endfor
##    X = X * 200 / max (max (max (X)));
##    savevtk (X, "spherical.vtk");
##  @end example
##
## @seealso{savevtkvector}
##
## @end deftypefn

##
## Author: Kurnia Wano, Levente Torok <TorokLev@gmail.com>
## Created: 2010-08-02 matlab version
## Updates: 2010-11-03 octave adoptation
##          2011-08-17 remove matlab style short-cicuit operator, indentation, help text
##

function status = savevtk (array, filename="vtkout.vtk")
 
  status = 0;
  if (nargin < 1), usage ("[status] = savevtk (array, filename)"); endif
  dims = size (array);
  if (numel (dims) != 3)
    error ("Save Vtk requires a 3 dimensional array");
  endif
  [nx, ny, nz] = size (array);
  
  if (ischar (filename))
    [fid, msg] = fopen (filename, 'wt');
    if (fid < 0)
      error ("Cannot open file for saving file. %s", msg);
    endif
  else
    usage ("Filename expected for arg # 2");
  endif

  try
    fprintf (fid, '# vtk DataFile Version 2.0\n');
    fprintf (fid, 'Comment goes here\n');
    fprintf (fid, 'ASCII\n');
    fprintf (fid, '\n');
    fprintf (fid, 'DATASET STRUCTURED_POINTS\n');
    fprintf (fid, 'DIMENSIONS    %d   %d   %d\n', nx, ny, nz);
    fprintf (fid, '\n');
    fprintf (fid, 'ORIGIN    0.000   0.000   0.000\n');
    fprintf (fid, 'SPACING    1.000   1.000   1.000\n');
    fprintf (fid, '\n');
    fprintf (fid, 'POINT_DATA   %d\n', nx*ny*nz);
    fprintf (fid, 'SCALARS scalars double\n');
    fprintf (fid, 'LOOKUP_TABLE default\n');
    fprintf (fid, '\n');
    for a=1:nz
      for b=1:ny
        for c=1:nx
          fprintf (fid, '%d ', array(c, b, a));
          endfor
          fprintf (fid, '\n');
          endfor
        endfor
        fclose (fid);
        status = 1;
  catch
    error ("Error writing file %s - disk full?", filename);
  end_try_catch

endfunction
