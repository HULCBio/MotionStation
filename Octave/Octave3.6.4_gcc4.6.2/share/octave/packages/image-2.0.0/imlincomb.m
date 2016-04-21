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
## @deftypefn {Function File} {@var{out} =} imlincomb (@var{fac}, @var{img})
## @deftypefnx {Function File} {@var{out} =} imlincomb (@var{fac1}, @var{img1}, @var{fac2}, @var{img2}, @dots{})
## @deftypefnx {Function File} {@var{out} =} imlincomb (@dots{}, @var{class})
## Combine images linearly.
##
## Returns the computed image as per:
##
## @var{out} = @var{fac}1*@var{img}1 + @var{fac}2*@var{img}2 + @dots{} + @var{fac}n*@var{img}n
##
## The images @var{img}1..n must all be of same size and class. The factors @var{fac}1..n
## must all be floating-point scalars.
##
## The class of @var{out} will be the same as @var{img}s unless @var{img}s are logical
## in which case @var{out} will be double. Alternatively, it can be specified
## with @var{class}.
##
## If applying several arithmetic operations on images, @code{imlincomb} is more
## precise since calculations are performed at double precision.
##
## @emph{Note 1}: you can force output class to be logical by specifying
## @var{class} though it possibly doesn't make a lot of sense.
##
## @seealso{imadd, imcomplement, imdivide, immultiply, imsubtract}
## @end deftypefn

function out = imlincomb (varargin)

  if (nargin < 2)
    print_usage;
  else
    if (rem (nargin, 2) == 0)
      ## use default for output class; the class of first image (second argument)
      out_class = class (varargin{2});
      def_class = true;
    else
      ## last argument is requested output class
      out_class = varargin{end};
      def_class = false;
    endif
  endif

  facI = 1:2:nargin-1;        # index for factors
  imgI = 2:2:nargin;          # index for images
  imgC = class (varargin{2}); # class of the first image

  out = zeros (size (varargin{2}));
  for i = 1:numel (imgI)
    ## we keep index the images froom varargin rather than copying to new variable to
    ## avoid taking up a lot of memory
    if (!isreal (varargin{facI(i)}) || !isscalar (varargin{facI(i)}) || !isfloat (varargin{facI(i)}))
      error ("factor to multiply each image must be a real, floating-point, scalar.");
    elseif ((!isnumeric (varargin{imgI(i)}) && !islogical (varargin{imgI(i)})) ...
                || isempty (varargin{imgI(i)}) || issparse (varargin{imgI(i)}) ...
                || !isreal (varargin{imgI(i)}) || !isa (varargin{imgI(i)}, imgC))
      error ("images must be a numeric or logical, non-empty, non-sparse real matrix of the same class.");
    endif
    img  = double(varargin{imgI(i)}) .* double(varargin{facI(i)});
    out += img;
  endfor

  ## this is probably matlab imcompatible since by their documentation, they don't even
  ## support logical matrix. If specified by user, respect and return a logical
  ## matrix. Otherwise, return a double, even if images were all logical
  if (strcmpi (out_class, "logical") && def_class)
    cnv = @double;
  else
    cnv = str2func (tolower (out_class));
  endif
  out = cnv (out);

endfunction

%!assert (imlincomb (0.5, uint8 ([255 10]), 0.5, uint8 ([50 20])),           uint8  ([153 15])); # default to first class and truncate
%!assert (imlincomb (0.5, uint8 ([255 10]), 0.5, uint8 ([50 20]), "uint16"), uint16 ([153 15])); # defining output class works
