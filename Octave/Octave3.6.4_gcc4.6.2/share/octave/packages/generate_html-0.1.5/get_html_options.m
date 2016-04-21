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
## @deftypefn {Function File} {@var{options} =} get_html_options (@var{project_name})
## Returns a structure containing design options for various project web sites.
##
## Given a string @var{project_name}, the function returns a structure containing
## various types of information for generating web pages for the specified project.
## Currently, the accepted values of @var{project_name} are
##
## @table @t
## @item "octave-forge"
## Design corresponding to the pages at @t{http://octave.sf.net}.
##
## @item "octave"
## Design corresponding to the pages at @t{http://octave.org}. The pages are
## meant to be processed with the @code{m4} preprocessor, using the macros for
## the site.
##
## @item "docbrowser"
## Design corresponding to the pages in the documentation browser.
## @end table
## @seealso{generate_package_html, html_help_text}
## @end deftypefn

function options = get_html_options (project_name)
  ## Check input
  if (nargin == 0)
    error ("get_html_options: not enough input arguments");
  endif
  
  if (!ischar (project_name))
    error ("get_html_options: first input argument must be a string");
  endif
  
  ## Generate options depending on project
  switch (lower (project_name))
    case "octave-forge"
      ## Basic HTML header
      hh = "\
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\
 \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n\
<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n\
  <head>\n\
  <meta http-equiv=\"content-type\" content=\"text/html; charset=iso-8859-1\" />\n\
  <meta name=\"date\" content=\"%date\"/>\n\
  <meta name=\"author\" content=\"The Octave-Forge Community\" />\n\
  <meta name=\"description\" content=\"Octave-Forge is a collection of packages\
   providing extra functionality for GNU Octave.\" />\n\
  <meta name=\"keywords\" lang=\"en\" content=\"Octave-Forge, Octave, extra packages\" />\n\
  <title>%title</title>\n\
  <link rel=\"stylesheet\" type=\"text/css\" href=\"%root%css\" />\n\
  <script src=\"%rootfixed.js\" type=\"text/javascript\"></script>\n\
  <script src=\"%rootjavascript.js\" type=\"text/javascript\"></script>\n\
  <link rel=\"shortcut icon\" href=\"%rootfavicon.ico\" />\n\
  </head>\n\
  <body %body_command>\n\
  <div id=\"top-menu\" class=\"menu\">\n\
   <table class=\"menu\">\n\
      <tr>\n\
        <td style=\"width: 90px;\" class=\"menu\" rowspan=\"2\">\n\
          <a name=\"top\">\n\
          <img src=\"%rootoct.png\" alt=\"Octave logo\" />\n\
          </a>\n\
        </td>\n\
        <td class=\"menu\" style=\"padding-top: 0.9em;\">\n\
          <big class=\"menu\">Octave-Forge</big><small class=\"menu\"> - Extra packages for GNU Octave</small>\n\
        </td>\n\
      </tr>\n\
      <tr>\n\
        <td class=\"menu\">\n\
\n\
 <a href=\"%rootindex.html\" class=\"menu\">Home</a> &middot;\n\
 <a href=\"%rootpackages.php\" class=\"menu\">Packages</a> &middot;\n\
 <a href=\"%rootdevelopers.html\" class=\"menu\">Developers</a> &middot;\n\
 <a href=\"%rootdocs.html\" class=\"menu\">Documentation</a> &middot;\n\
 <a href=\"%rootFAQ.html\" class=\"menu\">FAQ</a> &middot;\n\
 <a href=\"%rootbugs.html\" class=\"menu\">Bugs</a> &middot;\n\
 <a href=\"%rootarchive.html\" class=\"menu\">Mailing Lists</a> &middot;\n\
 <a href=\"%rootlinks.html\" class=\"menu\">Links</a> &middot;\n\
 <a href=\"https://sourceforge.net/p/octave/code\" class=\"menu\">SVN</a>\n\
\n\
        </td>\n\
      </tr>\n\
    </table>\n\
  </div>\n\
<div id=\"left-menu\">\n\
  <h3>Navigation</h3>\n\
  <p class=\"left-menu\"><a class=\"left-menu-link\" href=\"%rootoperators.html\">Operators and Keywords</a></p>\n\
  <p class=\"left-menu\"><a class=\"left-menu-link\" href=\"%rootfunction_list.html\">Function List:</a>\n\
  <ul class=\"left-menu-list\">\n\
    <li class=\"left-menu-list\">\n\
      <a  class=\"left-menu-link\" href=\"%rootoctave/overview.html\">&#187; Octave core</a>\n\
    </li>\n\
    <li class=\"left-menu-list\">\n\
      <a  class=\"left-menu-link\" href=\"%rootfunctions_by_package.php\">&#187; by package</a>\n\
    </li>\n\
    <li class=\"left-menu-list\">\n\
      <a  class=\"left-menu-link\" href=\"%rootfunctions_by_alpha.php\">&#187; alphabetical</a>\n\
    </li>\n\
  </ul>\n\
  </p>\n\
  <p class=\"left-menu\"><a class=\"left-menu-link\" href=\"%rootdoxygen/html\">C++ API</a></p>\n\
</div>\n\
<div id=\"doccontent\">\n";

      ## CSS
      options.css = "octave-forge.css";
      
      ## Options for alphabetical lists
      options.include_alpha = true;
    
      ## Options for individual function pages
      options.pack_body_cmd = 'onload="javascript:fix_top_menu (); javascript:show_left_menu ();"';
      options.header = strrep (hh, "%date", date ());
      options.footer = "<p>Package: <a href=\"../index.html\">%package</a></p>\n<div id=\"sf_logo\">\n\
         <a href=\"http://sourceforge.net\">\
         <img src=\"http://sourceforge.net/sflogo.php?group_id=2888&amp;type=1\"\
         width=\"88\" height=\"31\" style=\"border: 0;\" alt=\"SourceForge.net Logo\"/>\
         </a>\n</div>\n</div>\n</body>\n</html>\n";
      options.title = "Function Reference: %name";
      options.include_demos = true;
      options.seealso = @octave_forge_seealso;
      
      ## Options for overview page
      options.include_overview = true;
      #options.overview_header = strrep (strrep (hh, "%date", date ()), "%body_command", "");
      options.manual_body_cmd = 'onload="javascript:fix_top_menu (); javascript:manual_menu ();"';
    
      ## Options for package list page
      options.include_package_list_item = true;
      options.package_list_item = ...
"<div class=\"package\" id=\"%name\">\n\
<table class=\"package\"><tr>\n\
<td><b><a href=\"javascript:unfold('%name');\" class=\"package_head_link\">\n\
<img src=\"show.png\" id=\"%name_im\" alt=\"show/hide\" style=\"padding-right: 0.5em; border: none;\"/> %name </a></b></td>\n\
<td style=\"text-align: right;\">&raquo; <a href=\"./%name/index.html\" class=\"package_link\">details</a> |\n\
<a class=\"package_link\" href=\"http://downloads.sourceforge.net/octave/%name-%version.%extension?download\">download</a></td>\n\
</tr></table>\n\
<p id=\"%name_detailed\" style=\"display: none;\"> %shortdescription </p>\n\
</div>\n";

      ## Options for index package
      options.index_title = "The '%name' Package";
      options.download_link = "http://downloads.sourceforge.net/octave/%name-%version.tar.gz?download";
      options.include_package_page = true;
      options.include_package_license = true;
      options.index_body_command = "onload=\"javascript:fix_top_menu ();\"";
      
    case "octave"
      options.header = "__HEADER__(`%title')";
      options.footer = "__OCTAVE_TRAILER__";
      options.title  = "Function Reference: %name";
      options.include_overview = true;

    case "docbrowser"
      ## Basic HTML header
      hh = "\
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\
 \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n\
<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n\
  <head>\n\
  <meta http-equiv=\"content-type\" content=\"text/html; charset=iso-8859-1\" />\n\
  <meta name=\"date\" content=\"%date\"/>\n\
  <meta name=\"author\" content=\"The Octave Community\" />\n\
  <title>%title</title>\n\
  <link rel=\"stylesheet\" type=\"text/css\" href=\"%css\" />\n\
  </head>\n\
<body>\n\
<div id=\"top\">Function Reference</div>\n\
<div id=\"doccontent\">\n";
      hh = strrep (hh, "%date", date ());
    
      ## Options for individual function pages
      css = "doc.css";
      options.header = strrep (hh, "%css", css);
      options.footer = "</div>\n</body>\n</html>\n";
      options.title = "Function: %name";
      options.include_demos = true;
          
      ## Options for overview page
      options.include_overview = true;
      options.overview_header = strrep (hh, "%css", sprintf ("../%s", css));
      options.overview_title = "Overview: %name";
      
    otherwise
      error ("get_html_options: unknown project name: %s", project_name);
  endswitch

endfunction
