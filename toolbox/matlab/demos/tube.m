function tube(xy,ab,rtr,pq,box,vue)
%TUBE   Generating function for Edward's parametric curves.
%   tube(xy,ab,rtr,pq)) takes the following arguments:
%
%   xy = string name of function  [xt,yt] = xy(t)
%        defining parametric curve to be revolved
%   ab = [a b] = interval of defn of parametric curve
%   rtr = [radius twist revs] for revolution of curve
%   pq = [p q] = numbers of t- and u-subintervals
%   box = [x1 x2 y1 y2 z1 z2]  for viewing tube

%   C. Henry Edwards, University of Georgia. 6-20-93.
%
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/10 23:25:52 $

a = ab(1);   b = ab(2);
p = pq(1);   q = pq(2);
h = (b-a)/p;
t = a : h : b;

radius = rtr(1);
twist  = rtr(2);
revs   = rtr(3);

k = 2*revs*pi/q;
u = 0 : k : 2*revs*pi;

[tt,uu] = meshgrid(t,u);

xx = (radius + xpr(xy, tt, twist*uu)).*cos(uu);
yy = (radius + xpr(xy, tt, twist*uu)).*sin(uu);
zz = xpz(xy, tt, twist*uu);

surf(xx,yy,zz)
axis(box)
axis('off')
if nargin > 5 
   view(vue)
end


function  w = xpz(xy,t,u)
%XPZ    z-coordinate of t-point of xy-curve rotated through angle u.
 
[xt,yt] = feval(xy,t);

w = xt.*sin(u) + yt.*cos(u);

function  w = xpr(xy,t,u)
%XPR    Radial coordinate of t-point of xy-curve rotated through angle u.

[xt,yt] = feval(xy,t);

w = xt.*cos(u) - yt.*sin(u);


function  [xt,yt] = xylink1a(t)
%XYLINK1A Coordinates of an off-center circle.
%   XYLINK1A returns the coordinates of an off-center
%   circle used to generated a torus for TORI4.

xt = 1 + 0.5*cos(t);  
yt = 1 + 0.5*sin(t);


function  [xt,yt] = xylink1b(t)
%XYLINK1B Coordinates of an off-center circle.
%   XYLINK1B returns the coordinates of an off-center
%   circle used to generated a torus for TORI4.
 
xt = -1 + 0.5*cos(t);   yt = 1 + 0.5*sin(t);


function  [xt,yt] = xylink1c(t)
%XYLINK1C Coordinates of an off-center circle.
%   XYLINK1C returns the coordinates of an off-center
%   circle used to generated a torus for TORI4.

xt = -1 + 0.5*cos(t);   yt = -1 + 0.5*sin(t);


function  [xt,yt] = xylink1d(t)
%XYLINK1D Coordinates of an off-center circle.
%   XYLINK1D returns the coordinates of an off-center
%   circle used to generated a torus for TORI4.
 
xt = 1 + 0.5*cos(t);   yt = -1 + 0.5*sin(t);
