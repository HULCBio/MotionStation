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

## __OXS_spsh_info__

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2012-10-12
## Updates:
## 2012-10-12 Moved into ./private
## 2012-10-24 Style fixes

function [sh_names] = __OXS_spsh_info__ (xls)

  sh_cnt = xls.workbook.getNumWorkSheets ();
  sh_names = cell (sh_cnt, 2); nsrows = zeros (sh_cnt, 1);
  for ii=1:sh_cnt
    sh = xls.workbook.getWorkSheet (ii-1);   ## OpenXLS starts counting at 0 
    sh_names(ii, 1) = char (sh.getSheetName());
    ## OpenXLS doesn't distinguish between worksheets and graph sheets
    [tr, lr, lc, rc] = getusedrange (xls, ii);
    if (tr)
      sh_names(ii, 2) = ...
        sprintf ("%s:%s", calccelladdress (tr, lc), calccelladdress (lr, rc));
    else
      sh_names(ii, 2) = "Empty or Chart";
    endif
  endfor

endfunction
