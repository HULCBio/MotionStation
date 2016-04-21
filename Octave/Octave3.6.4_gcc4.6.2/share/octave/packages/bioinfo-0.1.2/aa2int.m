## Copyright (C) 2008 Bill Denney
##
## This software is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{sequenceint} =} aa2int (@var{sequencechar})
## Convert amino acid characters into integers.  See @code{aminolookup}
## for the listing of numbers and their corresponding characters.
## @seealso{aminolookup,int2aa,int2nt,nt2int}
## @end deftypefn

## Author: Bill Denney <bill@denney.ws>

function seqi = aa2int (seqc=0)

  if (! ischar (seqc))
    print_usage ();
  endif
  sequences = aminolookup ("code", []);

  seqi = -ones (size (seqc));
  seqc = upper (seqc);
  for i = 1:numel (sequences)
    seqi(sequences(i) == seqc) = i;
  endfor
  if any (seqi(:) < 0)
    idx = find (seqi(:) < 0, 1);
    error ("aa2int: unrecognised character (%s) in sequence input at position (%d)",
           seqc(idx), idx)
  endif

endfunction

## Tests
%!assert (aa2int ("a"), 1)
%!assert (aa2int ("ar"), [1 2])
%!assert (aa2int (["ar"]'), [1;2])
