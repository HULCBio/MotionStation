function mode = passThroughSelector(model)
% PSELECTOR Used by the simpassthru_in block to switch code-gen paths
%
% Return the appropriate path to execute based on
%
% 	get_param(model,'TargetStyle') and
% 	get_param(model,'RTWSystemTargetFile')
%
% Parameters
%	model	-	The name of the model that is being built
%
% Return values:
%   0   -   Simulation Code Generation Required
%   1   -   Device Driver Code Generation Required
%
% Notes :
%   if get_param(model,'RTWSystemTargetFile') returns a value with
%   the string PIL in it anywhere then it is assumed that the
%   target is PIL and that Simulation Code should be generated

% $Revision: 1.1.6.2 $
% $Date: 2004/04/19 01:22:03 $
%
% Copyright 2002-2004 The MathWorks, Inc.

% Notes :
%   Return Values from get_param(model,'TargetStyle')
%       Auto: Block diagram is in an uncompiled state.
%       SimulationTarget: Normal simulation, Acceleartor
%       StandAloneTarget: Some form of RTW build
%
%

switch get_param(model, 'TargetStyle')
case 'StandAloneTarget'
    target = get_param(model,'RTWSystemTargetFile');
    if ~isempty(regexp(lower(target),'pil'))
        % PIL RT targets will be generated as if they
        % are Simulation Code
        mode = 0; 
    else
        mode = 1;
    end
otherwise
    % return simulation path branch
    mode = 0;
end
