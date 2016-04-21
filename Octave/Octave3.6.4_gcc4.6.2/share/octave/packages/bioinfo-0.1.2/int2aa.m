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
## @deftypefn {Function File} {@var{sequencechar} =} int2aa (@var{sequenceint})
## Convert amino acid integers into characters.  See @code{aminolookup}
## for the listing of numbers and their corresponding characters.
## @seealso{aminolookup,aa2int,int2nt,nt2int}
## @end deftypefn

## Author: Bill Denney <bill@denney.ws>

function seqc = int2aa (seqi)

  if (! isnumeric (seqi))
    print_usage ();
  endif
  sequences = aminolookup ("code", []);
  seqc = reshape (sequences(seqi), size (seqi));
endfunction

## Tests
%!assert (int2aa (1), "A")
%!assert (int2aa ([1 2]), "AR");
%!assert (int2aa ([1;2]), ["A";"R"])
