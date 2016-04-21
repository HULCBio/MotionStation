## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} @var{bw2} = bwhitmiss (@var{bw1}, @var{se1}, @var{se1})
## @deftypefnx{Function File} @var{bw2} = bwhitmiss (@var{bw1}, @var{interval})
## Perform the binary hit-miss operation.
##
## If two structuring elements @var{se1} and @var{se1} are given, the hit-miss
## operation is defined as
## @example
## bw2 = erode(bw1, se1) & erode(!bw1, se2);
## @end example
## If instead an 'interval' array is given, two structuring elements are computed
## as
## @example
## se1 = (interval ==  1)
## se2 = (interval == -1)
## @end example
## and then the operation is defined as previously.
## @seealso{bwmorph}
## @end deftypefn

function bw = bwhitmiss(im, varargin)
  ## Checkinput
  if (nargin != 2 && nargin != 3)
    print_usage();
  endif
  if (!ismatrix(im) || !isreal(im))
    error("bwhitmiss: first input argument must be a real matrix");
  endif

  ## Get structuring elements
  if (nargin == 2) # bwhitmiss (im, interval)
    interval = varargin{1};
    if (!isreal(interval))
      error("bwhitmiss: second input argument must be a real matrix");
    endif
    if (!all( (interval(:) == 1) | (interval(:) == 0) | (interval(:) == -1) ))
      error("bwhitmiss: second input argument can only contain the values -1, 0, and 1");
    endif
    se1 = (interval ==  1);
    se2 = (interval == -1);
  else # bwhitmiss (im, se1, se2)
    se1 = varargin{1};
    se2 = varargin{2};
    if (!all((se1(:) == 1) | (se1(:) == 0)) || !all((se2(:) == 1) | (se2(:) == 0)))
      error("bwhitmiss: structuring elements can only contain zeros and ones.");
    endif
  endif
  
  ## Perform filtering
  bw = erode(im, se1) & erode(!im, se2);

endfunction
