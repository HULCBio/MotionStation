function v = varpick(v1,v2,Ts)
%VARPICK   Resolves clashes between domain variables V1 and V2.
%          The preference rules are
%              Continuous:   p > s
%              Discrete  :   z^-1 > q > z

%       Author(s): A. Potvin, 3-1-94
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.8 $

if strcmp(v1,v2),  
   v = v1;  
elseif isequal(Ts,0),
   % Resulting system is continous-time
   if strcmp(v1,'p') | strcmp(v2,'p'),
      v = 'p';
   else
      v = 's';
   end
else
   % Resulting system is discrete-time
   if strcmp(v1,'z^-1') | strcmp(v2,'z^-1'),
      v = 'z^-1';
   elseif strcmp(v1,'q') | strcmp(v2,'q'),
      v = 'q';
   else
      v = 'z';
   end
end

% end ../@tf/private/varpick.m
