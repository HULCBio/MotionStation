function h = nndrwlin(x,y,w,c)
%NNDRWLIN Neural Network Design utility function.

%  NNDRWLIN(X,Y,W,C)
%    X - Vector of horizontal coordinates.
%    Y - Vector of vertical coordinates.
%    W - Width of line.
%    C - Color of line.
%  Draws a line.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

% STORE AXIS STATE
NP = get(gca,'nextplot');
set(gca,'nextplot','add');

% MAKE SURE NO LINE IS EXACTLY VERTICAL
points = length(x);
lines = points-1;
for i=1:lines
  if x(i) == x(i+1), x(i) = x(i) + 1e-6; end
end

w = 0.5*w;
x1 = x(1:lines);   y1 = y(1:lines);
x2 = x(2:lines+1); y2 = y(2:lines+1);
m = zeros(1,lines);
b = m;
b1 = m;
b2 = m;
xa = zeros(1,points);
xb = xa;
ya = xa;
yb = xa;

% CALCULATE LINE EDGES
for i=1:lines

  % CALCULATE SLOPE OF LINE
  if (y1(i) == y2(i))
    b(i) = y1(i);
    if x1(i) < x2(i)
      m(i) = 0;
      invm = -inf;
      b1(i) = b(i)+w;
      b2(i) = b(i)-w;
    else
      m(i) = 0;
      invm = inf;
      b1(i) = b(i)-w;
      b2(i) = b(i)+w;
    end
  elseif (x2(i) == x1(i))
    if y1(i) < y2(i)
      m(i) = inf;
    else
      m(i) = -inf;
    end
    invm = 0;
    b(i) = y1(i);
    b1(i) = b(i);
    b2(i) = b(i);
  else
    m(i) = (y2(i)-y1(i))/(x2(i)-x1(i));
    signy = sign((y2(i)-y1(i)));
    signx = sign((x2(i)-x1(i)));
    signboth = signx*signy;
    
    b(i) = y1(i)-m(i)*x1(i);
    invm = -(1/m(i));
    db = w*(1/sqrt(m(i)^2+1) + signboth*m(i)/sqrt(invm^2+1));
    b1(i) = b(i)+db * signx;
    b2(i) = b(i)-db * signx;
  end

  % FIRST POINT
  if i == 1
    if finite(m(1))
      if (m(1) ~= 0), dx = signy*w/sqrt(invm^2+1); else dx = 0; end
      xa(1) = x1(1)-dx;
      xb(1) = x1(1)+dx;
      ya(1) = m(1)*xa(1)+b1(1);
      yb(1) = m(1)*xb(1)+b2(1);
    else
      xa(1) = x1(1)-sign(m(1))*w;
      xb(1) = x1(1)+sign(m(1))*w;
      ya(1) = y1(1);
      yb(1) = y1(1);
    end
    % plot([xa(1) xb(1)],[ya(1) yb(1)])
  
  % MID POINTS
  else
    if finite(m(i))
      if finite(m(i-1))
        xa(i) = (b1(i-1)-b1(i))/(m(i)-m(i-1));
        xb(i) = (b2(i-1)-b2(i))/(m(i)-m(i-1));
        ya(i) = m(i)*xa(i)+b1(i);
        yb(i) = m(i)*xb(i)+b2(i);
      else
        xa(i) = x1(i)-w;
        xb(i) = x1(i)+w;
        ya(i) = m(i)*xa(i)+b1(i);
        yb(i) = m(i)*xb(i)+b2(i);
      end
    else
      xa(i) = x1(i)-w;
      xb(i) = x1(i)+w;
      ya(i) = m(i-1)*xa(i)+b1(i-1);
      yb(i) = m(i-1)*xb(i)+b2(i-1);
    end
    % plot([xa(i) xb(i)],[ya(i) yb(i)])
  end
  
  % LAST POINT
  if i == lines
    if finite(m(lines))
      if (m(lines) ~= 0), dx = signy*w/sqrt(invm^2+1); else dx = 0; end
      xa(points) = x2(lines)-dx;
      xb(points) = x2(lines)+dx;
      ya(points) = m(lines)*xa(points)+b1(lines);
      yb(points) = m(lines)*xb(points)+b2(lines);
    else
      xa(points) = x2(lines)+sign(m(lines))*w;
      xb(points) = x2(lines)-sign(m(lines))*w;
      ya(points) = y2(lines);
      yb(points) = y2(lines);
    end
    % plot([xa(points) xb(points)],[ya(points) yb(points)])
  end
end

% DRAW THE LINE
xx = [xb(1) xa fliplr(xb)];
yy = [yb(1) ya fliplr(yb)];
g = fill(xx,yy,c,'edgecolor','none');

% RESTORE AXIS STATE
set(gca,'nextplot',NP);

% RETURN THE LINE
if nargout, h = g; end
