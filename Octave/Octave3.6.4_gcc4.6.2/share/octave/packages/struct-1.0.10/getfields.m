## Copyright (C) 2000 Etienne Grossmann <etienne@egdn.net>
## Copyright (C) 2012 Olaf Till <i7tiol@t-online.de>
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
## @deftypefn {Built-in Function} {} [@var{v1},...] =
## getfields (@var{s}, 'k1',...) = [@var{s}.k1,...]
## Return selected values from a scalar struct. Provides some
## compatibility and some flexibility.
## @end deftypefn
## @seealso{setfields,rmfield,isfield,isstruct,struct}

function [varargout] = getfields (s, varargin)

  if (! all (isfield (s, varargin)))
    error ("some fields not present");
  endif

  if (all (size (s) <= 1))
    varargout = fields2cell (s, varargin);
  else
    error ("structure must be scalar or empty");
  endif

endfunction

%!assert (getfields (struct ('key', 'value'), 'key'), 'value');
