## Copyright (C) 2010 Kurnia Wano, Levente Torok
##.
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##.
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##.
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING. If not, see <http://www.gnu.org/licenses/>.
##

## -*- texinfo -*-
## @deftypefn {Function File} [@var{status}] = savevtkvector (@var{X}, @var{Y}, @var{Z}, @var{filename})
##
##  Save a 3-D vector field of components @var{X}, @var{Y}, @var{Z} to the file @var{filename} in VTK format. 
##
## This file format is used by Mayavi2 or ParaView for example.
##  X, Y and Z should be 3-D arrays of the same
##  size, each storing vector components in a given Cartesian direction.
##
##  If no write errors occurred, output argument @var{status} is set to 1, otherwise 0.
##
## @seealso{savevtk}
## @end deftypefn

##
## Author: Kurnia Wano, Levente Torok <TorokLev@gmail.com>
## Created: 2010-08-02 matlab version
## Updates: 2010-11-03 octave adoptatoin
##          2011-08-17 remove matlab style short-cicuit operator, indentation, help text
##

function [status] = savevtkvector (X, Y, Z, filename='vtkvector.vtk')
  
  status = 0;
  if (nargin < 4), usage ("[status] = savevtkvector (X, Y, Z, filename='vtkvector.vtk')"); endif
  if ((size(X) ~= size(Y)) || (size(X) ~= size(Z)))
    error ("Error: velocity arrays of unequal size\n");
  end
  [ny, nx, nz] = size (datax);
  xx = 1:size (datax, 2);
  yy = 1:size (datax, 1);
  zz = 1:size (datax, 3);
  datax = datax(:)';
  datay = datay(:)';
  dataz = dataz(:)';
  ## Header
  if (ischar (filename))
    [ fid, msg ] = fopen (fullfile (outputd, filename), 'w');
    if ( fid < 1 )
      error ("Cannot open the file for saving: %s", msg);
    endif
  else
    usage ("Filename expected for arg # 2");
  endif

  try
    fprintf (fid, '%s\n', '# vtk DataFile Version 3.0');
    fprintf (fid, '%s\n', '3D LFF extrapolation');
    fprintf (fid, '%s\n', 'ASCII' );
    fprintf (fid, '%s\n', 'DATASET RECTILINEAR_GRID');
    fprintf (fid, '%s %1.0i %1.0i %1.0i\n', 'DIMENSIONS',nx, ny, nz);
    fprintf (fid, '%s %1.0i %s\n', 'X_COORDINATES', nx, 'float');
    fprintf (fid, '%1.0i ', xx);
    fprintf (fid, '\n%s %1.0i %s\n', 'Y_COORDINATES', ny, 'float');
    fprintf (fid, '%1.0i ', yy);
    fprintf (fid, '\n%s %1.0i %s\n', 'Z_COORDINATES', nz, 'float');
    fprintf (fid, '%1.0i ', zz);
    ## Data
    fprintf (fid, '\n%s %1.0i','POINT_DATA', nx*ny*nz );
    fprintf (fid, '\n%s\n', 'VECTORS BFIELD float');
    fprintf (fid, '%6.2f %6.2f %6.2f\n', [datax;datay;dataz]);
    fclose (fid);
    status = 1;
  catch
    error ("Error writing file %s - disk full?", filename)
  end_try_catch

endfunction

