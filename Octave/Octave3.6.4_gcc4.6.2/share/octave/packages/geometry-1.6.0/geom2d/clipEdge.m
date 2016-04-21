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
## @deftypefn {Function File} {@var{edge2} =} clipEdge (@var{edge}, @var{box})
## Clip an edge with a rectangular box.
## 
##   @var{edge}: [x1 y1 x2 y2],
##   @var{box} : [xmin xmax ; ymin ymax] or [xmin xmax ymin ymax];
##   return :
##   @var{edge2} = [xc1 yc1 xc2 yc2];
##
##   If clipping is null, return [0 0 0 0];
##
##   if @var{edge} is a [nx4] array, return an [nx4] array, corresponding to each
##   clipped edge.
##
## @seealso{edges2d, boxes2d, clipLine}
## @end deftypefn

function edge2 = clipEdge(edge, bb)

  # process data input
  if size(bb, 1)==2
      bb = bb';
  end

  # get limits of window
  xmin = bb(1);
  xmax = bb(2);
  ymin = bb(3);
  ymax = bb(4);


  # convert window limits into lines
  lineX0 = [xmin ymin xmax-xmin 0];
  lineX1 = [xmin ymax xmax-xmin 0];
  lineY0 = [xmin ymin 0 ymax-ymin];
  lineY1 = [xmax ymin 0 ymax-ymin];


  # compute outcodes of each vertex
  p11 = edge(:,1)<xmin; p21 = edge(:,3)<xmin;
  p12 = edge(:,1)>xmax; p22 = edge(:,3)>xmax;
  p13 = edge(:,2)<ymin; p23 = edge(:,4)<ymin;
  p14 = edge(:,2)>ymax; p24 = edge(:,4)>ymax;
  out1 = [p11 p12 p13 p14];
  out2 = [p21 p22 p23 p24];

  # detect edges totally inside window -> no clip.
  inside = sum(out1 | out2, 2)==0;

  # detect edges totally outside window
  outside = sum(out1 & out2, 2)>0;

  # select edges not totally outside, and process separately edges totally
  # inside window
  ind = find(~(inside | outside));


  edge2 = zeros(size(edge));
  edge2(inside, :) = edge(inside, :);


  for i=1:length(ind)
      # current edge
      iedge = edge(ind(i), :);
          
      # compute intersection points with each line of bounding window
      px0 = intersectLineEdge(lineX0, iedge);
      px1 = intersectLineEdge(lineX1, iedge);
      py0 = intersectLineEdge(lineY0, iedge);
      py1 = intersectLineEdge(lineY1, iedge);
           
      # create array of points
      points  = [px0; px1; py0; py1; iedge(1:2); iedge(3:4)];
      
      # remove infinite points (edges parallel to box edges)
	  points  = points(all(isfinite(points), 2), :);
      
      # sort points by x then y
      points = sortrows(points);
      
      # get center positions between consecutive points
      centers = (points(2:end,:) + points(1:end-1,:))/2;
      
      # find the centers (if any) inside window
      inside = find(  centers(:,1)>=xmin & centers(:,2)>=ymin & ...
                      centers(:,1)<=xmax & centers(:,2)<=ymax);

      # if multiple segments are inside box, which can happen due to finite
      # resolution, only take the longest segment
      if length(inside)>1
          # compute delta vectors of the segments
          dv = points(inside+1,:) - points(inside,:); 
          # compute lengths of segments
          len = hypot(dv(:,1), dv(:,2));
          # find index of longest segment
          [a, I] = max(len); ##ok<ASGLU>
          inside = inside(I);
      end
      
      # if one of the center points is inside box, then the according edge
      # segment is indide box
      if length(inside)==1
           # restore same direction of edge
          if iedge(1)>iedge(3) || (iedge(1)==iedge(3) && iedge(2)>iedge(4))
              edge2(i, :) = [points(inside+1,:) points(inside,:)];
          else
              edge2(i, :) = [points(inside,:) points(inside+1,:)];
          end
      end
      
  end # end of loop of edges
endfunction

%!demo
%! bb = [0 100 0 100];
%! edge = [-10 10 90 110];
%! ec = clipEdge (edge, bb);
%! 
%! drawBox(bb,'color','k');
%! line(edge([1 3]),edge([2 4]),'color','b');
%! line(ec([1 3]),ec([2 4]),'color','r','linewidth',2);
%! axis tight
%! v = axis ();
%! axis(v+[0 10 -10 0])

%!shared bb
%! bb = [0 100 0 100];
%!assert (clipEdge([20 30 80 60], bb), [20 30 80 60],1e-6);
%!assert (clipEdge([0  30 80 60], bb), [0  30 80 60],1e-6);
%!assert (clipEdge([0  30 100 60], bb), [0  30 100 60],1e-6);
%!assert (clipEdge([30 0 80 100], bb), [30 0 80 100],1e-6);
%!assert (clipEdge([0 0 100 100], bb), [0 0 100 100],1e-6);
%!assert (clipEdge([0 100 100 0], bb), [0 100 100 0],1e-6);
%!assert (clipEdge([20 60 120 60], bb), [20 60 100 60],1e-6);
%!assert (clipEdge([-20 60 80 60], bb), [0  60 80 60],1e-6);
%!assert (clipEdge([20 60 20 160], bb), [20 60 20 100],1e-6);
%!assert (clipEdge([20 -30 20 60], bb), [20 0 20 60],1e-6);
%!assert (clipEdge([120 30 180 60], bb), [0 0 0 0],1e-6);
%!assert (clipEdge([-20 30 -80 60], bb), [0 0 0 0],1e-6);
%!assert (clipEdge([30 120 60 180], bb), [0 0 0 0],1e-6);
%!assert (clipEdge([30 -20 60 -80], bb), [0 0 0 0],1e-6);
%!assert (clipEdge([-120 110 190 150], bb), [0 0 0 0],1e-6);
%!assert ([50 50 100 50], clipEdge([50 50 150 50], bb),1e-6);
%!assert ([50 50 0 50], clipEdge([50 50 -50 50], bb),1e-6);
%!assert ([50 50 50 100], clipEdge([50 50 50 150], bb),1e-6);
%!assert ([50 50 50 0], clipEdge([50 50 50 -50], bb),1e-6);
%!assert ([80 50 100 70], clipEdge([80 50 130 100], bb),1e-6);
%!assert ([80 50 100 30], clipEdge([80 50 130 0], bb),1e-6);
%!assert ([20 50 0 70], clipEdge([20 50 -30 100], bb),1e-6);
%!assert ([20 50 0 30], clipEdge([20 50 -30 0], bb),1e-6);
%!assert ([50 80 70 100], clipEdge([50 80 100 130], bb),1e-6);
%!assert ([50 80 30 100], clipEdge([50 80 0 130], bb),1e-6);
%!assert ([50 20 70 0], clipEdge([50 20 100 -30], bb),1e-6);
%!assert ([50 20 30 0], clipEdge([50 20 0 -30], bb),1e-6);
%!assert ([100 50 50 50], clipEdge([150 50 50 50], bb),1e-6);
%!assert ([0 50 50 50], clipEdge([-50 50 50 50], bb),1e-6);
%!assert ([50 100 50 50], clipEdge([50 150 50 50], bb),1e-6);
%!assert ([50 0 50 50], clipEdge([50 -50 50 50], bb),1e-6);
%!assert ([100 70 80 50], clipEdge([130 100 80 50], bb),1e-6);
%!assert ([100 30 80 50], clipEdge([130 0 80 50], bb),1e-6);
%!assert ([0 70 20 50], clipEdge([-30 100 20 50], bb),1e-6);
%!assert ([0 30 20 50], clipEdge([-30 0 20 50], bb),1e-6);
%!assert ([70 100 50 80], clipEdge([100 130 50 80], bb),1e-6);
%!assert ([30 100 50 80], clipEdge([0 130 50 80], bb),1e-6);
%!assert ([70 0 50 20], clipEdge([100 -30 50 20], bb),1e-6);
%!assert ([30 0 50 20], clipEdge([0 -30 50 20], bb),1e-6);
%!assert ([0 20 80 100], clipEdge([-10 10 90 110], bb),1e-6);



