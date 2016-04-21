## Copyright (C) 2011 David Bateman
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
## @deftypefn {Loadable Function} {@var{d} = } rank (@var{a})
## Compute the rank of the Galois array @var{a} by counting the independent
## rows and columns.
## @end deftypefn

function varargout = rank (varargin)
  varargout = cell (1, max(1, nargout));
  [varargout{:}] = grank (varargin{:});
endfunction
