function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:10:53 $

switch Context
case 'move'
	% Status update when completing move
    if strcmpi(Constr.Format,'damping')
        Status = sprintf('Requires damping of at least %0.3g.',Constr.Damping);
    else
        Status = sprintf('Requires overshoot of at most %0.3g %s.',Constr.overshoot,'%');
    end
    
case 'hover'
    % Status when hovered
    Description = sprintf('Design constraint: damping > %.3g (overshoot < %.3g %s).',...
        Constr.Damping,Constr.overshoot,'%');
    Status = sprintf('%s\nLeft-click and drag to change damping/overshoot value.',Description);
        
end
	
	