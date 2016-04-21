function [xp,yp,ip] = lproject(x,y,xline,yline,ax)
%LPROJECT  Project point on polyline.
%
%   [XP,YP] = LPROJECT(X,Y,XLINE,YLINE) projects the point (X,Y)
%   onto the polyline specified by the points (XLINE(i),YLINE(i)).
%
%   [XP,YP] = LPROJECT(X,Y,XLINE,YLINE,AX) performs the projection
%   in normalized axis units so that (XP,YP) is the "visually
%   nearest" point.  AX should be the handle of the axes containing
%   the line in question.

%   Authors: P. Gahinet
%   Revised: A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 04:43:38 $

% RE: If one of the axes has a log scale, the corresponding input
% data (x,xline) should be passed through LOG2 and the result
% through POW2.

% Init
np = length(xline);
t = zeros(1,np-1);
d = zeros(1,np-1);

% Normalization
if nargin>4
   %---Axes handle is provided, so perform visual scaling
   [xs,ys] = localScaleFactors(ax);
   x = x/xs; xls = xline/xs;
   y = y/ys; yls = yline/ys;
else
   xls = xline;
   yls = yline;
end
   
% Compute projection P = t*A + (1-t)*B of M(x,y) on each segment [A,B]
xAB = xls(2:np) - xls(1:np-1);
yAB = yls(2:np) - yls(1:np-1);
xMB = xls(2:np)-x;
yMB = yls(2:np)-y;
AB2 = xAB.^2 + yAB.^2;
t = (xMB .* xAB + yMB .* yAB) ./ (AB2+(AB2==0));
t = max(0,min(t,1));

% Compute min distance square
d = (xMB-t.*xAB).^2 + (yMB-t.*yAB).^2;
[dmin,imin] = min(d);

% Nearest point is P(imin)
tmin = t(imin);
xp = tmin * xline(imin) + (1-tmin) * xline(imin+1);
yp = tmin * yline(imin) + (1-tmin) * yline(imin+1);
ip = imin + 1 - tmin;  % relative index


%%%%%%%%%%%%%%%%%%%%%
% localScaleFactors %
%%%%%%%%%%%%%%%%%%%%%
function [xs,ys] = localScaleFactors(AXES)
 %---Calculate XY scaling factors for axes
 lims = get(AXES,{'XLim','YLim'});
 scales = get(AXES,{'XScale','YScale'});
 if strcmpi(scales{1},'log')
    lims{1} = log2(lims{1});
 end
 if strcmpi(scales{2},'log')
    lims{2} = log2(lims{2});
 end
 NRT = get(AXES,'x_NormRenderTransform');
 xs = (lims{1}(2)-lims{1}(1))/NRT(1,1);
 ys = (lims{2}(2)-lims{2}(1))/abs(NRT(2,2));
