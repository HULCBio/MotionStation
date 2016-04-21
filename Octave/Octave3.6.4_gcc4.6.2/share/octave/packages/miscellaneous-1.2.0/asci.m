## Copyright (C) 2008, Thomas Treichl <thomas.treichl@gmx.net>
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
## @deftypefn {Function} {[@var{string}] =} asci ([@var{columns}])
## Print ASCI table.
##
## If this function is called without any input argument and without any output
## argument then print a nice ASCI-table (excluding special characters with
## hexcode 0x00 to 0x20) on screen with four columns per default. If this
## function is called with one output argument then return an ASCI-table string
## and don't print anything on screen. Finally, if this function is called with
## one input argument of type scalar then either print (no output argument) or
## return (one output argument) an ASCI-table with a number of columns given in
## @var{columns}.
##
## For example,
## @example
## A = asci (3);
## disp (A);
## @end example
## @end deftypefn

function [varargout] = asci (varargin)

  %# Check number and types of input arguments
  if (nargin == 0)
    vcol = 4;
  elseif (isnumeric (varargin{1}) && \
          isequal (size (varargin{1}), [1, 1]))
    vcol = floor (varargin{1});
  else
    print_usage ();
  endif

  %# First char is #32 (0x20) and last char is #128 (0x80)
  vtab = "";
  voff = floor ((128 - 32) / vcol);

  %# Print a first row for the and underline that row
  for vcnt = 1:vcol
    vtab = sprintf ("%s Dec Hex Chr ", vtab);
  endfor
  vtab = sprintf ("%s\n", vtab);

  for vcnt = 1:vcol
    vtab = sprintf ("%s-------------", vtab);
  endfor
  vtab = sprintf ("%s\n", vtab);

  %# Create the lines and columns of the asci table
  for vpos = 32:(32+voff)
    for vcnt = 1:vcol
      vact = (vcnt-1)*voff+vpos;
      vstr = {num2str(vact), dec2hex(vact), char(vact)};
      for vctn = 1:length (vstr)
        vtab = sprintf ("%s %3s", vtab, vstr{vctn});
      endfor
      vtab = sprintf ("%s ", vtab);
    endfor
    vtab = sprintf ("%s\n", vtab);
  endfor
  vtab = sprintf ("%s\n", vtab);

  %# Print table to screen or return it to output argument
  if (nargout == 0)
    printf ("%s", vtab);
  elseif (nargout == 1)
    varargout{1} = vtab;
  endif
endfunction

%!test
%!  A = asci ();
%!test
%!  A = asci (2);
