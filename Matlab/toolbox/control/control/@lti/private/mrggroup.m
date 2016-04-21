function [Group1,clash] = mrggroup(Group1,Group2)
%MRGGROUP  I/O group management.  
%
%   [GROUP1,CLASH] = MRGGROUP(GROUP1,GROUP2)  merges the
%   two I/O groups GROUP1 and GROUP2.  CLASH is set to true 
%   if the two groups don't match.  If GROUP1 is empty,
%   it is replaced by GROUP2

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/01/07 19:32:26 $
CellFlag = isCellGroup(Group1,Group2); 
Group1 = getgroup(Group1);
Group2 = getgroup(Group2);

% Determine if there is a clash
f1 = fieldnames(Group1);
f2 = fieldnames(Group2);
clash = ~isempty(f1) && ~isempty(f2) && ~isequal(Group1,Group2) && ...
   ~isequal(orderfields(Group1),orderfields(Group2));

% Construct output
if isempty(f1)
   % Overwrite Group1 if empty
   Group1 = setgroup(Group2,CellFlag);
else
   % RE: Needed when Group1 and Group2 match, but Group1 is a cell 
   %     and Group2 a struct
   Group1 = setgroup(Group1,CellFlag);   
end

