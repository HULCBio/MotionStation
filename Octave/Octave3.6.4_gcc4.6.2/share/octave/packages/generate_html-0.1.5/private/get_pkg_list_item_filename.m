## Copyright (C) 2009 Carlo de Falco <carlo.defalco@gmail.com>
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

function pkg_list_item_filename = get_pkg_list_item_filename (name, outdir)

  filename = "short_package_description";
  ld = fullfile (outdir, name);
  
  if (!exist (ld, "dir"))
    [succ, msg] = mkdir (ld);
    if (!succ)
      error ("generate_package_html: unable to create directory %s:\n %s", 
	     ld, msg);
    endif
  endif

  pkg_list_item_filename = fullfile (ld, filename);
  
endfunction

