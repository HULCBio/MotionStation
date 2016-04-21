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
## @deftypefn {Function File} {} aminolookup ()
## @deftypefnx {Function File} {@var{aminodesc} =} aminolookup (@var{seq})
## @deftypefnx {Function File} {@var{aminodesc} =} aminolookup (@var{searchtype}, @var{seq})
## Convert between amino acid representations.  The types of input are
##
## @itemize @bullet
## @item Name
##
## The amino acid name
## @item Code
##
## The amino acid single letter code
## @item Abbreviation
##
## The three letter abbreviation for the amino acid
## @item Integer
##
## The number representation of the amino acid
## @end itemize
##
## To see the full list of each of the above, run this function without
## any arguments or outputs.
##
## If called without zero inputs, this will display the mapping between
## the above types.  If called with one input, it will convert to code by default.
## @seealso{aa2int,int2aa,int2nt,nt2int}
## @end deftypefn

## Author: Bill Denney <bill@denney.ws>

function result = aminolookup (varargin)

  persistent data

  if isempty (data)
    data.code = "ARNDCQEGHILKMFPSTWYVBZX*-";
    data.num = 1:25;

    data.abbr = {"Ala" "Arg" "Asn" "Asp" "Cys" "Gln" "Glu" "Gly" "His" \
                 "Ile" "Leu" "Lys" "Met" "Phe" "Pro" "Ser" "Thr" "Trp" \
                 "Tyr" "Val" "Asx" "Glx" "Xaa" "END" "GAP"};

    data.name = cell (numel (data.code), 3);
    data.name(:,1) = {"Alanine" "Arginine" "Asparagine" "Aspartic acid" \
                      "Cysteine" "Glutamine" "Glutamic acid" "Glycine" \
                      "Histidine" "Isoleucine" "Leucine" "Lysine" \
                      "Methionine" "Phenylalanine" "Proline" "Serine" \
                      "Threonine" "Tryptophan" "Tyrosine" "Valine" \
                      "Asparagine" "Glutamine" "Any amino acid" \
                      "Termination codon (translation stop)" \
                      "Gap of unknown length"}';
    ## Alternate names
    data.name{4,2} = "Aspartate";
    data.name{7,2} = "Glutamate";
    data.name{21,2} = "Aspartic acid";
    data.name{22,2} = "Glutamic acid";
    data.name{21,3} = "Aspartate";
    data.name{22,3} = "Glutamate";
    for i = 1:numel (data.name)
      if isempty (data.name{i})
        data.name{i} = "";
      endif
    endfor

    data.seq = {"GCU GCC GCA GCG" "CGU CGC CGA CGG AGA AGG" "AAU AAC" \
                "GAU GAC" "UGU UGC" "CAA CAG" "GAA GAG" \
                "GGU GGC GGA GGG" "CAU CAC" "AUU AUC AUA" \
                "UUA UUG CUU CUC CUA CUG" "AAA AAG" "AUG" "UUU UUC" \
                "CCU CCC CCA CCG" "UCU UCC UCA UCG AGU AGC" \
                "ACU ACC ACA ACG" "UGG" "UAU UAC" "GUU GUC GUA GUG" \
                "AAU AAC GAU GAC" "CAA CAG GAA GAG" "All codons" \
                "UAA UAG UGA" "NA"};
  endif

  searchtype = "";
  value = "";

  if (nargin == 0)
    n = cell (rows (data.name), 4);
    n(:,1) = data.name(:,1);
    for i = 1:rows (data.name)
      for j = 2:columns (data.name)
        if (! isempty (data.name{i,j}))
          n{i,1} = sprintf ("%s or %s", n{i,1}, data.name{i,j});
        endif
      endfor
      n{i,2} = num2str (i);
      n{i,3} = data.code(i);
      n{i,4} = data.seq{i};
    endfor
    s = max (cellfun (@numel, n));
    fmt = sprintf ("%%-%ds ", s(1), s(2), s(3), s(4));
    for i = 1:rows (n)
      printf ([fmt "\n"], n{i,:});
    endfor
  elseif (nargin == 1)
    showmany = 1;
    if isnumeric (varargin{1})
      ## this is an extension of the matlab options
      searchtype = "integer";
    elseif ischar (varargin{1})
      if ((mod (numel (varargin{1}), 3) == 0) &&
          (find (isupper (varargin{1})) == 1:3:numel (varargin{1})))
        ## if the number of characters is divisible by 3 and exactly
        ## every third character is upper case
        searchtype = "abbreviation";
      else
        searchtype = "code";
      endif
    endif
    value = varargin{1};
  else
    showmany = 0;
    searchtype = lower (varargin{1});
    value = varargin{2};
  endif

  if (rows (value) > 1)
    error ("aminolookup: value may only be one row")
  endif

  if (showmany == 1)
    ## we need to convert many inputs into one output.  First convert
    ## the input value into the integer form.
    switch lower (searchtype)
      case "code"
        value = upper (value);
        newvalue = -ones (size (value));
        for i = 1:numel (data.code)
          newvalue(value(:) == data.code(i)) = i;
        endfor
        outtype = "abbreviation";
      case "abbreviation"
        newvalue = -ones (1, numel (value)/3);
        for i = 1:3:numel (value)
          newvalue((i-1)/3+1) = find (strcmp (value(i:i+2), data.abbr), 1);
        endfor
        outtype = "code";
      case "integer"
        newvalue = value;
        outtype = "code";
      otherwise
        error (["aninolookup: cannot convert multiple arguments of any type\n"
                "but code, abbreviation, or integer"]);
    endswitch
    if (any (newvalue(:)) < 0)
      idx = find ((newvalue < 0) | (newvalue > numel (data.num)), 1);
      error ("aminolookup: unrecognised symbol in input at position %d", idx);
    endif

    switch outtype
      case "code"
        result = data.code(newvalue);
      case "abbreviation"
        result = strcat(data.abbr{newvalue});
      otherwise
        error ("aminolookup: invalid output type")
    endswitch
  elseif (showmany == 0)
    ## we're only showing one value
    switch lower (searchtype)
      case "integer"
        if isempty (value)
          result = ints;
        else
          result = sprintf ("%s %s %s", data.code(value), data.abbr(value), data.name(value));
        endif
      case "code"
        if isempty (value)
          result = data.code;
        else
          idx = find (lower (value) == lower(data.code), 1);
          result = sprintf ("%s %s", data.abbr{idx}, data.name{idx});
        endif
      case "abbreviation"
        if isempty (value)
          result = data.abbr;
        else
          idx = find (strcmpi (value, data.abbr));
          result = sprintf ("%s %s", data.code(idx), data.name{idx});
        endif
      case "name"
        if isempty (value)
          result = data.name;
        else
          [idx whocares] = find (strcmpi (value, data.name), 1);
          result = sprintf ("%s %s", data.code(idx), data.abbr{idx});
        endif
      otherwise
        error ("aminolookup: invalid search type, %s", searchtype)
    endswitch
  endif

endfunction

## Tests
%!shared code, abbr, ints
%! code = "MWKQAEDIRDIYDF";
%! abbr = "MetTrpLysGlnAlaGluAspIleArgAspIleTyrAspPhe";
%! ints = [13 18 12 6 1 7 4 10 2 4 10 19 4 14];
%!assert (aminolookup(code), abbr)
%!assert (aminolookup(abbr), code)
%!assert (aminolookup(ints), code)
%!assert (aminolookup("Code", "R"), "Arg Arginine")
%!assert (aminolookup("Integer", 1), "A Ala Alanine")
%!assert (aminolookup("Abbreviation", "asn"), "N Asparagine")
%!assert (aminolookup("Name", "proline"), "P Pro")
