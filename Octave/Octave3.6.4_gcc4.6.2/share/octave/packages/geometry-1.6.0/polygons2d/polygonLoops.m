## Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
## Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{loops} = } polygonLoops (@var{poly})
## Divide a possibly self-intersecting polygon into a set of simple loops
##
##   @var{poly} is a polygone defined by a series of vertices,
##   @var{loops} is a cell array of polygons, containing the same vertices of the
##   original polygon, but no loop self-intersect, and no couple of loops
##   intersect each other.
##
##   Example:
## @example
##       poly = [0 0;0 10;20 10;20 20;10 20;10 0];
##       loops = polygonLoops(poly);
##       figure(1); hold on;
##       drawPolygon(loops);
##       polygonArea(loops)
## @end example
##
## @seealso{polygons2d, polygonSelfIntersections}
## @end deftypefn

function loops = polygonLoops(poly)

  ## Initialisations

  # compute intersections
  [inters pos1 pos2] = polygonSelfIntersections(poly);

  # case of a polygon without self-intersection
  if isempty(inters)
      loops = {poly};
      return;
  end

  # array for storing loops
  loops = cell(0, 1);

  positions = sortrows([pos1 pos2;pos2 pos1]);


  ## First loop

  pos0 = 0;
  loop = polygonSubcurve(poly, pos0, positions(1, 1));
  pos = positions(1, 2);
  positions(1, :) = [];

  while true
      # index of next intersection point
      ind = find(positions(:,1)>pos, 1, 'first');
      
      # if not found, break
      if isempty(ind)
          break;
      end
      
      # add portion of curve
      loop = [loop;polygonSubcurve(poly, pos, positions(ind, 1))]; ##ok<AGROW>
      
      # look for next intersection point
      pos = positions(ind, 2);
      positions(ind, :) = [];
  end

  # add the last portion of curve
  loop = [loop;polygonSubcurve(poly, pos, pos0)];

  # remove redundant vertices
  loop(sum(loop(1:end-1,:) == loop(2:end,:) ,2)==2, :) = [];
  if sum(diff(loop([1 end], :))==0)==2
      loop(end, :) = [];
  end

  # add current loop to the list of loops
  loops{1} = loop;


  ## Other loops

  Nl = 1;
  while ~isempty(positions)

      loop    = [];
      pos0    = positions(1, 2);
      pos     = positions(1, 2);
      
      while true
          # index of next intersection point
          ind = find(positions(:,1)>pos, 1, 'first');

          # add portion of curve
          loop = [loop;polygonSubcurve(poly, pos, positions(ind, 1))]; ##ok<AGROW>

          # look for next intersection point
          pos = positions(ind, 2);
          positions(ind, :) = [];

          # if not found, break
          if pos==pos0
              break;
          end
      end

      # remove redundant vertices
      loop(sum(loop(1:end-1,:) == loop(2:end,:) ,2)==2, :) = []; ##ok<AGROW>
      if sum(diff(loop([1 end], :))==0)==2
          loop(end, :) = []; ##ok<AGROW>
      end

      # add current loop to the list of loops
      Nl = Nl + 1;
      loops{Nl} = loop;
  end

endfunction
