## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
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
## @deftypefn {Function File} @var{bool} = isbw (@var{img})
## @deftypefnx {Function File} @var{bool} = isbw (@var{img}, @var{logic})
## Return true if @var{img} is a black and white image.
##
## The optional argument @var{logic} defines what is considered a black and
## white image. Possible values are the strings `logical' or `non-logical'. The
## first defines it as a logical matrix, while the second defines it as a matrix
## where the only values are 1 and 0. Defaults to `logical'.
##
## @seealso{isgray, isind, islogical, isrgb}
## @end deftypefn

function bool = isbw (BW, logic = "logical")
  ## this function has been removed from version 7.3 (R2011b) of
  ## matlab's image processing toolbox
  if (nargin < 1 || nargin > 2)
    print_usage;
  elseif (!ischar (logic) && any (strcmpi (logic, {"logical", "non-logical"})))
    error ("second argument must either be a string 'logical' or 'non-logical'")
  endif

  bool = false;
  if (!isimage (BW))
    bool = false;
  elseif (strcmpi (logic, "logical"))
    ## this is the matlab compatible way (before they removed the function)
    bool = islogical (BW);

    ## FIXME the following block is just temporary to keep backwards compatibility
    if (nargin == 1 && !islogical (BW) && isbw (BW, "non-logical"))
      persistent warned = false;
      if (! warned)
        warned = true;
        warning ("isbw: image is not logical matrix and therefore not binary but all values are either 0 and 1.")
        warning ("isbw: future versions of this function will return true. Consider using the call `isbw (img, \"non-logical\")'.")
      endif
      bool = true;
    endif
    ## end of temporary block for backwards compatibility

  elseif (strcmpi (logic, "non-logical"))
    bool = ispart (@is_bw_nonlogical, BW);
  endif

endfunction

function bool = is_bw_nonlogical (BW)
  bool = all ((BW(:) == 1) + (BW(:) == 0));
endfunction

%!shared a
%! a = round(rand(100));
%!assert (isbw (a, "non-logical"), true);
%!assert (isbw (a, "logical"), false);
%!assert (isbw (logical(a), "logical"), true);
%!assert (isbw (logical(a), "non-logical"), true);
%! a(50, 50) = 2;
%!assert (isbw (a, "non-logical"), false);
