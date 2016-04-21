## Copyright (C) 2012 Markus Bergholz <markuman@gmail.com>
## Copyright (C) 2012 carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {} textable (@var{matrix})
## @deftypefnx {Function File} {} textable (@var{matrix}, @var{params}, @dots{})
## Save @var{matrix} in LaTeX format (tabular or array).
##
## The input matrix must be numeric and two dimensional.
##
## The generated LaTeX source can be saved directly to a file with the option
## @command{file}. The file can then be inserted in any latex document by using
## the @code{\input@{latex file name without .tex@}} statement.
##
## Available parameters are:
## @itemize @bullet
## @item @code{file}: filename to save the generated LaTeX source. Requires a string
## as value.
## @item @code{rlines}: display row lines.
## @item @code{clines}: display column lines.
## @item @code{align}: column alignment. Valid values are `l', `c' and `r' for
## center, left and right (default).
## @item @code{math}: create table in array environment inside displaymath
## environment. It requires a string as value which will be the name of the matrix.
## @end itemize
##
## The basic usage is to generate the source for a table without lines and right
## alignment (default values):
## @example
## @group
## textable (data)
##     @result{}
##        \begin@{tabular@}@{rrr@}
##            0.889283 & 0.949328 & 0.205663 \\
##            0.225978 & 0.426528 & 0.189561 \\
##            0.245896 & 0.466162 & 0.225864 \\
##        \end@{tabular@}
## @end group
## @end example
##
## Alternatively, the source can be saved directly into a file:
## @example
## @group
## textable (data, "file", "data.tex");
## @end group
## @end example
##
## The appearance of the table can be controled with switches and key values. The
## following generates a table with both row and column lines (rlines and clines),
## and center alignment:
## @example
## @group
## textable (data, "rlines", "clines", "align", "c")
##     @result{}
##        \begin@{tabular@}@{|c|c|c|@}
##            \hline 
##            0.889283 & 0.949328 & 0.205663 \\
##            \hline 
##            0.225978 & 0.426528 & 0.189561 \\
##            \hline 
##            0.245896 & 0.466162 & 0.225864 \\
##            \hline 
##        \end@{tabular@}
## @end group
## @end example
##
## Finnally, for math mode, it is also possible to place the matrix in an array
## environment and name the matrix:
## @example
## @group
## textable (data, "math", "matrix-name")
##     @result{}
##        \begin@{displaymath@}
##          \mathbf@{matrix-name@} =
##          \left(
##          \begin@{array@}@{*@{ 3 @}@{rrr@}@}
##            0.889283 & 0.949328 & 0.205663 \\
##            0.225978 & 0.426528 & 0.189561 \\
##            0.245896 & 0.466162 & 0.225864 \\
##          \end@{array@}
##          \right)
##        \end@{displaymath@}
## @end group
## @end example
##
## @seealso{csv2latex, publish}
## @end deftypefn

function [str] = textable (data, varargin)

  if (nargin < 1)
    print_usage;
  elseif (!isnumeric (data) || !ismatrix (data)|| ndims (data) != 2)
    error ("first argument must be a 2D numeric matrix");
  endif

  p = inputParser;
  p = p.addSwitch ("clines");
  p = p.addSwitch ("rlines");
  p = p.addParamValue ("math", "X", @ischar);
  p = p.addParamValue ("file", "matrix.tex", @ischar);
  p = p.addParamValue ("align", "r", @(x) any(strcmpi(x, {"l", "c", "r"})));
  p = p.parse (varargin{:});

  ## if there is no filename given we won't print to file
  print_to_file = all (!strcmp ("file", p.UsingDefaults));

  ## will we use an array environment (in displaymath)
  math = all (!strcmp ("math", p.UsingDefaults));

  if (p.Results.clines)
    align = sprintf ("|%s", repmat (cstrcat (p.Results.align, "|"), [1, columns(data)]));
    ## if we are in a array environment, we need to remove the last | or we end
    ## with two lines at the end
    if (math), align = align(1:end-1); endif
  else
    align = sprintf ("%s", repmat (p.Results.align, [1, columns(data)]));
  endif

  ## start making table
  if (math)
    str = "\\begin{displaymath}\n";
    str = strcat (str, sprintf ("  \\mathbf{%s} =\n", p.Results.math));
    str = strcat (str,          "  \\left(\n");
    str = strcat (str, sprintf ("  \\begin{array}{*{ %d }{%s}}\n", columns (data), align));
  else
    str = sprintf ("\\begin{tabular}{%s}\n", align);
  endif

  if (p.Results.rlines)
    str = strcat (str, "    \\hline \n");
  endif

  for ii = 1:rows(data)
    str = strcat (str, sprintf ("    %g", data (ii, 1)));
    str = strcat (str, sprintf (" & %g", data (ii, 2:end)));
    str = strcat (str, " \\\\\n");
    if (p.Results.rlines)
      str = strcat (str, "    \\hline \n");
    endif
  endfor

  if (math)
    str = strcat (str, "  \\end{array}\n  \\right)\n\\end{displaymath}");
  else
    str = strcat (str, "\\end{tabular}\n");
  endif

  if (print_to_file)
    [fid, msg] = fopen (p.Results.file, "w");
    if (fid == -1)
      error ("Could not fopen file '%s' for writing: %s", p.Results.file, msg);
    endif
    fputs (fid, str);
    fclose (fid);
  endif
endfunction
