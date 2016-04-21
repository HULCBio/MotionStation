function rotate(h,azel,alpha,origin)
%ROTATE Rotate objects about specified origin and direction.
%   ROTATE(H,[THETA PHI],ALPHA) rotates the objects with handles H
%   through angle ALPHA about an axis described by the 2-element
%   direction vector [THETA PHI] (spherical coordinates).  
%   All the angles are in degrees.  The handles in H must be children
%   of the same axes.
%
%   THETA is the angle in the xy plane counterclockwise from the
%   positive x axis.  PHI is the elevation of the direction vector
%   from the xy plane (see also SPH2CART).  Positive ALPHA is defined
%   as the righthand-rule angle about the direction vector as it
%   extends from the origin.
%
%   ROTATE(H,[X Y Z],ALPHA) rotates the objects about the direction
%   vector [X Y Z] (Cartesian coordinates). The direction vector
%   is the vector from the center of the plot box to (X,Y,Z).
%
%   ROTATE(...,ORIGIN) uses the point ORIGIN = [x0,y0,y0] as
%   the center of rotation instead of the center of the plot box.
%
%   See also SPH2CART, CART2SPH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.17.4.2 $  $Date: 2004/04/10 23:32:20 $

% Determine the default origin (center of plot box).
if nargin < 4
  ax = ancestor(h(1),'axes');
  if isempty(ax) | ax==0,
    error('H must contain axes children only.');
  end
  origin = sum([get(ax,'xlim')' get(ax,'ylim')' get(ax,'zlim')'])/2;
end

% find unit vector for axis of rotation
if prod(size(azel)) == 2 % theta, phi
    theta = pi*azel(1)/180;
    phi = pi*azel(2)/180;
    u = [cos(phi)*cos(theta); cos(phi)*sin(theta); sin(phi)];
elseif prod(size(azel)) == 3 % direction vector
    u = azel(:)/norm(azel);
end

alph = alpha*pi/180;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = u(1);
y = u(2);
z = u(3);
rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
       x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
       x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';

for i=1:prod(size(h)),
  t = get(h(i),'type');
  skip = 0;
  if strcmp(t,'surface') | strcmp(t,'patch') | strcmp(t,'line')
    x = get(h(i),'xdata');
    y = get(h(i),'ydata');
    z = get(h(i),'zdata');
    if isempty(z)
       z = -origin(3)*ones(size(y));
    end
    [m,n] = size(z);
    if prod(size(x)) < m*n
      [x,y] = meshgrid(x,y);
    end
  elseif strcmp(t,'text')
    p = get(h(i),'position');
    x = p(1); y = p(2); z = p(3);
  elseif strcmp(t,'image')
    x = get(h(i),'xdata');
    y = get(h(i),'ydata');
    z = zeros(size(x));
  else
    skip = 1;
  end
  
  if ~skip,
    [m,n] = size(x);
    newxyz = [x(:)-origin(1), y(:)-origin(2), z(:)-origin(3)];
    newxyz = newxyz*rot;
    newx = origin(1) + reshape(newxyz(:,1),m,n);
    newy = origin(2) + reshape(newxyz(:,2),m,n);
    newz = origin(3) + reshape(newxyz(:,3),m,n);

    if strcmp(t,'surface') | strcmp(t,'patch') | strcmp(t,'line')
      set(h(i),'xdata',newx,'ydata',newy,'zdata',newz);
    elseif strcmp(t,'text')
      set(h(i),'position',[newx newy newz])
    elseif strcmp(t,'image')
      set(h(i),'xdata',newx,'ydata',newy)
    end
  end
end
