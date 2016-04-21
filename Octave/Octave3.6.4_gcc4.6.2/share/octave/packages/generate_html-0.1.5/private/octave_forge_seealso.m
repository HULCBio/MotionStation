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

function expanded = octave_forge_seealso (root, arg)
  header = "@html\n<div class=\"seealso\">\n<b>See also</b>: ";
  footer = "\n</div>\n@end html\n";
  
  ## XXX: Deal properly with the root directory
  format = sprintf (" <a href=\"%sfind_function.php?fun=%%s\">%%s</a> ", root);
  kw_format = sprintf (" <a href=\"%soperators.html#%%s\">%%s</a> ", root);
  
  keywords = __keywords__ ();
  
  help_list = "";
  for k = 1:length (arg)
    f = arg {k};
    if (any (strcmp (f, keywords)))
      elem = sprintf (kw_format, f, f);
    else
      elem = sprintf (format, f, f);
    endif
    help_list = strcat (help_list, elem);
  endfor
  
  expanded = strcat (header, help_list, footer);
endfunction
