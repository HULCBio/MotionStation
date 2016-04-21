function Status = movelog(Group,PZID,Ts)
%MOVELOG  Generate log entry with new location of moved root

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 04:52:43 $

if Ts
    DomainVar = 'z';
else
    DomainVar = 's';
end

switch Group.Type
case {'Real','LeadLag'}
    R = get(Group,PZID);
    Status = sprintf('Moved the selected real %s to %s = %.3g',lower(PZID),DomainVar,R);
case 'Complex'
    R = get(Group,PZID);
    Status = sprintf('Moved the selected complex %ss to %s = %.3g %s %.3gi',...
        lower(PZID),DomainVar,real(R(1)),char(177),abs(imag(R(1))));
case 'Notch'
    Z = Group.Zero(1); 
    P = Group.Pole(1);
    Status = sprintf('Moved notch zeros to %s = %.3g %s %.3gi and notch poles to %s = %.3g %s %.3gi',...
        DomainVar,real(Z),char(177),abs(imag(Z)),DomainVar,real(P),char(177),abs(imag(P)));
end