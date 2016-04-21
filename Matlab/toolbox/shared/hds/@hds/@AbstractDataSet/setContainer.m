function setContainer(this,Variable,ValueArrayContainer)
%SETCONTAINER  Specifies data container for a given variable or link.
%
%   The data container must be a subclass of @ValueArray.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:16 $
[V,idx] = findvar(this,Variable);
if ~isempty(idx)
   if ~isa(ValueArrayContainer,'hds.ValueArray')
      error('Specified container must be a subclass of hds.ValueArray.')
   end
   ValueArrayContainer.Variable = V;
   % REVISIT: 3->1
   % this.Data_(idx) = ValueArrayContainer;
   d = this.Data_;
   d(idx) = ValueArrayContainer;
   this.Data_ = d;
else
   [L,idx] = findlink(this,Variable);
   if isempty(L) 
      if ~isa(Variable,'char')
         Variable = Variable.Name;
      end
      error(sprintf('Unknown variable %s',Variable))
   else
      if ~isa(ValueArrayContainer,'hds.LinkArray')
         error('Specified container must be a subclass of hds.ValueArray.')
      end
      % REVISIT: 3->1
      c = this.Children_;
      c(idx) = ValueArrayContainer;
      this.Children_ = c;
   end
end
