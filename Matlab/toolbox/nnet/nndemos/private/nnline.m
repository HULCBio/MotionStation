function h = nnline(x,y,w,c,e)
%NNLINE Draw line connecting series of points.
%
%  NNLINE(X,Y,W,C,E)
%    X - Vector of horizontal coordinates.
%    Y - Vector of vertical coordinates.
%    W - Width of line (default = 1).
%    C - Color of line (default = white).
%    E - Erase mode (default = 'normal').

% Mark Beale 6-4-94
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

% DEFAULTS
if nargin < 2, error('Not enough input arguments.'), end
if nargin < 3, w = 1; end
if nargin < 4, c = [1 1 1]; end
if nargin < 5, e = 'normal'; end

% STORE AXIS STATE
NP = get(gca,'nextplot');
set(gca,'nextplot','add');

rect = [-1 1 1 -1;
        -1 -1 1 1]*(w/2);
lines = length(x)-1;
X = zeros(6,lines);
Y = zeros(6,lines);

% DRAW EACH LINE SEGMENT
for i=1:lines
  x1 = x(i); x2 = x(i+1);
  y1 = y(i); y2 = y(i+1);
  
  rect1 = [x1+rect(1,:); y1+rect(2,:)];
  rect2 = [x2+rect(1,:); y2+rect(2,:)];
  
  % CALCULATE LINE EDGES
  if (y1 <= y2)
    
    % FIRST QUADRANT
    if (x1 <= x2)
      the_line = [rect1(:,[1 2]) rect2(:,[2 3 4]) rect1(:,4)];
    
    % SECOND QUADRANT
    else
      the_line = [rect1(:,[1 2 3]) rect2(:,[3 4 1])];
    end
  
  else
    % THIRD QUADRANT
    if (x1 >= x2)
      the_line = [rect1(:,[2 3 4]) rect2(:,[4 1 2])];
    
    % FOURTH QUADRANT
    else
      the_line = [rect1(:,1) rect2(:,[1 2 3]) rect1(:,[3 4])];
    end
  end
  
  X(:,i) = the_line(1,:)';
  Y(:,i) = the_line(2,:)';
  
end % FOR LOOP

g = fill(X,Y,c,'edgecolor','none','erasemode',e);

% RESTORE AXIS STATE
set(gca,'nextplot',NP);

% RETURN THE LINE
if nargout, h = g; end

