## Copyright (C) 2009-2012 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Command} {} which name @dots{}
## Display the type of each @var{name}.  If @var{name} is defined from a
## function file, the full name of the file is also displayed.
## @seealso{help, lookfor}
## @end deftypefn

function varargout = which (varargin)

  if (nargin > 0 && iscellstr (varargin))
    m = __which__ (varargin{:});

    if (nargout == 0)
      for i = 1:nargin
        if (isempty (m(i).file))
          if (! isempty (m(i).type))
            printf ("'%s' is a %s\n",
                    m(i).name, m(i).type);
          endif
        else
          if (isempty (m(i).type))
            printf ("'%s' is the file %s\n",
                    m(i).name, m(i).file);
          else
            printf ("'%s' is a %s from the file %s\n",
                    m(i).name, m(i).type, m(i).file);
          endif
        endif
      endfor
    else
      varargout = {m.file};
    endif
  else
    print_usage ();
  endif

endfunction


%!test
%! str = which ("ls");
%! assert (str(end-17:end), strcat ("miscellaneous", filesep(), "ls.m"));
%!test
%! str = which ("dot");
%! assert (str(end-6:end), "dot.oct");

%!assert (which ("NO_NAME"), "");
