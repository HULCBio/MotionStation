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

## -*- texinfo -*-
## @deftypefn {Function File} @var{SVGn} = normalize (@var{SVG})
## normalizes and SVG.
## @end deftypefn

function [SVGn bb] = normalize (obj)

  SVGn = obj;
  bb = [];
  if ! obj.Data.normalized

    ids = fieldnames (obj.Path);
    npath = numel(ids);
    v = zeros(npath,2);
    bb = zeros(1,4);

    for ip = 1:npath
      v(ip,:) = shapecentroid(obj.Path.(ids{ip}).data);
      p = shape2polygon(obj.Path.(ids{ip}).data);
      bb = mergeBoxes(bb, [min(p) max(p)]([1 3 2 4]));
    end

    if npath > 1
      v = mean(v)(:);
    else
      v = v.';
    end

    ## check whether document and bounding box agree.
    bbHeight = bb(2)-bb(1);
    bbWidth = bb(4)-bb(2);

    if obj.Data.height != bbHeight
      warning("svg:normalize:Sanitycheck",...
      ["Height of SVG #g and height boundingbox #g don't match.\n" ...
       "Using bounding box.\n"],obj.Data.height,bbHeight)
    end

    if obj.Data.width != bbWidth
      warning("svg:normalize:Sanitycheck",...
      ["Width of SVG #g and width boundingbox #g don't match.\n" ...
      "Using bounding box.\n"],obj.Data.width,bbWidth)
    end

    ## Move paths such that center of SVG is at 0,0
    ## Put coordinates in the usual frame
    ## Scale such that diagonal of bounding box is 1
    Dnorm = sqrt (bbWidth ^ 2 + bbHeight ^ 2);
    S = (1 / Dnorm) * eye (2);
    bb = zeros(1,4);

    for ip = 1:npath
      SVGn.Path.(ids{ip}).data = shapetransform(obj.Path.(ids{ip}).data,-v);

      # Put to middle
      SVGn.Path.(ids{ip}).data = ...
                        shapetransform(SVGn.Path.(ids{ip}).data,[0; -bbHeight/2]);
      # Reflect y
      SVGn.Path.(ids{ip}).data = ...
                             shapetransform(SVGn.Path.(ids{ip}).data,[1 0;0 -1]);
      # Put to bottom
      SVGn.Path.(ids{ip}).data = ...
                        shapetransform(SVGn.Path.(ids{ip}).data,[0; bbHeight/2]);

      # Scale
      SVGn.Path.(ids{ip}).data = ...
                        shapetransform(SVGn.Path.(ids{ip}).data,S);

      p = shape2polygon(SVGn.Path.(ids{ip}).data);
      bb = mergeBoxes(bb, [min(p) max(p)]([1 3 2 4]));
    end
    bbHeight = bb(2)-bb(1);
    bbWidth = bb(4)-bb(2);

    SVGn.Data.height = bbHeight;
    SVGn.Data.width = bbWidth;
    SVGn.Data.normalized = true;
  end

end
