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

function [file_list, file_pattern] = get_txi_files (srcdir)
  txi_dir = fullfile (srcdir, "doc", "interpreter");
  octave_texi = fullfile (txi_dir, "octave.texi");
  file_pattern = fullfile (txi_dir, "*.txi");
  include = "@include";
  
  fid = fopen (octave_texi, "r");
  file_list = {};
  while (true)
    line = fgetl (fid);
    if (line == -1)
      break;
    endif
    
    n = min (length (include), length (line));
    if (strcmp (line (1:n), include))
      fun = strtrim (line (n+1:end));
      if (strcmpi (fun, "conf.texi"))
        continue;
      endif
      fun = strrep (fun, ".texi", ".txi");
      file_list {end+1} = fullfile (txi_dir, fun);
    endif
  endwhile
  fclose (fid);
endfunction

function [file_list, file_pattern] = old_get_txi_files (srcdir)
  file_pattern = fullfile (txi_dir, "*.txi");
  fl = dir(file_pattern);
  file_list = {};
  for k = 1:length (fl)
    if (any (strcmpi (fl (k).name, {".", ".."})))
      continue;
    endif
    file_list {end+1} = fullfile (txi_dir, fl (k).name);
  endfor
endfunction
