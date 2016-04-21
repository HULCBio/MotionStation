function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:10:23 $

f = unitconv(Constr.Frequency,'rad/sec',Constr.FrequencyUnits);

switch Context
case 'move'
    % Status update when completing move
    if strcmpi(Constr.Type,'upper')
        lgt = 'most';
    else
        lgt = 'least';
    end
    Status = sprintf('Natural frequency required to be at %s %0.3g %s.',...
        lgt,f,Constr.FrequencyUnits);
    
case 'hover'
    % Status when hovered
    if strcmpi(Constr.Type,'upper')
        lgt = '<';
    else
        lgt = '>';
    end
    Description = sprintf('Design constraint: natural frequency %s %.3g %s.',...
        lgt,f,Constr.FrequencyUnits);
    Status = sprintf('%s\nLeft-click and drag to change natural frequency value.',Description);
    
end

	