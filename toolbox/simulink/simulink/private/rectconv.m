function rout=rectconv(rin,style)
%RECTCONV Conversion function for SIMULINK and HG rectangles.
%   ROUT=RECTCONV(RIN,STYLE) converts a SIMULINK style rectangle
%   (top,left,bottom,right) to a Handle Graphics style rectangle
%   (left,bottom,width,height) or vice versa.  The input variable
%   STYLE specifies the style that the input rectangle is converted
%   to.  Specify a style as 'simulink' to convert to a SIMULINK
%   rectangle, 'hg' to convert to a Handle Graphics rectangle.
%   Note that all rectangle units are in pixels.
%
%   Example:
%
%      rhg=rectconv(rsl,'simulink');    % convert rect to SIMULINK
%      rsl=rectconv(rhg,'hg');          % convert rect to Handle Graphics

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $

switch lower(style),

  case { 'handlegraphics','hg'}
    rout=InternalSimRect2HGRect(rin);

  case { 'simulink','sl' }
    rout=InternalHGRect2SimRect(rin);

  otherwise,
    error('Rectangle style is either ''simulink'' or ''handlegraphics''');

end



%******************************************************************************
% Function - Converts a SIMULINK rectangle [left, top, right, bottom]       ***
%  into a Handle Graphics rectangle [left, bottom, width, height].          ***
%******************************************************************************
function rout=InternalSimRect2HGRect(rin)

origRootUnits = get(0, 'Units');
set(0,'Units','pixel');
screen = get(0, 'ScreenSize');
set(0,'Units',origRootUnits);


% SIMULINK rects [left top    right bottom] - from the screen top
% HG rects       [left bottom width height] - from the screen bottom

rout=zeros(1,4);
rout(1) = rin(1);             % left is the left
rout(2) = screen(4)-rin(4);   % bottom is screen height - bottom
rout(3) = rin(3)-rin(1);      % width is right - left
rout(4) = rin(4)-rin(2);      % height is bottom - height


%******************************************************************************
% Function - Converts a Handle Graphics rectangle,                          ***
%  [left, bottom, width, height] into a SIMULINK rectangle,                 ***
%  [left, top, right, bottom].                                              ***
%******************************************************************************
function rout=InternalHGRect2SimRect(rin)

origRootUnits = get(0, 'Units');
set(0,'Units','pixel');
screen = get(0, 'ScreenSize');
set(0,'Units',origRootUnits);

% HG rects       [left bottom width height] - from the screen bottom
% SIMULINK rects [left top    right bottom] - from the screen top

rout=zeros(1,4);
rout(1) = rin(1);                   % left is the left
rout(2) = screen(4)-rin(2)-rin(4);  % top is screen height - bottom - height
rout(3) = rin(1)+rin(3);            % right is left + width
rout(4) = screen(4)-rin(2);         % bottom is screen height - bottom
