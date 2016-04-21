function Proj = getsro(Model,SpecFlag)
%GETSRO  Take snapshot of current response optimization project.
%
%   PROJ = GETSRO(MODELNAME) returns the Response Optimization 
%   project PROJ currently associated with the Simulink model 
%   with name MODELNAME.  The model should be opened and contain
%   Response Optimization blocks.
%
%   Type HELP SROPROJECT for more information on how to customize and
%   run a Response Optimization project.
%
%   Example: Open the pidtune_demo model:
%      pidtune_demo
%   Extract the response optimization project from this model
%      proj = getsro('pidtune_demo')
%
%   See also RESPONSEOPTIMIZER/FINDCONSTR, RESPONSEOPTIMIZER/FINDPAR,
%   NEWSRO, RESPONSEOPTIMIZER/OPTIMIZE, SROPROJECT.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.5 $ $Date: 2004/04/19 01:33:48 $
%   Copyright 1990-2004 The MathWorks, Inc.

if isempty(find(get_param(0,'Object'),'Name',Model))
   error('The Simulink model %s must be opened prior to calling GETSRO.',Model)
end

% Find @SimProjectForm (literal project specification) associated with
% model 
SROBlocks = find_system(Model,'FollowLinks','on','LookUnderMasks','all',...
   'RegExp','on','BlockType','SubSystem','LogID','SRO_DataLog_\d');
if isempty(SROBlocks)
   error('Simulink model %s does not contain any Response Optimization blocks.',Model)
else
   [Proj,errmsg] = utFindProject(Model,SROBlocks{1});
   warning(errmsg)
end
   
if nargin==1
   % Evaluate spec and return @SimProject
   Proj = evalForm(Proj);
end
