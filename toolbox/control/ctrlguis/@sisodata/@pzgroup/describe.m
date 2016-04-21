function Description = describe(Group,Ts)
%DESCRIBE  Provides group description.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 04:52:40 $


if Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end

% Construct description
switch Group.Type  
case 'Real'
    % Real pole/zero
    if isempty(Group.Pole)
        R = Group.Zero;   ID = 'Zero';
    else
        R = Group.Pole;   ID = 'Pole';
    end
    Description = {ID ; sprintf('real compensator %s at %s = %.3g',lower(ID),DomainVar,R)};
    
case 'Complex'
    % Complex pole/zero
    if isempty(Group.Pole)
        R = Group.Zero(1);   ID = 'Zero';
    else
        R = Group.Pole(1);   ID = 'Pole';
    end
    Description = {ID ; sprintf('complex pair of compensator %ss at %s = %.3g %s %.3gi',...
            lower(ID),DomainVar,real(R),char(177),abs(imag(R)))};
        
case 'LeadLag'
   % Lead or lag network (s+tau1)/(s+tau2) 
   if (~Ts & Group.Pole<=Group.Zero) | (Ts & abs(Group.Pole)<=abs(Group.Zero))
       ID = 'Lead';
   else
       ID = 'Lag';
   end
   Description = {ID ; sprintf('%s network with zero at %s = %.3g and pole at %s = %.3g',...
           lower(ID),DomainVar,Group.Zero,DomainVar,Group.Pole)};
   
case 'Notch'
   % Notch filter. 
   Z = Group.Zero(1);
   P = Group.Pole(1);
   Description = {'Notch';sprintf('notch filter with zeros at %s = %.3g %s %.3gi and poles at %s = %.3g %s %.3gi',...
       DomainVar,real(Z),char(177),abs(imag(Z)),DomainVar,real(P),char(177),abs(imag(P)))};
end
