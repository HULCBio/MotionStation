## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {@var{rval} =} cstrcmp (@var{s1}, @var{s2})
## Compare strings @var{s1} and @var{s2} like the C function.
##
## Aside the difference to the return values, this function API is exactly the
## same as Octave's @code{strcmp} and will accept cell arrays as well.
##
## @var{rval} indicates the relationship between the strings:
## @itemize @bullet
## @item
## A value of 0 indicates that both strings are equal;
## @item
## A value of +1 indicates that the first character that does not match has a
## greater value in @var{s1} than in @var{s2}.
## @item
## A value of -1 indicates that the first character that does not match has a
## match has a smaller value in @var{s1} than in @var{s2}.
## @end itemize
##
## @example
## @group
## cstrcmp("marry","marry")
##       @result{}  0
## cstrcmp("marry","marri")
##       @result{} +1
## cstrcmp("marri","marry")
##       @result{} -1
## @end group
## @end example
##
## @seealso {strcmp, strcmpi}
## @end deftypefn

function rval = cstrcmp (s1, s2)

  if (nargin != 2)
    print_usage();
  endif

  ## this function is just like Octave's strcmp but the 0 and 1 need to be
  ## inverted. Once is done, if there are 1, we need to decide if they will
  ## be positive or negative. Also, since it's possible that the value needs
  ## to be negative, class must be double (strcmp returns logical)
  rval = double(!strcmp (s1, s2));

  if (!any (rval))
    ## all zeros, no need to do anything else
    return
  endif

  ## get index of the ones we have to "fix"
  idx = find (rval == 1);
  ## if any is not a cell, this simplifies the code that follows
  if (!iscell (s1)), s1 = {s1}; endif
  if (!iscell (s2)), s2 = {s2}; endif
  ## there's 2 hypothesis:
  ##  - arrays have same length (even if it's only one cell)
  ##  - arrays have different lengths (in which case, one will have a single cell)
  if (numel (s1) == numel (s2))
    rval(idx) = cellfun (@get_sign, s1(idx), s2(idx));
  elseif (numel (s1) > 1)
    rval(idx) = cellfun (@get_sign, s1(idx), s2(1));
  elseif (numel (s2) > 1)
    rval(idx) = cellfun (@get_sign, s1(1), s2(idx));
  endif
endfunction

function r = get_sign (s1, s2)
  ## strings may have different lengths which kinda complicates things
  ## in case the strings are of different size, we need to make them equal
  ## If once "trimmed", the strings are equal, the "shortest" string is
  ## considered smaller since the comparison is made by filling it with null

  ns1  = numel (s1);
  ns2  = numel (s2);
  nmin = min (ns1, ns2);

  ## if one of the strings is empty, we are already done
  if (nmin == 0), r = sign (ns1 - ns2); return endif

  s  = sign (s1(1:nmin) - s2(1:nmin));
  if (any (s))
    ## if there's any difference between this part of the two strings, get the
    ## index of the first occurence and return its value
    r = s(find (s != 0, 1));
  else
    r = sign (ns1 - ns2);
  endif
endfunction

%!assert(cstrcmp("hello","hello"),0);
%!assert(cstrcmp("marry","marie"),+1);
%!assert(cstrcmp("Matlab","Octave"),-1);
%!assert(cstrcmp("Matlab",{"Octave","Scilab","Lush"}), [-1 -1 +1]);
%!assert(cstrcmp({"Octave","Scilab","Lush"},"Matlab"), [+1 +1 -1]);
