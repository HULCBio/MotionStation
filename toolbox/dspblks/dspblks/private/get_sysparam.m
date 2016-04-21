function v = get_sysparam(sys, p)
% GET_SYSPARAM Get a system-level parameter.
%  This function is error-protected against calls on
%  subsystems or blocks, which do not have system-level
%  parameter.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/14 20:52:24 $

if strmatch(lower(p), ...
      lower(fieldnames(get_param(sys,'objectparameters'))), 'exact'),
   % Simulink does not do param-completion, so we use 'exact' above
   
   % Object has parameter - get the corresponding value:
   v = get_param(sys,p);
else
   % No system parameter - check parent:
   parent = get_param(sys,'Parent');
   if ~isempty(parent),
      % recurse
      v = get_sysparam(get_param(sys,'parent'),p);
   else
      % param not found
      error(['No parent block diagram has a parameter named ''' p '''.']);
   end
end
