function moveptr(Axes,action,X,Y)
%MOVEPTR  Adjusts pointer position when changing axes limits.
%
%   MOVEPTR(AXES,'init') initializes the move.
%
%   MOVEPTR(AXES,'move',X,Y) moves the pointer to the new position (X,Y) in
%   data units (axes coordinates).
%
%   Only for single axes.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 04:43:35 $

persistent Transform isLogX isLogY

switch action(1)
case 'i'  % init
   % Compute the transformation from norm. axis position to screen position
   Transform = LocalAxis2Screen(Axes);   
   isLogX = strcmp(Axes.XScale,'log');
   isLogY = strcmp(Axes.YScale,'log');
   
case 'm'  % move pointer
   % Move pointer
   Xlim = Axes.Xlim;      % X limits
   Ylim = Axes.Ylim;      % Y limits
   
   % Compute normalized axis coordinates
   if isLogX,
       NormX = (log2(X) - log2(Xlim(1))) / (log2(Xlim(2))-log2(Xlim(1)));
   else
       NormX = (X-Xlim(1)) / (Xlim(2)-Xlim(1));
   end
   if isLogY,
       NormY = (log2(Y)-log2(Ylim(1))) / (log2(Ylim(2))-log2(Ylim(1)));
   else
       NormY = (Y-Ylim(1)) / (Ylim(2)-Ylim(1));
   end
   
   % Reset pointer location.
   % RE: When pointer is reset in each cycle, use dead zone to prevent drifting
   DeadZone = 0.02;
   NewLoc = Transform(1:2) + Transform(3:4) .* [NormX NormY];
   if any(abs(get(0,'PointerLocation')-NewLoc) > DeadZone*Transform(3:4))
      set(0,'PointerLocation',NewLoc)
   end
   
end


%----------------- Local functions -----------------


%%%%%%%%%%%%%%%%%%%%
% LocalAxis2Screen %
%%%%%%%%%%%%%%%%%%%%
function T = LocalAxis2Screen(ax)
% Axis to screen coordinate transformation.
%
%   T = AXIS2SCREEN(AX) computes a coordinate transformation 
%       T = [xo yo rx ry] 
%   that relates the normalized axes coordinates [xa;ya] of a 
%   given point to its screen coordinate [xs;ys] (in the root 
%   units) by
%       xs = xo + rx * xa
%       ys = yo + ry * ya
%
%   See also SISOTOOL.

% Get axes normalized position in figure
AxisPos = LocalGetNormPos(ax);

% Get figure's normalized position in screen
FigPos = LocalGetNormPos(get(ax,'Parent'));

% Transformation norm. axis coord -> norm. fig. coord.
T = AxisPos;

% Transformation norm. axis coord -> norm. screen coord.
T(1:2) = FigPos(1:2) + FigPos(3:4) .* T(1:2);
T(3:4) = FigPos(3:4) .* T(3:4);

% Transform to screen units
ScreenSize = get(0,'ScreenSize');
T(1:2) = ScreenSize(1:2) + ScreenSize(3:4) .* T(1:2);
T(3:4) = ScreenSize(3:4) .* T(3:4);


%%%%%%%%%%%%%%%%%%%
% LocalGetNormPos %
%%%%%%%%%%%%%%%%%%%
function Pos = LocalGetNormPos(Handle)
%   Determine if mag. plot is slipping out of focus.

Units = get(Handle,'Units');
if strcmp(Units,'normalized')
   Pos = get(Handle,'Position');
else
   set(Handle,'Units','normalized')
   Pos = get(Handle,'Position');
   set(Handle,'Units',Units)
end
