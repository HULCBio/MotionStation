function var2parG(this,xL,xR)
% Sets values of L/R parameters in the gradient model
% using the current values xL,xR of the decision vector.
% Note: Assumes that the workspace variable values match
%       the project parameter values.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:38 $
p = this.Project.Parameters;
pNames = get(p,{'Name'});
GMVars = this.Gradient.Variables;  % gradient model parameters
GMVarNames = {GMVars.Name};

% Initialize value of GM parameters involved in composite 
% tuned parameters such as controller.P
idxComp = find(~ismember(GMVarNames,pNames));
if ~isempty(idxComp)
   % Model workspace
   ModelWS = get_param(this.Project.Model,'ModelWorkspace');
   s = whos(ModelWS);
   ModelWSVars = {s.name};
   % Evaluate variable
   for ct=1:length(idxComp)
      idx = idxComp(ct);
      v = utEvalModelVar(GMVars(idx).Name,ModelWS,ModelWSVars);
      GMVars(idx).LValue = v;
      GMVars(idx).RValue = v;
   end
end

% Mapping tuned parameters -> GM parameters
[vNames,vSubs] = strtok(pNames,'.({');
[junk,idxLoc] = ismember(vNames,GMVarNames);

% Map XL and XR values to GMVars.LValue and GMVars.RValue
offset = 0;
for ct=1:length(p)
   pct = p(ct);
   % Determine left and right values of associated tuned parameter
   pLct = pct.Value;
   pRct = pct.Value;
   % Find tuned parameters
   idxt = find(pct.Tuned);
   len = length(idxt);
   if len>0
      pLct(idxt) = xL(offset+1:offset+len);
      pRct(idxt) = xR(offset+1:offset+len);
      offset = offset + len;
   end
   % Assign to GMVars structure
   idx = idxLoc(ct);
   if isempty(vSubs{ct})
      GMVars(idx).LValue = pLct;
      GMVars(idx).RValue = pRct;
   else
      % Composite parameter like controller.P
      tmp = GMVars(idx).LValue;
      eval(['tmp' vSubs{ct} '= pLct;']);
      GMVars(idx).LValue = tmp;
      tmp = GMVars(idx).RValue;
      eval(['tmp' vSubs{ct} '= pRct;']);
      GMVars(idx).RValue = tmp;
   end
end

% Assign modified variables to gradient model
this.Gradient.Variables = GMVars;

