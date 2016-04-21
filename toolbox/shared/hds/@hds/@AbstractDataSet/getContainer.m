function C = getContainer(this,Variable)
%GETCONTAINER  Accesses data container for a given variable or link.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:02 $
if isa(Variable,'char')
   Variable = findvar(hds.VariableManager,Variable);
end
C = find(this.Data_,'Variable',Variable);
if isempty(C)
   C = find(this.Children_,'Alias',Variable);
end
if isempty(C)
   error(sprintf('Unknown variable %s',Variable.Name))
end
