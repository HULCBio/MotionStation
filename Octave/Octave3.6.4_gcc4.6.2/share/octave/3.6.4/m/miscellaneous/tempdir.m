## Copyright (C) 2003-2012 John W. Eaton
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
## @deftypefn {Function File} {@var{dir} =} tempdir ()
## Return the name of the system's directory for temporary files.
## @end deftypefn

function dirname = tempdir ()

  dirname = getenv ("TMPDIR");
  if (isempty (dirname))
    dirname = P_tmpdir;
  endif

  if (! strcmp (dirname(end), filesep))
    dirname = cstrcat (dirname, filesep);
  endif

  if (! isdir (dirname))
    warning ("tempdir: '%s' does not exist or is not a directory", dirname);
  endif

endfunction


%!assert (ischar (tempdir ()))

%!test
%! old_wstate = warning ("query");
%! warning ("off");
%! old_tmpdir = getenv ("TMPDIR");
%! unwind_protect
%!   setenv ("TMPDIR", "__MY_TMP_DIR__");
%!   assert (tempdir (), ["__MY_TMP_DIR__" filesep()]);
%! unwind_protect_cleanup
%!   setenv ("TMPDIR", old_tmpdir);
%!   warning (old_wstate);
%! end_unwind_protect

