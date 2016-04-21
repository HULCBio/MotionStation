function drawarrow(this)
%DRAWARROW   Positions and sizes arrows.

%   Authors: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:21:54 $

[ny,nu] = size(this.PosCurves);
for ct=1:ny*nu
   ax = this.PosCurves(ct).Parent;
   Xlim = get(ax,'XLim');
   Ylim = get(ax,'YLim');
   % Positive freqs
   LocalPositionArrow(this.PosCurves(ct),this.PosArrows(ct),Xlim,Ylim,1);
   % Negative freqs
   if this.ShowFullContour
      LocalPositionArrow(this.NegCurves(ct),this.NegArrows(ct),Xlim,Ylim,-1);
   else
      set(this.NegCurves(ct),'Xdata',[],'Ydata',[])
   end
end

%----------------- Local Function ------------------------

function LocalPositionArrow(hline,harrow,Xlim,Ylim,Sign)
% RE: Assumes Ylim(1)=-Ylim(2)

% Get line data 
xdata = get(hline,'xdata');
ydata = get(hline,'ydata');
npts = length(xdata);

% Geometric parameters
xrange = Xlim(2)-Xlim(1);
yrange = Ylim(2)-Ylim(1);

% Shrink range to leave room for arrows
RelArrowSize = (0.5+get(hline,'LineWidth'))/40;
dX = xrange * RelArrowSize;  
dY = yrange * RelArrowSize;
Xlim = Xlim + [dX -dX];
Ylim = Ylim + [dY -dY];

% Select segment [A,B] where to plot the arrow 
% RE: A is always inside current axis limits
inscope = (xdata>Xlim(1) & xdata<Xlim(2) & ydata>Ylim(1) & ydata<Ylim(2));
[Ymax,iy] = max(abs(ydata));
if ~any(inscope),
   % No data in scope
   set(harrow,'Xdata',[],'Ydata',[])
   return
elseif all(inscope) | (inscope(iy) & Ymax>max(abs(Ylim))/100),
   % All data is in scope, or peak Y value is nonzero and in scope
   if ~any(ydata),
      % All data is real: pick mid point in x data range
      [junk,ia] = min(abs(xdata-(min(xdata)+max(xdata))/2));
   else
      % Pick point with largest |y| value
      ia = iy;
   end
   ib = ia-1+2*(ia==1);
elseif inscope(1),
   % Find first data point out of scope
   outs = find(~inscope);
   ib = outs(1);
   ia = ib-1;
else
   % Find first data point in scope   
   ins = find(inscope);
   ia = ins(1);
   ib = ia-1;
end
xa = xdata(ia);   
ya = ydata(ia);
xb = xdata(ib);  
yb = ydata(ib);

% Adjust position to place arrow inside and near axis limits
% (Find smallest t>0 s.t. A+t(B-A) intersect box [Xmin+dX Xmax-dX Ymin+dY Ymax-dY]
if xa==xb & ya==yb,
   % No arrow if (xa,ya)=(xb,yb) (e.g., sys = tf(1) )
   set(harrow,'Xdata',[],'Ydata',[])
   return
elseif prod(Xlim-xb)>=0 | prod(Ylim-yb)>=0,
   % (XB,YB) is outside of axis limits
   t = [];
   if xa~=xb,
      t = [t , (Xlim-xa)/(xb-xa)];
   end
   if ya~=yb, 
      t = [t , (Ylim-ya)/(yb-ya)];
   end
   t = min(t(t>0));   % smallest t>0 s.t. A+t(B-A) intersect box 
   if length(t),
      xa = xa + t * (xb-xa);
      ya = ya + t * (yb-ya);
   end
end

% Compute arrow extent
if all(inscope)
   sf = max((max(xdata)-min(xdata))/xrange,(max(ydata)-min(ydata))/yrange);
else
   sf = max((Xlim(2)-Xlim(1))/xrange,(Ylim(2)-Ylim(1))/yrange);
end
xsf = sf * dX;  % X arrow size
ysf = sf * dY;  % Y arrow size

% Determine (normalized) arrow direction DIR = B-A
dir = atan2((yb-ya)/yrange,(xb-xa)/xrange) + (Sign*(ib-ia)<0) * pi;

% Compute arrow position (tip at A, direction DIR)
Xarrow = xa + xsf * [cos(dir+5*pi/6);0;cos(dir-5*pi/6)];
Yarrow = ya + ysf * [sin(dir+5*pi/6);0;sin(dir-5*pi/6)];

% Compute offset to prevent arrow overlap when YA=0
offset = xsf/2 * (abs(ya)<ysf); 
if (xa-sum(Xlim)/2) * (xa-Xarrow(1))>0
    Xarrow = Xarrow + sign(Xarrow(1)-xa) * offset;
end

% Set position
set(harrow,'Xdata',Xarrow,'Ydata',Yarrow)
