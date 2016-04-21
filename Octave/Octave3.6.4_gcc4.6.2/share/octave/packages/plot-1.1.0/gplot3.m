## Copyright (C) 2010 Soren Hauberg <soren@hauberg.org>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} gplot3 (@var{a}, @var{xyz})
## @deftypefnx {Function File} {} gplot3 (@var{a}, @var{xyz}, @var{line_style})
## @deftypefnx {Function File} {[@var{x}, @var{y}, @var{z}] =} gplot3 (@var{a}, @var{xyz})
## Plot a 3-dimensional graph defined by @var{A} and @var{xyz} in the
## graph theory sense.  @var{A} is the adjacency matrix of the array to
## be plotted and @var{xy} is an @var{n}-by-3 matrix containing the
## coordinates of the nodes of the graph.
##
## The optional parameter @var{line_style} defines the output style for
## the plot.  Called with no output arguments the graph is plotted
## directly.  Otherwise, return the coordinates of the plot in @var{x}
## and @var{y}.
## @seealso{gplot, treeplot, etreeplot, spy}
## @end deftypefn

function [x, y, z] = gplot3 (A, xyz, varargin)

  if (nargin < 2)
    print_usage ();
  endif

  if (length (varargin) == 0)
    varargin {1} = "-";
  endif

  [i, j] = find (A);
  xcoord = [xyz(i,1), xyz(j,1), NA(length(i),1)]'(:);
  ycoord = [xyz(i,2), xyz(j,2), NA(length(i),1)]'(:);
  zcoord = [xyz(i,3), xyz(j,3), NA(length(i),1)]'(:);

  if (nargout == 0)
    plot3 (xcoord, ycoord, zcoord, varargin {:});
  else
    x = xcoord;
    y = ycoord;
    z = zcoord;
  endif

endfunction

%!demo
%! ## Define adjacency matrix of a graph with 5 nodes
%! A = [0, 1, 0, 0, 1;
%!      1, 0, 1, 1, 1;
%!      0, 1, 0, 1, 1;
%!      0, 1, 1, 0, 1;
%!      1, 1, 1, 1, 0 ];
%! 
%! ## Define 3D points of the nodes
%! xyz = [2,   1, 3/2;
%!        3,   2, 2;
%!        8/3, 3, 1;
%!        5/3, 3, 1;
%!        1,   2, 2 ];
%!
%! ## Plot the 3D graph
%! gplot3 (A, xyz);
