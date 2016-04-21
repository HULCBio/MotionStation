## Copyright (C) 2009-2012 S�ren Hauberg
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
## @deftypefn  {Command} {} help @var{name}
## @deftypefnx {Command} {} help @code{--list}
## Display the help text for @var{name}.   For example, the command
## @kbd{help help} prints a short message describing the @code{help}
## command.
##
## Given the single argument @code{--list}, list all operators,
## keywords, built-in functions, and loadable functions available
## in the current session of Octave.
##
## If invoked without any arguments, @code{help} display instructions
## on how to access help from the command line.
##
## The help command can give you information about operators, but not the
## comma and semicolons that are used as command separators.  To get help
## for those, you must type @kbd{help comma} or @kbd{help semicolon}.
## @seealso{doc, lookfor, which}
## @end deftypefn

function retval = help (name)

  if (nargin == 0)

    puts ("\n\
  For help with individual commands and functions type\n\
\n\
    help NAME\n\
\n\
  (replace NAME with the name of the command or function you would\n\
  like to learn more about).\n\
\n\
  For a more detailed introduction to GNU Octave, please consult the\n\
  manual.  To read the manual from the prompt type\n\
\n\
    doc\n\
\n\
  GNU Octave is supported and developed by its user community.\n\
  For more information visit http://www.octave.org.\n\n");

  elseif (nargin == 1 && ischar (name))

    if (strcmp (name, "--list"))
      tmp = do_list_functions ();
      if (nargout == 0)
        printf ("%s", tmp);
      else
        retval = tmp;
      endif
      return;
    endif

    ## Get help text
    [text, format] = get_help_text (name);

    ## Take action depending on help text format
    switch (lower (format))
      case "plain text"
        status = 0;
      case "texinfo"
        [text, status] = __makeinfo__ (text, "plain text");
      case "html"
        [text, status] = strip_html_tags (text);
      case "not documented"
        error ("help: '%s' is not documented\n", name);
      case "not found"
        do_contents (name);
        return;
      otherwise
        error ("help: internal error: unsupported help text format: '%s'\n", format);
    endswitch

    ## Print text
    if (status != 0)
      warning ("help: Texinfo formatting filter exited abnormally; raw Texinfo source of help text follows...\n");
    endif

    if (nargout == 0)
      which (name);
      printf ("\n%s\n%s", text, __additional_help_message__ ());
    else
      retval = text;
    endif

  else
    error ("help: invalid input\n");
  endif

endfunction

function retval = do_list_functions ()

  operators = sprintf ("*** operators:\n\n%s\n\n",
                       list_in_columns (__operators__ ()));

  keywords = sprintf ("*** keywords:\n\n%s\n\n",
                      list_in_columns (__keywords__ ()));

  builtins = sprintf ("*** builtins:\n\n%s\n\n",
                      list_in_columns (__builtins__ ()));

  dirs = strsplit (path, pathsep);
  flist = "";
  for i = 2:numel (dirs)
    files = sort ({dir(fullfile (dirs{i}, "*.m")).name, ...
                   dir(fullfile (dirs{i}, "*.oct")).name, ...
                   dir(fullfile (dirs{i}, "*.mex")).name});

    if (! isempty (files))
      flist = sprintf ("%s*** functions in %s:\n\n%s\n\n",
                       flist, dirs{i}, list_in_columns (files));
    endif
  endfor

  retval = cstrcat (operators, keywords, builtins, flist);

endfunction

function do_contents (name)

  found = false;

  dlist = find_dir_in_path (name, "all");

  for i = 1:numel (dlist)
    fname = make_absolute_filename (fullfile (dlist{i}, "Contents.m"));

    [text, format] = get_help_text_from_file (fname);

    ## Take action depending on help text format
    switch (lower (format))
      case "plain text"
        status = 0;
      case "texinfo"
        [text, status] = __makeinfo__ (text, "plain text");
      case "html"
        [text, status] = strip_html_tags (text);
    endswitch

    if (! isempty (text))
      found = true;
      ## Print text.
      if (status != 0)
        warning ("help: Texinfo formatting filter exited abnormally; raw Texinfo source of help text follows...\n");
      endif
      printf ("%s:\n\n%s\n", fname, text);
    endif

  endfor

  if (found)
    puts (__additional_help_message__ ());
  else
    msg = feval (missing_function_hook, name);

    if (isempty (msg))
      msg = sprintf ("'%s' not found", name);
    endif

    error ("help: %s\n", msg);
  endif

endfunction


%!assert (! isempty (findstr (help ("ls"), "List directory contents")))
%!error <invalid input> help (42)
