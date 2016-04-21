function setTunedParams(this,NewSpecs)
% Updates list of tuned parameters and bound/scaling specs for 
% these parameters.

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/01/03 12:27:50 $

% Get list of variable names in model workspace
ModelWS = get_param(this.Model,'ModelWorkspace');
s = whos(ModelWS);
ModelWSVars = {s.name};

% Validate new settings
for ct=1:length(NewSpecs)
   try
      evalForm(NewSpecs(ct),ModelWS,ModelWSVars);
   catch
      rethrow(lasterror)
   end
end

% Update project
this.Parameters = NewSpecs;
this.Dirty = true;

