## Copyright (C) 2010, 2011, 2012   Lukas F. Reichlin
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## Subscripted reference for quaternions.  Used by Octave for "q.w".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.4

function ret = subsref (q, s)

  if (numel (s) == 0)
    ret = q;
    return;
  endif

  switch (s(1).type)
    case "."                                # q.w
      switch (tolower (s(1).subs))
        case {"w", "s", "e"}                # scalar part
          ret = subsref (q.w, s(2:end));
        case {"x", "i"}
          ret = subsref (q.x, s(2:end));
        case {"y", "j"}
          ret = subsref (q.y, s(2:end));
        case {"z", "k"}
          ret = subsref (q.z, s(2:end));
        case "v"                            # vector part, scalar part set to zero
          q.w = zeros (size (q.w));
          ret = subsref (q, s(2:end));
        otherwise
          error ("quaternion: invalid subscript name '%s'", s(1).subs);
      endswitch

    case "()"                               # q(...)
      w = subsref (q.w, s(1));
      x = subsref (q.x, s(1));
      y = subsref (q.y, s(1));
      z = subsref (q.z, s(1));
      tmp = quaternion (w, x, y, z);
      ret = subsref (tmp, s(2:end));
      
    otherwise
      error ("quaternion: invalid subscript type '%s'", s(1).type);
  endswitch

endfunction
