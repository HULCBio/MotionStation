function doc_group1a
% Use Save As in the File menu to create 
% an editable version of this M-file
%

% Copyright 2003-2004 The MathWorks, Inc.

clf
% Create the surface and group objects
h = surf(peaks(40));view(-20,30)
t = hgtransform;

% Parent surface to group object
set(h,'Parent',t)

% Draw the surface and wait for 1 second
drawnow;pause(3)

% Convert angles in degrees to radians
ry_angle = -15*pi/180;% Rotate by -15 degrees

% Form y-axis rotation matrix
Ry = makehgtform('yrotate',ry_angle);

% Set transform matrix
set(t,'Matrix',Ry)

% Draw a line at the rotation axis and pause
line_handle = show_axis([0 0]); 
drawnow;pause(3)
 
% Undo rotation and pause
set(t,'Matrix',eye(4))
drawnow
pause(3)

Tx1 = makehgtform('translate',[-20 0 0]);
Tx2 = makehgtform('translate',[20 0 0]);
set(t,'Matrix',Tx2*Ry*Tx1)
show_axis(line_handle,[20 20]); % Move line to rotation axis

function varargout = show_axis(varargin)
% This function draws a line at the rotation axis
set(gca,'YLimMode','manual')
if nargin == 2
    set(varargin{1},'XData',varargin{2})
elseif nargin == 1
    hline = line(varargin{1},[-10 60],[0 0],...
      'LineWidth',2,...
      'Color','black',...
      'Clipping','off');
  varargout = {hline};
end
