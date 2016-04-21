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
## @deftypefn {Function File} {@var{seqr} =} seqreverse (@var{seqf})
## Reverse a nucleotide sequence.  @var{seqf} can be either a numeric or
## code DNA or RNA sequence or a struct with the field sequence, and it
## will reverse the direction of the sequence.
## @seealso{seqcomplement, seqrcomplement}
## @end deftypefn

## Author: Bill Denney <bill@denney.ws>

function s = seqreverse (seqf)

  if isstruct (seqf)
    s = seqf.sequence;
  else
    s = seqf;
  endif

  if (rows (s) != 1)
    error ("seqreverse: the sequence must have a single row");
  endif
  s = fliplr (s);
  if isstruct (seqf)
    seqf.sequence = s;
    s = seqf;
  endif
endfunction

## Tests
%!assert (seqreverse ("ATCG"), "GCTA")
%!assert (seqreverse (struct ("sequence", "ATCG")), struct ("sequence", "GCTA"));
