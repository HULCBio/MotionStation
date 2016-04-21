## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} generate_html_manual (@var{srcdir}, @var{outdir})
## @end deftypefn

function generate_html_manual (srcdir, outdir = "htdocs", options = struct ())
  ## Check input
  if (nargin == 0)
    print_usage ();
  endif

  if (!ischar (srcdir))
    error ("generate_html_manual: first input argument must be a string");
  endif

  if (!ischar (outdir))
    error ("generate_html_manual: second input argument must be a string");
  endif
  
  ## If options is a string, call get_html_options
  if (ischar (options))
    options = get_html_options (options);
  elseif (!isstruct (options))
    error ("generate_html_manual: third input argument must be a string or a structure");
  endif
  
  ## Create directories
  if (!exist (outdir, "dir"))
    mkdir (outdir);
  endif
  %outdir = fullfile (outdir, "octave");
  %if (!exist (outdir, "dir"))
  %  mkdir (outdir);
  %endif
  
  %chapter_dir = mk_chapter_dir (outdir, options);
  %mk_function_dir (outdir, options);
  %
  %ds_handler = @(fun) docstring_handler (fun);
  
  ## Get file list
  %file_list = get_txi_files (srcdir);
  %txi_dir = fileparts (file_list {1});
  %
  %texi_header = sprintf ("%s\n", get_texi_conf (srcdir));
  
  ## Copy images from Octave build
  %txi_dir = fullfile (srcdir, "doc", "interpreter");
  %pngs = fullfile (txi_dir, "*.png");
  %copyfile (pngs, ".");
  
  ## Set javascript startup
  %if (!isfield (options, "body_command"))
  %  if (isfield (options, "manual_body_cmd"))
  %    options.body_command = options.manual_body_cmd;
  %  else
  %    options.body_command = ""; # XXX: do we need this?
  %  endif
  %endif

  ## Process each file
  %for k = 1:length (file_list)
  %  file = file_list {k};
  %  [notused, name] = fileparts (file);
  %  
  %  text = txi2reference (file, ds_handler);
  %  
  %  text = strcat (texi_header, text);   
  %  
  %  ## Remove numbers from headings as this has been broken since we handle
  %  ## each chapter as a seperate file
  %  text = strrep (text, "@chapter", "@unnumbered");
  %  text = strrep (text, "@appendix", "@unnumbered");
  %  text = strrep (text, "@section", "@unnumberedsec");
  %  text = strrep (text, "@subsection", "@unnumberedsubsec");
  %  text = strrep (text, "@subsubsection", "@unnumberedsubsubsec");
  %  
  %  ## Make sure any @include's work
  %  include = "@include ";
  %  include_with_path = sprintf ("@include %s%s", txi_dir, filesep ());
  %  text = strrep (text, include, include_with_path);
  %  
  %  ## Add 'op' index
  %  text = strcat ("@defindex op\n\n", text);
  %
  %  ## Convert to HTML and write to disc
  %  [header, body, footer] = texi2html (text, options, "../../");
  %  
  %  fid = fopen (fullfile (chapter_dir, sprintf ("%s.html", name)), "w");
  %  fprintf (fid, "%s\n%s\n%s\n", header, body, footer);
  %  fclose (fid);
  %endfor
  
  ## Move images into the chapter dir
  %movefile ("*.png", chapter_dir);
  
  ###################################################
  ##  Generate reference for individual functions  ##
  ###################################################

  ## Get INDEX structure
  indices = txi2index (srcdir);
  index = struct ();
  index.provides = {};
  index.name = "octave";
  index.description = "GNU Octave comes with a large set of general-prupose functions that are listed below. This is the core set of functions that is available without any packages installed.";
  for k = 1:length (indices)
    if (!isempty (indices {k}))
      ikp = indices {k}.provides;
      index.provides (end+1:end+length (ikp)) = ikp;
    endif
  endfor
  
  ## Generate the documentation
  options.include_package_list_item = false;
  options.include_package_page = false;
  options.include_package_license = false;
  
  generate_package_html (index, outdir, options);
  %for k = 1:length (index)
  %  if (!isempty (index {k}))
  %    printf ("Chapter: %s\n", index {k}.name); fflush (stdout);
  %    index {k}.name = ""; # remove the name to avoid  each chapter having its own dir
  %    generate_package_html (index {k}, outdir, options);
  %  endif
  %endfor
endfunction

function retval = docstring_handler (fun)
  retval = sprintf ("@ifhtml\n@html\n<div class='seefun'>See <a href='../function/%s.html'>%s</a></div>\n@end html\n@end ifhtml\n",
                    fun, fun);
endfunction

