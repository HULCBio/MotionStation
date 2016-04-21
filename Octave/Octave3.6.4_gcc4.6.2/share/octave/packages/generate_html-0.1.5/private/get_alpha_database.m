## Copyright (C) 2009 Soren Hauberg <soren@hauberg.org>
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

function [name_filename, desc_filename] = get_alpha_database (outdir, name, letter);
  directory = fullfile (outdir, name);
  if (!exist (directory, "dir"))
    [succ, msg] = mkdir (directory);
    if (!succ)
      error ("get_alpha_database: could not create '%s': %s", directory, msg);
    endif
  endif
  
  name_filename = fullfile (directory, sprintf ("function_names_%s", letter));
  desc_filename = fullfile (directory, sprintf ("function_descriptions_%s", letter));
endfunction

