function Status = status(Constr, Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:11:24 $

XUnits = Constr.PhaseUnits;
YUnits = Constr.MagnitudeUnits;
PhaseOrigin = unitconv(Constr.OriginPha, 'deg', XUnits);
MarginGain  = unitconv(Constr.MarginGain, 'dB', YUnits);

switch Context
case 'move'
   % Status update when completing move
   Status = sprintf('New gain margin constraint is %0.3g %s at %0.3g %s.', ...
      MarginGain, YUnits, PhaseOrigin, XUnits);
   
case 'resize'
   % Post new slope
   Status = sprintf('New gain margin constraint is %0.3g %s at %0.3g %s.', ...
      MarginGain, YUnits, PhaseOrigin, XUnits);
   
case 'hover'
   % Status when hovered
   str = sprintf('Design constraint: gain margin < %0.3g %s at %0.3g %s.', ...
      MarginGain, YUnits, PhaseOrigin, XUnits);
   Status = sprintf('%s\nLeft-click and drag to move this constraint.', str);
   
case 'hovermarker'
   % Status when hovering over markers
   str = sprintf('Design constraint: gain margin < %0.3g %s at %0.3g %s.', ...
      MarginGain, YUnits, PhaseOrigin, XUnits);
   Status = sprintf('%s\nLeft-click and drag to resize this constraint.', str);
end
