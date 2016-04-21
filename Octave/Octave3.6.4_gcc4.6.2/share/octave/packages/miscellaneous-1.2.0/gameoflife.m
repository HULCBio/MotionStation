## Copyright (C) 2010 VZLU Prague, a.s.
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
## @deftypefn{Function File} {B =} gameoflife (A, ngen, delay)
## Runs the Conways' game of life from a given initial state for a given
## number of generations and visualizes the process.
## If ngen is infinity, the process is run as long as A changes.
## Delay sets the pause between two frames. If zero, visualization is not done.
## @end deftypefn

function B = gameoflife (A, ngen, delay = 0.2)
  B = A != 0;
  igen = 0;
  CSI = char ([27, 91]);

  oldpso = page_screen_output (delay != 0);
  unwind_protect

    if (delay > 0)
      puts (["\n", CSI, "s"]);
      printf ("generation 0\n");
      colorboard (! B);
      pause (delay);
    endif

    while (igen < ngen)
      C = conv2 (B, ones (3), "same") - B;
      B1 = C == 3 | (B & C == 2);
      igen++;
      if (isinf (ngen) && all ((B1 == B)(:)))
        break;
      endif
      B = B1;
      if (delay > 0)
        puts (["\n", CSI, "u"]);
        printf ("generation %d\n", igen);
        colorboard (! B);
        pause (delay);
      endif
    endwhile

  unwind_protect_cleanup
    page_screen_output (oldpso);
  end_unwind_protect

endfunction
