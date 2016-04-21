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

function [location, full_location] = mk_function_dir (outdir, options)
  if (isfield (options, "function_dir"))
    location = options.function_dir;
  else
    location = "function";
  endif
  
  full_location = fullfile (outdir, location);
  %location = strcat (outdir, "/", location);
  
  ## Create output directory if needed
  if (!exist (full_location, "dir"))
    mkdir (full_location);
  endif

endfunction
