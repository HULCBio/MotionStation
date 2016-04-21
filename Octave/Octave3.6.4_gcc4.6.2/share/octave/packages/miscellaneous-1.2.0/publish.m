## Copyright (C) 2010 Fotios Kasolis <fotios.kasolis@gmail.com>
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
## @deftypefn {Function File} {} publish (@var{filename})
## @deftypefnx {Function File} {} publish (@var{filename}, @var{options})
## Produces latex reports from scripts.
##
## @example
## publish (@var{my_script})
## @end example
##
## @noindent
## where the argument is a string that contains the file name of
## the script we want to report.
##
## If two arguments are given, they are interpreted as follows.
##
## @example
## publish (@var{filename}, [@var{option}, @var{value}, ...])
## @end example
##
## @noindent
## The following options are available:
##
## @itemize @bullet
## @item format
## 
## the only available format values are the strings `latex' and
## `html'.
##
## @item
## imageFormat:
##
## string that specifies the image format, valid formats are `pdf',
## `png', and `jpg'(or `jpeg').
##
## @item
## showCode:
##
## boolean value that specifies if the source code will be included
## in the report.
##
## @item
## evalCode:
##
## boolean value that specifies if execution results will be included
## in the report.
## 
## @end itemize
##
## Default @var{options}
##
## @itemize @bullet
## @item format = latex
##
## @item imageFormat = pdf
##
## @item showCode =  1
##
## @item evalCode =  1
##
## @end itemize
##
## Remarks
##
## @itemize @bullet
## @item Any additional non-valid field is removed without
## notification.
##
## @item To include several figures in the resulting report you must
## use figure with a unique number for each one of them.
##
## @item You do not have to save the figures manually, publish will
## do it for you.
##
## @item The functions works only for the current path and no way ...
## to specify other path is allowed.
##
## @end itemize
##
## Assume you have the script `myscript.m' which looks like
##
## @example
## @group
## x = 0:0.1:pi;
## y = sin(x)
## figure(1)
## plot(x,y);
## figure(2)
## plot(x,y.^2);
## @end group
## @end example
##
## You can then call publish with default @var{options}
## 
## @example
## publish("myscript")
## @end example
## @end deftypefn

function publish (file_name, varargin)

  if ((nargin < 1) || (rem (numel (varargin), 2) != 0))
    print_usage ();
  endif

  if (!strcmp (file_name(end-1:end), ".m"))
    ifile = strcat (file_name, ".m");
    ofile = strcat (file_name, ".tex");
  else
    ifile = file_name;
    ofile = strcat (file_name(1:end-1), "tex");
  endif

  if (exist (ifile, "file") != 2)
    error ("File %s does not exist.", ifile);
  endif

  options = set_default (struct ());
  options = read_options (varargin, "op1", "format imageFormat showCode evalCode", "default", options);

  if (strcmpi (options.format, "latex"))
    create_latex (ifile, ofile, options);
  elseif strcmpi(options.format, "html")
    create_html (ifile, options);
  endif

endfunction

function def_options = set_default (options);

  if (!isfield (options, "format"))
    def_options.format = "latex";
  elseif (!ischar (options.format))
    error("Option format must be a string.");
  else
    valid_formats={"latex", "html"};
    validity_test = strcmpi (valid_formats, options.format);
    if (isempty (find (validity_test)))
      error ("The supplied format is not currently supported.");
    else
      def_options.format = options.format;
    endif
  endif

  if (! isfield (options, "imageFormat"))
    def_options.imageFormat = "pdf";
  elseif (! ischar(options.imageFormat))
    error("Option imageFormat must be a string.");
  else
    valid_formats = {"pdf", "png", "jpg", "jpeg"};
    validity_test = strcmpi (valid_formats, options.imageFormat);
    if (isempty (find (validity_test)))
      error ("The supplied image format is not available.");
    else
      def_options.imageFormat = options.imageFormat;
    endif
  endif
  
  if (!isfield (options,"showCode"))
    def_options.showCode = true;
  elseif (!isbool (options.showCode))
    error ("Option showCode must be a boolean.");
  else
    def_options.showCode = options.showCode;
  endif

  if (!isfield (options,"evalCode"))
    def_options.evalCode = true;
  elseif (!isbool (options.evalCode))
    error ("Option evalCode must be a boolean.");
  else
    def_options.evalCode = options.evalCode;
  endif
endfunction

function create_html (ifile, options)

  ofile = strcat (ifile(1:end-1), "html");
  html_start = "<html>\n<body>\n";
  html_end   = "</body>\n</html>\n";

  if options.showCode
    section1_title = "<h2>Source code</h2>\n";
    fid = fopen (ifile, "r");
    source_code = fread (fid, "*char")';
    fclose(fid);
  else
    section1_title = "";
    source_code    = "";
  endif

  if options.evalCode
    section2_title = "<h2>Execution results</h2>\n";
    oct_command    = strcat ("<listing>octave> ", ifile(1:end-2), "\n");
    script_result  = exec_script (ifile);
  else
    section2_title = "";
    oct_command    = "";
    script_result  = "";
  endif

  [section3_title, disp_fig] = exec_print (ifile, options);

  final_document = strcat (html_start, section1_title, "<listing>\n", source_code,"\n",...
                           "</listing>\n", section2_title, oct_command, script_result,...
                           "</listing>", section3_title, disp_fig, html_end);

  
  fid = fopen (ofile, "w");
  fputs (fid, final_document);
  fclose (fid);

endfunction

function create_latex (ifile, ofile, options)
  latex_preamble = "\
\\documentclass[a4paper,12pt]{article}\n\
\\usepackage{listings}\n\
\\usepackage{graphicx}\n\
\\usepackage{color}\n\
\\usepackage[T1]{fontenc}\n\
\\definecolor{lightgray}{rgb}{0.9,0.9,0.9}\n";

  listing_source_option = "\
\\lstset{\n\
language = Octave,\n\
basicstyle =\\footnotesize,\n\
numbers = left,\n\
numberstyle = \\footnotesize,\n\
backgroundcolor=\\color{lightgray},\n\
frame=single,\n\
tabsize=2,\n\
breaklines=true}\n";

  listing_exec_option = "\
\\lstset{\n\
language = Octave,\n\
basicstyle =\\footnotesize,\n\
numbers = none,\n\
backgroundcolor=\\color{white},\n\
frame=none,\n\
tabsize=2,\n\
breaklines=true}\n";

  if options.showCode
    section1_title = strcat ("\\section*{Source code: \\texttt{", ifile, "}}\n");
    source_code    = strcat ("\\lstinputlisting{", ifile, "}\n");
  else
    section1_title = "";
    source_code    = "";
  endif
  
  if options.evalCode
    section2_title = "\\section*{Execution results}\n";
    oct_command    = strcat ("octave> ", ifile(1:end-2), "\n");
    script_result = exec_script (ifile);
  else
    section2_title = "";
    oct_command    = "";
    script_result  = "";
  endif

  [section3_title, disp_fig] = exec_print (ifile, options);

  final_document = strcat (latex_preamble, listing_source_option, 
                           "\\begin{document}\n", 
                           section1_title, source_code, 
                           section2_title, listing_exec_option,
                           "\\begin{lstlisting}\n",
                           oct_command, script_result,
                           "\\end{lstlisting}\n",
                           section3_title,
                           "\\begin{center}\n",
                           disp_fig,
                           "\\end{center}\n",
                           "\\end{document}");

  fid = fopen (ofile, "w");
  fputs(fid, final_document);
  fclose(fid);
endfunction

function script_result = exec_script (ifile)
  diary publish_tmp_script.txt
  eval (ifile(1:end-2))
  diary off
  fid = fopen ("publish_tmp_script.txt", 'r');
  script_result = fread (fid, '*char')';
  fclose(fid);
  delete ("publish_tmp_script.txt");
endfunction

function [section3_title, disp_fig] = exec_print (ifile, options)
  figures = findall (0, "type", "figure");
  section3_title = "";
  disp_fig       = "";
  if (!isempty (figures))
    for nfig = 1:length (figures)
      figure (figures(nfig));
      print (sprintf ("%s%d.%s", ifile(1:end-2), nfig, options.imageFormat),
             sprintf ("-d%s", options.imageFormat), "-color");
      if (strcmpi (options.format, "html"));
        section3_title = "<h2>Generated graphics</h2>\n";
        disp_fig = strcat (disp_fig, "<img src=\"", ifile(1:end-2), 
                           sprintf ("%d", nfig), ".", options.imageFormat, "\"/>");
      elseif (strcmpi (options.format, "latex"))
        section3_title = "\\section*{Generated graphics}\n";
        disp_fig = strcat (disp_fig, "\\includegraphics[scale=0.6]{", ifile(1:end-2), 
                           sprintf("%d",nfig), "}\n");
      endif
    endfor
  endif
endfunction

# TODO
#   * ADD VARARGIN FOR ADDITIONAL FILES SOURCES TO BE INLCUDED AS
#     APPENDICES (THIS SOLVES THE PROBLEM OF FUNCTIONS SINCE YOU CAN
#     PUT THE FUNCTION CALL IN SCRIPT CALL PUBLISH(SCRIPT) AND ADD
#     THE FUNCTIONS CODE AS APPENDIX)
#
#   * KNOWN PROBLEM: THE COMMENTING LINES IN HTML
