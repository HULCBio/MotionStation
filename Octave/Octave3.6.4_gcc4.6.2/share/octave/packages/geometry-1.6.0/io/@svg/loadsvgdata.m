## Copyright (C) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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

function data = loadsvgdata (obj, svg, varargin)

  here   = which ("@svg/loadsvgdata");
  here   = fileparts (here);
  script = fullfile (here, 'parseSVGData.py');

  ## Call python script
  if exist (svg,'file')
  # read from file
    [st str]=system (sprintf ('python %s %s', script, svg));

  else
  # inline SVG
    [st str]=system (sprintf ('python %s < %s', script, svg));
  end

  ## Parse ouput
  strdata = strsplit (str(1:end-1), '$', true);
  eval (strdata);

endfunction
