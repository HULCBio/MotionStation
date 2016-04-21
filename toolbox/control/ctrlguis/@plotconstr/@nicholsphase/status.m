function Status = status(Constr, Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:09:45 $

XUnits = Constr.PhaseUnits;
YUnits = Constr.MagnitudeUnits;
MarginPhase = unitconv(Constr.MarginPha, 'deg', XUnits);
PhaseOrigin = unitconv(Constr.OriginPha, 'deg', XUnits);

switch Context
 case 'move'
  % Status update when completing move
  Status = sprintf('New phase margin constraint is %0.3g %s at %0.3g %s.', ...
		   MarginPhase, XUnits, PhaseOrigin, XUnits);
  
 case 'resize'
  % Post new size
  Status = sprintf('New phase margin constraint is %0.3g %s at %0.3g %s.', ...
		   MarginPhase, XUnits, PhaseOrigin, XUnits);
  
 case 'hover'
  % Status when hovered
  str = sprintf('Design constraint: phase margin < %0.3g %s at %0.3g %s.', ...
		MarginPhase, XUnits, PhaseOrigin, XUnits);
  Status = sprintf('%s\nLeft-click and drag to move this constraint.', str);
  
 case 'hovermarker'
  % Status when hovering over markers
  str = sprintf('Design constraint: phase margin < %0.3g %s at %0.3g %s.', ...
		MarginPhase, XUnits, PhaseOrigin, XUnits);
  Status = sprintf('%s\nLeft-click and drag to resize this constraint.', str);
end
