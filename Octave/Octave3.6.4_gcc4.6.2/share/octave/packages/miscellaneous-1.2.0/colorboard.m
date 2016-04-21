## Copyright (C) 2009 VZLU Prague, a.s.
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
## @deftypefn{Function File} colorboard (@var{m}, @var{palette}, @var{options})
## Displays a color board corresponding to a numeric matrix @var{m}.
## @var{m} should contain zero-based indices of colors.
## The available range of indices is given by the @var{palette} argument,
## which can be one of the following:
##
## @itemize
## @item "b&w"
##   Black & white, using reverse video mode. This is the default if @var{m} is logical.
## @item "ansi8"
##   The standard ANSI 8 color palette. This is the default unless @var{m} is logical.
## @item "aix16"
##   The AIXTerm extended 16-color palette. Uses codes 100:107 for bright colors.
## @item "xterm16"
##   The first 16 system colors of the Xterm 256-color palette.
## @item "xterm216"
##   The 6x6x6 color cube of the Xterm 256-color palette.
##   In this case, matrix can also be passed as a MxNx3 RGB array with values 0..5.
## @item "grayscale"
##   The 24 grayscale levels of the Xterm 256-color palette.
## @item "xterm256"
##   The full Xterm 256-color palette. The three above palettes together.
## @end itemize
##
## @var{options} comprises additional options. The recognized options are:
## 
## @itemize
## @item "indent"
##   The number of spaces by which the board is indented. Default 2.
## @item "spaces"
##   The number of spaces forming one field. Default 2.
## @item "horizontalseparator"
##   The character used for horizontal separation of the table. Default "#".
## @item "verticalseparator"
##   The character used for vertical separation of the table. Default "|".
## @end itemize
## @end deftypefn

function colorboard (m, palette, varargin)
  if (nargin < 1)
    print_usage ();
  endif

  nopt = length (varargin);

  ## default options

  indent = 2;
  spc = 2;
  vsep = "|";
  hsep = "#";

  ## parse options

  while (nopt > 1)
    switch (tolower (varargin{nopt-1}))
    case "indent"
      indent = varargin{nopt};
    case "spaces"
      spc = varargin{nopt};
    case "verticalseparator"
      vsep = varargin{nopt};
    case "horizontalseparator"
      hsep = varargin{nopt};
    otherwise
      error ("unknown option: %s", varargin{nopt-1});
    endswitch
    nopt -= 2;
  endwhile

  if (nargin == 1)
    if (islogical (m))
      palette = "b&w";
    else
      palette = "ansi8";
    endif
  endif

  persistent digs = char (48:55); # digits 0..7

  switch (palette)
  case "b&w"
    colors = ["07"; "27"];
  case "ansi8"
    i = ones (1, 8);
    colors = (["4"(i, 1), digs.']);
  case "aix16"
    i = ones (1, 8);
    colors = (["04"(i, :), digs.'; "10"(i, :), digs.']);
  case "xterm16"
    colors = xterm_palette (0:15);
  case "xterm216"
    colors = xterm_palette (16:231);
    if (size (m, 3) == 3)
      m = (m(:,:,1)*6 + m(:,:,2))*6 + m(:,:,3);
    endif
  case "grayscale"
    colors = xterm_palette (232:255);
  case "xterm256"
    colors = xterm_palette (0:255);
  otherwise
    error ("colorboard: invalid palette");
  endswitch

  nc = rows (colors);

  persistent esc = char (27);
  escl = [esc, "["](ones (1, nc), :);
  escr = ["m", blanks(spc)](ones (1, nc), :);

  colors = [escl, colors, escr].';

  [rm, cm] = size (m);

  if (isreal (m) && max (m(:)) <= 1)
    m = min (floor (nc * m), nc-1);
  endif

  try
    board = reshape (colors(:, m + 1), [], rm, cm);
  catch
    error ("colorboard: m is not a valid index into palette");
  end_try_catch

  board = permute (board, [2, 1, 3])(:, :);

  persistent reset = [esc, "[0m"];

  indent = blanks (indent);
  vline = [indent, hsep(1, ones (1, spc*cm+2))];
  hlinel = [indent, vsep](ones (1, rm), :);
  hliner = [reset, vsep](ones (1, rm), :);

  oldpso = page_screen_output (0);
  unwind_protect

    disp ("");
    disp (vline);
    disp ([hlinel, board, hliner]);
    disp (vline);
    disp ("");

    puts (reset); # reset terminal

  unwind_protect_cleanup
    page_screen_output (oldpso);
  end_unwind_protect

endfunction

function pal = xterm_palette (r)
  if (max (r) < 100)
    fmt = "48;5;%02d"; l = 7;
  else
    fmt = "48;5;%03d"; l = 8;
  endif
  pal = reshape (sprintf (fmt, r), l, length (r)).';
endfunction
