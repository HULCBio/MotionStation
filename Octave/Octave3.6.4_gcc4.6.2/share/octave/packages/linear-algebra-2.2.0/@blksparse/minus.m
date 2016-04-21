## Copyright (C) 2010 VZLU Prague
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

function s = minus (s1, s2)
  if (isa (s1, "blksparse") && isa (s2, "blksparse"))
    ## Conformance check.
    siz1 = s1.siz;
    bsiz1 = s1.bsiz;
    siz2 = s2.siz;
    bsiz2 = s2.bsiz;
    if (bsiz1(2) != bsiz2(1))
      gripe_nonconformant (bsiz1, bsiz2, "block sizes");
    elseif (siz1(2) != siz2(1))
      gripe_nonconformant (bsiz1.*siz1, bsiz2.*siz2);
    endif

    ## Stupid & simple.
    s = blksparse ([s1.i; s2.i], [s1.j; s2.j], cat (3, s1.sv, -s2.sv), siz1(1), siz1(2));
  else
    error ("blksparse: only blksparse - blksparse implemented");
  endif
endfunction

function gripe_nonconformant (s1, s2, what = "arguments")
  error ("Octave:nonconformant-args", ...
  "nonconformant %s (op1 is %dx%d, op2 is %dx%d)", what, s1, s2);
endfunction
