## Copyright (C) 2009 VZLU Prague, a.s., Czech Republic
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.
## -*- texinfo -*-
## @deftypefn{Function File} display (d)
## Overloaded display for dictionaries.
## @end deftypefn

## Author: Jaroslav Hajek <highegg@gmail.com>

function display (d)
  if (isempty (d.keys))
    printf ("%s = dict: {}\n", argn);
  else
    printf ("%s = \n\n", argn);
    n = numel (d.keys);
    puts ("dict: {\n");
    for i = 1:n
      keystr = d.keys{i};
      valstr = disp (d.values{i});
      if (any (valstr(1:end-1) == "\n"))
        valstr = strrep (valstr, "\n", "\n    ");
        printf ("  %s :\n\n    %s", keystr, valstr(1:end-4));
      else
        printf ("  %s : %s", keystr, valstr);
      endif
    endfor
    puts ("}\n");
  endif
endfunction
