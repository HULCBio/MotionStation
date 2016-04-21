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
## @deftypefn {Function File} {@var{fragments} =} cleave (@var{sequence}, @var{pattern}, @var{position})
## @deftypefnx {Function File} {[@var{fragments}, @var{cuttingsites}] =} cleave (@dots{})
## @deftypefnx {Function File} {[@var{fragments}, @var{cuttingsites}, @var{lengths}] =} cleave (@dots{})
## @deftypefnx {Function File} {[@dots{}] =} cleave (@dots{}, "PartialDigest", @var{prob})
## Cleave a peptide @var{sequence} using the @var{pattern} at the
## @var{position} relative to the pattern.  The @var{sequence} is a
## sequence of amino acids; the @var{pattern} is a regular expression to
## find the location of the cleavage; and the @var{position} is the
## position relative to that regular expression (0 is immediately to the
## left of the first character, 1 is immediately to the right of the
## first character, @dots{}).
##
## Example regular expressions for some commone proteases are given
## below.
##
## @multitable @columnfractions .5 .3 .2
## @item Protease @tab Peptide Pattern @tab Position
## @item Trypsin @tab [KR](?!P) @tab 1
## @item Chymotrypsin @tab [WYF](?!P) @tab 1
## @item Glutamine C @tab [ED](?!P)  @tab 1
## @item Lysine C @tab [K](?!P)  @tab 1
## @item Aspartic acid N @tab D @tab 1
## @end multitable
##
## @seealso{rebasecuts, restrict, seqshowwords, regexp}
## @end deftypefn

## Author: Bill Denney <bill@denney.ws>

function [fragments, s, lengths] = cleave (seq, pattern, pos, varargin)

  if isstruct (seq)
    seq = seq.sequence;
  endif
  if (rows (seq) != 1)
    error ("seqreverse: the sequence must have a single row");
  endif
  if (! isempty (varargin))
    ## FIXME: add support for partialdigest
    error ("cleave: additional parameters are not yet supported")
  endif

  s = [0 (pos - 1 + regexp (seq, pattern))];
  ## There is no cleavage at the end-- there was already a cleavage
  ## there.
  if (s(end) == length(seq))
  s(end) = [];
  endif
  fragments = cell (size (s));
  lengths = [s(2:end) length(seq)] - s;
  for i = 1:numel (s)
    fragments{i} = seq(s(i)+1:s(i)+lengths(i));
  endfor

endfunction

## Tests
%!test
%! site = [0 6 7 41 46 67 74 80 92 100];
%! len = [6 1 34 5 21 7 6 12 8 10];
%! frag = {"MGTGGR" "R" "GAAAAPLLVAVAALLLGAAGHLYPGEVCPGMDIR" "NNLTR" \
%!         "LHELENCSVIEGHLQILLMFK" "TRPEDFR" "DLSFPK" "LIMITDYLLLFR" \
%!         "VYGLESLK" "DLFPNLTVIR"};
%! seq = strcat (frag{:});
%! [tfrag, tsite, tlen] = cleave (seq, '[KR](?!P)', 1);
%! assert (tfrag, frag)
%! assert (tsite, site)
%! assert (tlen, len)
## FIXME: This needs a test for partialdigest.
