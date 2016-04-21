function runSimulation(this)

% Copyright 2003 The MathWorks, Inc.

% Runs the current simulation scenario

% "this" is the MPCSims node

if length(char(this.CurrentScenario)) <= 0
    % If empty, scenario not ready to run
    msgbox('No simulation scenarios defined yet.',...
        'MPC message');
    return
end
Scenario = this.getChildren.find('Label', this.CurrentScenario);
if isempty(Scenario)
    error(sprintf('Could not find scenario "%s".', this.CurrentScenario));
else
    Scenario.runSimulation;
end