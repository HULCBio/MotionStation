function Proj = newsro(Model,Params)
%NEWSRO  Create default response optimization project for Simulink model.
%
%   PROJ = NEWSRO(MODELNAME,PARAMETERS) creates a new optimization
%   project PROJ for the Simulink model with name MODELNAME.  The
%   tuned parameters are specified by the cell array of strings
%   PARAMETERS.  The specified model should contain at least one
%   block from the Simulink Response Optimization library (see SROLIB).
%
%   Type HELP SROPROJECT for more information on how to customize and
%   run a Response Optimization project.
%
%   Example
%      p = newsro('srodemo1',{'P' 'I' 'D'})
%
%   See also RESPONSEOPTIMIZER/FINDCONSTR, RESPONSEOPTIMIZER/FINDPAR,
%   GETSRO, RESPONSEOPTIMIZER/OPTIMIZE, SROPROJECT.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.6 $ $Date: 2004/04/19 01:33:50 $
%   Copyright 1990-2004 The MathWorks, Inc.

error(nargchk(2,2,nargin))

% Is the model open?
LoadFlag = isempty(find(get_param(0,'Object'),'Name',Model));
if LoadFlag
   try
      load_system(Model)
   catch
      rethrow(lasterror)
   end
end

% Look for SRO blocks
SROBlocks = find_system(Model,'FollowLinks','on','LookUnderMasks','all',...
      'RegExp','on','BlockType','SubSystem','LogID','SRO_DataLog_\d');
if isempty(SROBlocks)
   error('Simulink model %s does not contain any Response Optimization blocks.',Model)
end

% Creates project specification for Simulink model
ProjForm = srogui.SimProjectForm;
ProjForm.Name = Model;

% Initialize project with one constraint per block in MODEL
ProjForm.init(Model)

% Get list of all model parameters
AllVars = getTunableParams(ProjForm);
AllVars = {AllVars.Name};

% Check parameters against list of tunable model parameters
if ischar(Params)
   Params = {Params};
elseif ~iscellstr(Params)
   error('Second input must be a cell array of tuned parameter names.')
end
isValid = ismember(strtok(Params,'.({'),AllVars);
idxNotValid = find(~isValid);
if ~isempty(idxNotValid)
   error('There is no model parameter with name %s.',Params{idxNotValid(1)})
end

% Create parameter specs and initialize parameters
ParForms = [];
for ct=1:numel(Params)
   ps = srogui.ParameterForm(Params{ct});
   ParForms = [ParForms ; ps];
end
ProjForm.Parameters = ParForms;

% Evaluate project specification
try
   Proj = evalForm(ProjForm);
catch
   rethrow(lasterror)
end

% Clean up
if LoadFlag
   close_system(Model,0)
end

