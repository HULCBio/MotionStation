function [Group1,clash] = mrggroup(Group1,Group2)
%MRGGROUP  I/O group management.  
%
%   GROUP1 = MRGGROUP(GROUP1,GROUP2) merges the two
%   I/O groups GROUP1 and GROUP2.  If GROUP1 is empty,
%   it is replaced by GROUP2.  CLASH is set to true if 
%   some common groups clash (GROUP1 is then unchanged).

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:42 $
CellFlag = isCellGroup(Group1,Group2); 
G = getgroup(Group1);  % default choice
Group2 = getgroup(Group2);

% Determine if there is a clash
f1 = fieldnames(G);
f2 = fieldnames(Group2);
if isempty(f1)
   G = Group2;
elseif ~isempty(f2) && ~isequal(Group1,Group2)
   % Determine if some groups clash, merge otherwise
   for ct=1:length(f2)
      f = f2{ct};
      if ~isfield(G,f)
         G.(f) = Group2.(f);
      elseif ~isequal(G.(f),Group2.(f))
         clash = true;  return
      end
   end
end

% RE: Needed when Group1 and Group2 match, but Group1 is a cell 
%     and Group2 a struct
Group1 = setgroup(G,CellFlag);
clash = false;