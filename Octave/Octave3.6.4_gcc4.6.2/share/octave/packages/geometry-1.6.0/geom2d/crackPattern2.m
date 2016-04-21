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
## @deftypefn {Function File} {@var{e} = } crackPattern2 (@var{box}, @var{points}, @var{alpha})
## Create a (bounded) crack pattern tessellation
##
##   E = crackPattern2(BOX, POINTS, ALPHA)
##   create a crack propagation pattern wit following parameters :
##   - pattern is bounded by area BOX which is a polygon.
##   - each crack originates from points given in POINTS
##   - directions of each crack is given by a [NxM] array ALPHA, where M is
##   the number of rays emanating from each seed/
##   - a crack stop when it reaches another already created crack. 
##   - all cracks stop when they reach the border of the frame, given by box
##   (a serie of 4 points).
##   The result is a collection of edges, in the form [x1 y1 x2 y2].
##
##   E = crackPattern2(BOX, POINTS, ALPHA, SPEED)
##   Also specify speed of propagation of each crack.
##
##
##   See the result with :
##     figure;
##     drawEdge(E);
##
##   @seealso{drawEdge}
## @end deftypefn

function edges = crackPattern2(box, points, alpha, varargin)

  if ~isempty(varargin)
      speed = varargin{1};
  else
      speed = ones(size(points, 1), 1);
  end

  # Compute line equations for each initial crack.
  # The 'Inf' at the end correspond to the position of the limit.
  # If an intersection point is found with another line, but whose position
  # is after this value, this means that another crack stopped it before it
  # reach the intersection point.
  NP = size(points, 1);
  lines = zeros(0, 5);
  for i=1:size(alpha, 2)    
      lines = [lines; points speed.*cos(alpha(:,i)) speed.*sin(alpha(:,i)) Inf*ones(NP, 1)];
  end
  NL = size(lines, 1);

  # initialize lines for borders, but assign a very high speed, to be sure
  # borders will stop all cracks.
  dx = (box([2 3 4 1],1)-box([1 2 3 4],1))*max(speed)*5;
  dy = (box([2 3 4 1],2)-box([1 2 3 4],2))*max(speed)*5;

  # add borders to the lines set
  lines = [lines ; createLine(box, dx, dy) Inf*ones(4,1)];

  edges = zeros(0, 4);


  while true    
      modif = 0;
      
      # try to update each line
	  for i=1:NL
          
          # initialize first point of edge
          edges(i, 1:2) = lines(i, 1:2);
          
          # compute intersections with all other lines
          pi = intersectLines(lines(i,:), lines);
          
          # compute position of all intersection points on the current line 
          pos = linePosition(pi, lines(i,:));
          
                  
          # consider points to the right (positive position), and sort them
          indr = find(pos>1e-12 & pos~=Inf);
          [posr, indr2] = sort(pos(indr));
          
          
          # look for the closest intersection to the right
          for i2=1:length(indr2)
              
              # index of intersected line
              il = indr(indr2(i2));

              # position of point relative to intersected line
              pos2 = linePosition(pi(il, :), lines(il, :));
              
              # depending on the sign of position, tests if the line2 can
              # stop the current line, or if it was stopped before
              if pos2>0
                  if pos2<abs(posr(i2)) && pos2<lines(il, 5)
                      if lines(i, 5) ~= posr(i2)
                          edges(i, 3:4) = pi(il,:);
                          lines(i, 5) = posr(i2); 
                          modif = 1;
                      end                                                           
                      break;
                  end
              end
          end   # end processing of right points of the line
                
          
	  end # end processing of all lines
      
      # break the infinite loop if no more modification was made
      if ~modif
          break;
      end
  end

  # add edges of the surronding box.
  edges = [edges ; box(1,:) box(2,:) ; box(2,:) box(3,:); ...
                   box(3,:) box(4,:) ; box(4,:) box(1,:)  ];

endfunction
