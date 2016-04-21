function [x,y] = joinicon(orient,polar,split)
%JOINICON  Create icons for complex "Join" or a "Split" blocks
%    [X,Y] = JOINICON(ORIENT,POLAR,SPLIT) returns vectors which can be
%    used in a plot command inside a block mask to indicate
%    a complex join (or split with the orientation reversed).
%
%    ORIENT is a string indicating the orientation of the block:
%       up    ==> bottom-to-top
%	down  ==> top-to-bottom,
%       left  ==> right-to-left,
%       right ==> left-to-right,
%
%    POLAR indicates whether polar notation should be used
%      (magnitude and angle indicators).
%    SPLIT indicates whether a split (vs. a join) should be drawn

%    T. Krauss, 12-9-94
%    Revised: D. Orofino
%    Copyright 1995-2002 The MathWorks, Inc.
%    $Revision: 1.8 $  $Date: 2002/04/14 20:52:39 $

if nargin<1, orient='right'; end
if nargin<2, polar=0; end
if nargin<3, split=0; end

% Compatibility:
% The split and join blocks in V1.0a used the construct
% "joinicon(o+2)", where "o" was the orientation and assumed
% to be a numeric value.  Now, "o" is a string, and adding 2
% is no longer appropriate.  We need to translate:
if ~isstr(orient),
  orient=char(orient-2);
  switch orient
  case 'right',
    orient = 'left';
  case 'down',
    orient = 'up';
  case 'left',
    orient = 'right';
  case 'up',
    orient = 'down';
  end
end

if split,
  % Reverse the orientation:
  switch orient
  case 'up',   orient='down';
  case 'down', orient='up';
  case 'left', orient='right';
  otherwise,   orient='left';
  end
  % dirs={'up','down','left','right'};
  % orient = dirs{bitxor(strmatch(orient,dirs)-1,1)+1};
end

if ~polar,
  % Cartesian coordinates:

  % Default orientation is 'right':
  x = [79 60 40 0; 79 60 40 0]';
  y = [55 55 76 76; 45 45 25 25]';

  switch orient
  case 'up'    % bottom-to-top
    xx = x;  x = y;  y = xx;   % swap x and y 
    x = 100 - x;
  case 'down'  % top-to-bottom
    xx = x;  x = y;  y = xx;   % swap x and y 
    y = 100 - y;
  case 'left'  % right-to-left
    x = 100 - x;
  end

else
  % Polar coordinates:

  magshapex = [20 20 20 20 20; 
               40 40 40 40 40; 
               30 32 30 28 30 ]' - 30;
  magshapey = [60 90 90 90 90;
               60 90 90 90 90;
               76 74 72 74 76]' - 75;

  angleshapex = [ 40 20 40 40 40;
                  31 32 33 34 34 ]' - 30;
  angleshapey = [ 15 15 35 35 35;
                  25 22 20 17 15 ]' - 25;

  x = [79 65 52 45 45; 79 65 53 45 45]';
  y = [55 55 75 75 75; 45 45 25 25 25]';

  switch orient
  case 'down', % top-to-bottom
    xx = x;  x = y;  y = xx;   % swap x and y 
    y = 100 - y;
    x = [x magshapex+25 angleshapex+75];
    y = [y magshapey+70 angleshapey+70];
  case 'left', % right-to-left
    x = 100 - x;
    x = [x magshapex+70 angleshapex+70];
    y = [y magshapey+75 angleshapey+25];
  case 'up',   % bottom-to-top
    xx = x;  x = y;  y = xx;   % swap x and y 
    x = 100 - x;
    x = [x magshapex+25 angleshapex+75];
    y = [y magshapey+30 angleshapey+30];
  otherwise,   % left-to-right
    x = [x magshapex+30 angleshapex+30];
    y = [y magshapey+75 angleshapey+25];
  end
end
