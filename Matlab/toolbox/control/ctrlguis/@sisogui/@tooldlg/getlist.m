function List = getlist(h,key)
%GETLIST  Builds requested list.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:06:43 $

switch key
 case 'ActiveContainers'
  % List of visible containers with editable constraints
  List = find(h.ContainerList,'-depth',0,'Visible','on');
  hasConstr = logical([]);
  for ct = length(List):-1:1
    hasConstr(ct) = ~isempty(find(List(ct),'-isa','plotconstr.designconstr'));
  end
  List = List(hasConstr,:);
 case 'Constraints'
  % List of activate constraints in targeted container
  List = find(h.Container,'-depth', 1, ...
	      '-isa', 'plotconstr.designconstr', 'Activated', 1);
end
