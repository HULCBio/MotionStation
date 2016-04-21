## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## THIS FUNCTION SHOULD BE private

function overview_filename = get_overview_filename (options, name)
  if (isfield (options, "overview_filename"))
    overview_filename = options.overview_filename;
    overview_filename = strrep (overview_filename, "%name", name);
  else
    overview_filename = sprintf ("overview.html", name);
  endif
  
  overview_filename = strrep (overview_filename, " ", "_");
endfunction
