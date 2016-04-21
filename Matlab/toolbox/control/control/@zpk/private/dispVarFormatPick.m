function [f,v] = dispVarFormatPick(v1,v2,f1,f2,Ts)
%VARPICK   Resolves clashes between domain variables V1 and V2 & display formats f1 anf f2
%          The preference rules are
%              Continuous:   p > s
%              Discrete  :   z^-1 > q > z
%          The preference rules for the display format are
%          t > f > r

%       Author(s): A. Potvin, 3-1-94
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.8 $ $Date: 2002/04/04 15:18:03 $

% First apply variables precidence
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

%now apply display format precidence


if strcmp(f1(1),f2(1)),  
   f = f1;  
else 
   ord = 'tfr';
   dispVec = {'time-constant','frequency','roots'};
   f = dispVec{min(findstr(f1(1),ord),findstr(f2(1),ord))};
end

% now check that the combination is legal (i.e., to 'tq' or 'fq')
if (strcmp(v,'z^-1') | strcmp(v,'q')) & (strcmp(f(1),'t') | strcmp(f(1),'f'))
    f = 'roots'; 
end

