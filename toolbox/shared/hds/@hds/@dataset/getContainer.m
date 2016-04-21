function C = getContainer(this,Variable)
%SETCONTAINER  Accesses data container for a given variable or link.
%
%   The data container must be a subclass of @ValueArray.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:23 $
[V,idx] = findvar(this,Variable);
if ~isempty(idx)
   C = this.Data_(idx);
else
   [L,idx] = findlink(this,Variable);
   if isempty(idx) 
      if ~isa(Variable,'char')
         Variable = Variable.Name;
      end
      error(sprintf('Unknown variable %s',Variable))
   else
      C = this.Children_(idx);
   end
end