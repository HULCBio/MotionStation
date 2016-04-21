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

function root = get_root (outdir, subdir)
  web_sep = '/';
  
  if (outdir (end) == web_sep)
    outdir (end) = [];
  endif
  
  if (subdir (end) == web_sep)
    subdir (end) = [];
  endif
  
  n = sum (subdir == web_sep) - sum (outdir == web_sep);
  root = repmat ("../", 1, n);
endfunction
