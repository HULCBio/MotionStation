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
## @deftypefn {Function File} {[@var{pline2} @var{idx}] = } simplifypolyline (@var{pline})
## @deftypefnx {Function File} {@dots{} = } simplifypolyline (@dots{},@var{property},@var{value},@dots{})
## Simplify or subsample a polyline using the Ramer-Douglas-Peucker algorithm,
## a.k.a. the iterative end-point fit algorithm or the split-and-merge algorithm.
##
## The @var{pline} as a N-by-2 matrix. Rows correspond to the
## verices (compatible with @code{polygons2d}). The vector @var{idx} constains
## the indexes on vetices in @var{pline} that generates @var{pline2}, i.e.
## @code{pline2 = pline(idx,:)}.
##
## @strong{Parameters}
## @table @samp
## @item 'Nmax'
## Maximum number of vertices. Default value @code{1e3}.
## @item 'Tol'
## Tolerance for the error criteria. Default value @code{1e-4}.
## @item 'MaxIter'
## Maximum number of iterations. Default value @code{10}.
## @item 'Method'
## Not implemented.
## @end table
##
## Run @code{demo simplifypolyline} to see an example.
##
## @seealso{curve2polyline, curveval}
## @end deftypefn

function [pline idx] = simplifypolyline (pline_o, varargin)
## TODO do not print warnings if user provided Nmax or MaxIter.

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "simplifypolyline";
  parser = addParamValue (parser,'Nmax', 1e3, @(x)x>0);
  toldef = 1e-4;#max(sumsq(diff(pline_o),2))*2;
  parser = addParamValue (parser,'Tol', toldef, @(x)x>0);
  parser = addParamValue (parser,'MaxIter', 100, @(x)x>0);
  parser = parse(parser,varargin{:});

  Nmax      = parser.Results.Nmax;
  tol       = parser.Results.Tol;
  MaxIter   = parser.Results.MaxIter;

  clear parser toldef
  msg = ["simplifypolyline: Maximum number of points reached with maximum error #g." ...
       " Increase #s if the result is not satisfactory."];
  # ------ #

  [N dim] = size(pline_o);
  idx = [1 N];

  for iter = 1:MaxIter
    # Find the point with the maximum distance.
    [dist ii] = maxdistance (pline_o, idx);

    tf = dist > tol;
    n = sum(tf);
    if all(!tf);
      break;
    end

    idx(end+1:end+n) = ii(tf);
    idx = sort(idx);

    if length(idx) >= Nmax
      ## TODO remove extra points
      warning('geometry:MayBeWrongOutput', sprintf(msg,max(dist),'Nmax'));
      break;
    end

  end
  if iter == MaxIter
    warning('geometry:MayBeWrongOutput', sprintf(msg,max(dist),'MaxIter'));
  end

  pline = pline_o(idx,:);
endfunction

function [dist ii] = maxdistance (p, idx)

  ## Separate the groups of points according to the edge they can divide.
  func = @(x,y) x:y;
  idxc   = arrayfun (func, idx(1:end-1), idx(2:end), "UniformOutput",false);
  points = cellfun (@(x)p(x,:), idxc, "UniformOutput",false);

  ## Build the edges
  edges = [p(idx(1:end-1),:) p(idx(2:end),:)];
  edges = mat2cell (edges, ones(1,size(edges,1)), 4)';

  ## Calculate distance between the points and the corresponding edge
  [dist ii] = cellfun(@dd, points,edges,idxc);

endfunction

function [dist ii] = dd (p,e,idx)
  [d pos] = distancePointEdge(p,e);
  [dist ii] = max(d);
  ii = idx(ii);
endfunction

%!demo
%! t     = linspace(0,1,100).';
%! y     = polyval([1 -1.5 0.5 0],t);
%! pline = [t y];
%!
%! figure(1)
%! clf
%! plot (t,y,'-r;Original;','linewidth',2);
%! hold on
%!
%! tol    = [8 2  1 0.5]*1e-2;
%! colors = jet(4);
%!
%! for i=1:4
%!   pline_ = simplifypolyline(pline,'tol',tol(i));
%!   msg = sprintf('-;#g;',tol(i));
%!   h = plot (pline_(:,1),pline_(:,2),msg);
%!   set(h,'color',colors(i,:),'linewidth',2,'markersize',4);
%! end
%! hold off
%!
%! # ---------------------------------------------------------
%! # Four approximations of the initial polyline with decreasing tolerances.

%!demo
%! P       = [0 0; 3 1; 3 4; 1 3; 2 2; 1 1];
%! func    = @(x,y) linspace(x,y,5);
%! P2(:,1) = cell2mat( ...
%!             arrayfun (func, P(1:end-1,1),P(2:end,1), ...
%!             'uniformoutput',false))'(:);
%! P2(:,2) = cell2mat( ...
%!             arrayfun (func, P(1:end-1,2),P(2:end,2), ...
%!             'uniformoutput',false))'(:);
%!
%! P2s = simplifypolyline (P2);
%!
%! plot(P(:,1),P(:,2),'s',P2(:,1),P2(:,2),'o',P2s(:,1),P2s(:,2),'-ok');
%!
%! # ---------------------------------------------------------
%! # Simplification of a polyline in the plane.
