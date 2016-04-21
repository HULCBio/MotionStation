function this = variable(var,CreateFlag)
% Returns instance of @variable class

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:29:44 $
ni = nargin;
if ni==0
   error('Variable name must be specified.')
elseif isa(var,'char')
   var = strrep(deblank(var),' ','_');
   if var(end)=='_',
      % Protection against redefining private properties
      error('Last character of variable name cannot be an underscore.')
   end
   if ni==1
      % Delegate to variable manager
      this = findvar(hds.VariableManager,var);
   else
      % Special signature for Variable manager
      this = hds.variable;
      this.Name = var;
   end
elseif isa(var,'hds.variable')
   this = var;
else
   error('First argument must be a string or a hds.variable object.')
end
