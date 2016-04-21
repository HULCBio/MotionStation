function utAssignParams(Model,s)
% Assigns model parameter values in appropriate workspace.
% 
%   S is a structure with fields Name, Value, and Workspace.

%   $Revision: 1.1.6.2 $ $Date: 2004/03/24 21:13:09 $
%   Copyright 1986-2004 The MathWorks, Inc.
inBase = strncmp({s.Workspace},'b',1);

% Assign parameters defined in base workspace
idxB = find(inBase);
for ct=1:length(idxB)
   idx = idxB(ct);
   [var,subs] = strtok(s(idx).Name,'.({');
   if isempty(subs)
      % Parameter is a variable
      assignin('base',var,s(idx).Value)
   else
      % Parameter is an expression
      tmp = evalin('base',var);
      rhs = s(idx).Value;
      try
         eval(['tmp' subs '= rhs;'])
      catch
         error('Expression "%s" is not a tunable parameter.',s(idx).Name)
      end
      assignin('base',var,tmp)
   end
end

% Assign parameters defined in model workspace
idxM = find(~inBase);
if ~isempty(idxM)
   mws = get_param(Model,'ModelWorkspace');
   if ~strcmp(mws.DataSource,'MDL-File')
      error('Parameters in model workspace cannot be modified (data source is read-only).')
   end
   for ct=1:length(idxM)
      idx = idxM(ct);
      [var,subs] = strtok(s(idx).Name,'.({');
      if isempty(subs)
         % Parameter is a variable
         mws.assignin(var,s(idx).Value)
      else
         tmp = mws.evalin('base',var);
         rhs = s(idx).Value;
         try
            eval(['tmp' subs '= rhs;'])
         catch
            error('Expression "%s" is not a tunable parameter.',s(idx).Name)
         end
         mws.assignin(var,tmp)
      end
   end
end