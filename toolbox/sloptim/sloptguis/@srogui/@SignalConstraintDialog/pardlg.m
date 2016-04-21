function pardlg(this)
% Creates and manages parameter editor

% Author(s): P. Gahinet, Bora Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:44:27 $
Proj = this.Project;
Dlg = Proj.ParDialog;
if isempty(Dlg) || ~ishandle(Dlg)
   Dlg = srogui.ParameterDialog(Proj,this);
   Proj.ParDialog = Dlg;
end

% Sync up with project's parameter specs
% UDDREVISIT
if isempty(Proj.Parameters)
   Dlg.ParamSpecs = [];
else
   % Get current list of model parameters and references
   TunedVars = getTunedVarNames(Proj);
   try
      TunableVars = getTunableParams(Proj,'Reference');
   catch
      errordlg(utGetLastError,'Parameter Error','modal')
      return
   end
   % Locate tuned parameters in this list 
   % RE: Cannot use INTERSECT because cases like foo.x, foo.y give rise to
   % repeated names in TunedVars
   [isDefined,idxLoc] = ismember(TunedVars,{TunableVars.Name});
   % Guard against deleted parameters
   if any(~isDefined)
      warndlg('Some tuned parameters no longer exist in the model.','Parameter Warning','modal')
   end
   idxDef = find(isDefined);
   % Reevaluate parameters
   % Snap spec and update value/reference
   if isempty(idxDef)
      Dlg.ParamSpecs = [];
   else      
      Dlg.ParamSpecs = copy(Proj.Parameters(idxDef));
      pv = utEvalParams(Proj.Model,get(Dlg.ParamSpecs,{'Name'}));
      for ct=1:length(idxDef)
         Dlg.ParamSpecs(ct).ReferencedBy = TunableVars(idxLoc(idxDef(ct))).ReferencedBy;
         Dlg.ParamSpecs(ct).Value = mat2str(pv(ct).Value,4);
      end
   end
end
% Update list contents
updateList(Dlg)
% Make frame visible
Dlg.Figure.Visible = 'on';