function Status = status(Constr, Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 05:11:58 $

XUnits = Constr.PhaseUnits;
YUnits = Constr.MagnitudeUnits;
PhaseOrigin = unitconv(Constr.OriginPha, 'deg', XUnits);
PeakGain    = unitconv(Constr.PeakGain,   'dB', YUnits);

switch Context
 case 'move'
  % Status update when completing move
  Status = sprintf('New peak gain constraint is %0.3g %s at %0.3g %s.', ...
		   PeakGain, YUnits, PhaseOrigin, XUnits);
  
 case 'resize'
  % Post new slope
  Status = sprintf('New peak gain constraint is %0.3g %s at %0.3g %s.', ...
		   PeakGain, YUnits, PhaseOrigin, XUnits);
  
 case 'hover'
  % Status when hovered
  str = sprintf('Design constraint: closed-loop peak gain < %0.3g %s at %0.3g %s.', ...
		PeakGain, YUnits, PhaseOrigin, XUnits);
  Status = sprintf('%s\nLeft-click and drag to move this constraint.', str);
  
 case 'hovermarker'
  % Status when hovering over markers
  str = sprintf('Design constraint: closed-loop peak gain < %0.3g %s at %0.3g %s.', ...
		PeakGain, YUnits, PhaseOrigin, XUnits);
  Status = sprintf('%s\nLeft-click and drag to resize this constraint.', str);
end
