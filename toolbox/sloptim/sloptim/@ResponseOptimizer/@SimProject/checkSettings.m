function [hasTunedPar,hasObj,hasConstr] = checkSettings(this)
% Checks project settings

%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:07 $
%   Copyright 1986-2004 The MathWorks, Inc.
hasTunedPar = ~(isempty(this.Parameters) || ...
   isempty(find(this.Parameters,'-function','Tuned',@(x) any(x(:)))));

hasObj = false;
hasConstr = false;
Model = this.Model;
if ~isempty(this.Tests)
   Tests = find(this.Tests,'Enable','on','Optimized','on');
   for ct=1:length(Tests)
      t = Tests(ct);
      for cts=1:length(t.Specs)
         s = t.Specs(cts);
         % Update enable flag based on current settings
         if isActive(s.SignalSource,Model)
             s.Enable = 'on';
         else
             s.Enable = 'off';
         end
         % Update booleans
         hasObj = hasObj || hasCost(s);
         hasConstr = hasConstr || hasConstraint(s);
      end
   end
end
