function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 05:08:31 $

switch Context
case 'move'
	% Status update when completing move
	Status = sprintf('Settling time required to be at most %0.3g seconds.',...
		Constr.SettlingTime);
	
case 'hover'
    % Status when hovered
    Description = sprintf('Design constraint: settling time < %.3g sec.',Constr.SettlingTime);
    Status = sprintf('%s\nLeft-click and drag to change settling time value.',Description);
    
end
	
	