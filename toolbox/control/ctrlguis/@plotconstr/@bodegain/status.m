function Status = status(Constr,Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:08:07 $

XUnits = Constr.FrequencyUnits;
Freqs = unitconv(Constr.Frequency,'rad/sec',XUnits);

switch Context
case 'move'
    % Status upodate when completing move
    Status = sprintf('New gain constraint location is from %0.3g to %0.3g %s.',...
        Freqs(1),Freqs(2),XUnits);
case 'resize'
    % Post new slope
    LocStr = sprintf('The gain constraint new location is from %0.3g to %0.3g %s',...
        Freqs(1),Freqs(2),XUnits);
    SlopeStr = sprintf('with a slope of %d dB/decade.',slope(Constr));
    Status = sprintf('%s\n%s',LocStr,SlopeStr);    
case 'hover'
    % Status when hovered
    Type = Constr.Type;  Type(1) = upper(Type(1));
    Description = sprintf('%s gain limit with slope %d dB/decade.',Type,slope(Constr));
    Status = sprintf('%s\nLeft-click and drag to move this gain constraint.',Description);   
case 'hovermarker'
    % Status when hovering over markers
    Status = sprintf('Select and drag to adjust extent and slope of gain constraint.');
    
end

