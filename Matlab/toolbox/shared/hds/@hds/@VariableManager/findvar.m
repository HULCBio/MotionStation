function v = findvar(this,varname)
% Assigns handle to variable or finds handle for given variable.
% A unique handle is associated with each variable.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:29:09 $
if isfield(this.VarTable,varname)
   % Return variable handle if there is already a variable of this name
   v = this.VarTable.(varname);
else
   % Create new variable and store its handle in hash table
   v = hds.variable(varname,'create');
   this.VarTable.(varname) = v;
end
   
