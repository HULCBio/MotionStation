## Copyright (C) 2012 Philip Nienhuis <prnienhuis@users.sf.net>
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
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## __JOD_spsh_close__ - internal function: close a spreadsheet file using JOD

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2012-10-12
## Updates:
## 2012-10-23 Style fixes
## 2013-01-20 Adapted to ML-compatible Java calls

function [ ods ] = __JOD_spsh_close__ (ods)

  try
    if (ods.changed && ods.changed < 3)
      if (isfield (ods, "nfilename"))
        ofile = javaObject ("java.io.File", ods.nfilename);
      else
        ofile = javaObject ("java.io.File", ods.filename);
      endif
      ods.workbook.saveAs (ofile);
      ods.changed = 0;
    endif
  catch
  end_try_catch

endfunction
