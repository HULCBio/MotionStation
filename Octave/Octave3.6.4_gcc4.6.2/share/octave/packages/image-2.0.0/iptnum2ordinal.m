## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {@var{ord} =} iptnum2ordinal (@var{num})
## Convert number to ordinal string.
##
## @var{num} must be a real positive integer which will be converted to a string
## with its ordinal form @var{ord}.
##
## @example
## @group
## iptnum2ordinal (1)
##       @result{} first
## iptnum2ordinal (12)
##      @result{} twelfth
## iptnum2ordinal (21)
##      @result{} 21st
## @end group
## @end example
##
## @seealso{num2str, sprintf, int2str, mat2str}
## @end deftypefn

function ord = iptnum2ordinal (num)

  ## thanks to Skei in ##matlab for checking the grammar of ordinals and that it
  ## is after number 20 that it starts using the suffixes only

  ## thanks to porten in ##matlab for help checking these corner-cases
  ## the following were test and failed: Inf, 0, -1, 3.4, 1e-7
  ## using a string kind of succeeded as the character position in the ascii
  ## table as used for the conversion

  if (nargin != 1)
    print_usage;
  elseif (!isnumeric (num) || !isscalar (num) || !isreal (num) || num <= 0 || rem (num, 1) != 0)
    error ("num must be a real positive integer");
  endif

  switch num
    case {1}  ord = "first";
    case {2}  ord = "second";
    case {3}  ord = "third";
    case {4}  ord = "fourth";
    case {5}  ord = "fifth";
    case {6}  ord = "sixth";
    case {7}  ord = "seventh";
    case {8}  ord = "eighth";
    case {9}  ord = "ninth";
    case {10} ord = "tenth";
    case {11} ord = "eleventh";
    case {12} ord = "twelfth";
    case {13} ord = "thirteenth";
    case {14} ord = "fourteenth";
    case {15} ord = "fifteenth";
    case {16} ord = "sixteenth";
    case {17} ord = "seventeenth";
    case {18} ord = "eighteenth";
    case {19} ord = "nineteenth";
    case {20} ord = "twentieth";
    otherwise
      ## if we ever want to mimic matlab's defective behaviour of accepting a
      ## string and return the ordinal of position on the ascii table, we must
      ## check here if it's a string, and if so, use:
      ## ord = sprintf ("%dth", num);
      num = num2str (num);
      switch num(end)
        case {"1"} ord = strcat (num, "st");
        case {"2"} ord = strcat (num, "nd");
        case {"3"} ord = strcat (num, "rd");
        otherwise  ord = strcat (num, "th");
      endswitch
  endswitch

endfunction

%!assert (strcmp (iptnum2ordinal (1), 'first'));    # simple works
%!assert (strcmp (iptnum2ordinal (21), '21st'));    # after 20, goes stupid
%!assert (strcmp (iptnum2ordinal (100), '100th'));  # use th correctly
%!fail ("iptnum2ordinal (inf)");                    # must be real
%!fail ("iptnum2ordinal (0)");                      # must be positive
%!fail ("iptnum2ordinal (-1)");                     # must be positive
%!fail ("iptnum2ordinal (3.4)");                    # must be integer
