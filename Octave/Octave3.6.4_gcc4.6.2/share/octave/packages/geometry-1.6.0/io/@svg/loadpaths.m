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

function Paths = loadpaths (obj, svg, varargin)

  here   = which ("@svg/loadpaths");
  here   = fileparts (here);
  script = fullfile (here, 'parsePath.py');

  ## Call python script
  if exist (svg,'file')
  # read from file
    [st str]=system (sprintf ('python %s %s', script, svg));

  else
  # inline SVG
    [st str]=system (sprintf ('python %s < %s', script, svg));
  end

  ## Parse ouput
  strpath = strsplit (str(1:end-1), '$', true);

  npaths = numel (strpath);

  ## Convert path data to polynoms
  for ip = 1:npaths

    eval (strpath{ip});
    ## FIXME: intialize struct with cell field
    svgpath2.cmd = svgpath(1).cmd;
    svgpath2.data = {svgpath.data};

    nD = length(svgpath2.cmd);
    pathdata = cell (nD-1,1);

    point_end=[];
    ## If the path is closed, last command is Z and we set initial point == final
    if svgpath2.cmd(end) == 'Z'
      nD -= 1;
      point_end = svgpath2.data{1};
      svgpath2.data(end) = [];
    end

    ## Initial point
    points(1,:) = svgpath2.data{1};

    for jp = 2:nD
      switch svgpath2.cmd(jp)
        case 'L'
          ## Straigth segment to polygon
          points(2,:) = svgpath2.data{jp};
          pp = [(points(2,:)-points(1,:))' points(1,:)'];
          clear points
          points(1,:) = [polyval(pp(1,:),1) polyval(pp(2,:),1)];

        case 'C'
          ## Cubic bezier to polygon
          points(2:4,:) = reshape (svgpath2.data{jp}, 2, 3).';
          pp = cbezier2poly (points);
          clear points
          points(1,:) = [polyval(pp(1,:),1) polyval(pp(2,:),1)];
      end

      pathdata{jp-1} = pp;
    end

    if ~isempty(point_end)
      ## Straight segment to close the path
      points(2,:) = point_end;
      pp = [(points(2,:)-points(1,:))' points(1,:)'];

      if all ( abs(pp(:,1)) < sqrt(eps) )
      # Final point of last segment is already initial point
        pathdata(end) = [];
      else
        pathdata{end} = pp;
      end

    end
    ## TODO
    # pathdata = shapetransform(pathdata);

    Paths.(svgpathid).data = pathdata;
  end
endfunction
