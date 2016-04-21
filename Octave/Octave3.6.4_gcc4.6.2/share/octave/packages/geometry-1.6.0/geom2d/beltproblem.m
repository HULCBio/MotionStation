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
## @deftypefn {Function File} {[@var{tangent},@var{inner}] = } beltproblem (@var{c}, @var{r})
## Finds the four lines tangent to two circles with given centers and radii.
##
## The function solves the belt problem in 2D for circles with center @var{c} and
## radii @var{r}.
##
## @strong{INPUT}
## @table @var
## @item c
## 2-by-2 matrix containig coordinates of the centers of the circles; one row per circle.
## @item r
## 2-by-1 vector with the radii of the circles.
##@end table
##
## @strong{OUPUT}
## @table @var
## @item tangent
## 4-by-4 matrix with the points of tangency. Each row describes a segment(edge).
## @item inner
## 4-by-2 vector with the point of intersection of the inner tangents (crossed belts)
## with the segment that joins the centers of the two circles. If
## the i-th edge is not an inner tangent then @code{inner(i,:)=[NaN,NaN]}.
## @end table
##
## Example:
##
## @example
## c         = [0 0;1 3];
## r         = [1 0.5];
## [T inner] = beltproblem(c,r)
## @result{} T =
##  -0.68516   0.72839   1.34258   2.63581
##   0.98516   0.17161   0.50742   2.91419
##   0.98675  -0.16225   1.49338   2.91888
##  -0.88675   0.46225   0.55663   3.23112
##
## @result{} inner =
##   0.66667   2.00000
##   0.66667   2.00000
##       NaN       NaN
##       NaN       NaN
##
## @end example
##
## @seealso{edges2d}
## @end deftypefn

function [edgeTan inner] = beltproblem(c,r)

  x0 = [c(1,1) c(1,2) c(2,1) c(2,2)];
  r0 = r([1 1 2 2]);

  middleEdge = createEdge(c(1,:),c(2,:));

  ind0 = [1 0 1 0; 0 1 1 0; 1 1 1 0; -1 0 1 0; 0 -1 1 0; -1 -1 1 0;...
          1 0 0 1; 0 1 0 1; 1 1 0 1; -1 0 0 1; 0 -1 0 1; -1 -1 0 1;...
          1 0 1 1; 0 1 1 1; 1 1 1 1; -1 0 1 1; 0 -1 1 1; -1 -1 1 1;...
          1 0 -1 0; 0 1 -1 0; 1 1 -1 0; -1 0 -1 0; 0 -1 -1 0; -1 -1 -1 0;...
          1 0 0 -1; 0 1 0 -1; 1 1 0 -1; -1 0 0 -1; 0 -1 0 -1; -1 -1 0 -1;...
          1 0 -1 -1; 0 1 -1 -1; 1 1 -1 -1; -1 0 -1 -1; 0 -1 -1 -1; -1 -1 -1 -1];
  nInit = size(ind0,1);
  ir = randperm(nInit);
  edgeTan = zeros(4,4);
  inner = zeros(4,2);
  nSol = 0;
  i=1;

  ## Solve for 2 different lines
  while nSol<4 && i<nInit
      ind = find(ind0(ir(i),:)~=0);
      x = x0;
      x(ind)=x(ind)+r0(ind);
      [sol f0 nev]= fsolve(@(x)belt(x,c,r),x);
      if nev~=1
           perror('fsolve',nev)
      end

      for j=1:4
         notequal(j) = all(abs(edgeTan(j,:)-sol) > 1e-6);
      end
      if all(notequal)
       nSol = nSol+1;
       edgeTan(nSol,:) = createEdge(sol(1:2),sol(3:4));
       # Find innerTangent
       inner(nSol,:) = intersectEdges(middleEdge,edgeTan(nSol,:));
      end

      i = i+1;
  end

endfunction

function res = belt(x,c,r)
  res = zeros(4,1);

  res(1,1) = (x(3:4) - c(2,1:2))*(x(3:4) - x(1:2))';
  res(2,1) = (x(1:2) - c(1,1:2))*(x(3:4) - x(1:2))';
  res(3,1) = sumsq(x(1:2) - c(1,1:2)) - r(1)^2;
  res(4,1) = sumsq(x(3:4) - c(2,1:2)) - r(2)^2;

end

%!demo
%!  c         = [0 0;1 3];
%!  r         = [1 0.5];
%!  [T inner] = beltproblem(c,r)
%!
%!  figure(1)
%!  clf
%!  h = drawEdge(T);
%!  set(h(find(~isnan(inner(:,1)))),'color','r');
%!  set(h,'linewidth',2);
%!  hold on
%!  drawCircle([c(1,:) r(1); c(2,:) r(2)],'linewidth',2);
%!  axis tight
%!  axis equal
%!
%! # -------------------------------------------------------------------
%! # The circles with the tangents edges are plotted. The solution with
%! # crossed belts (inner tangets) is shown in red.
