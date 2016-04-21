function success = configset_delete(cfgSets, reallyDelete)
% Delete a configuration set from a model
% or check to see if configuration set can be deleted

% Copyright 2003 The MathWorks, Inc.

success = true;

try
i=1;
while (i<=length(cfgSets) & success)
    configSet = cfgSets(i);
    model = configSet.up;
    activeConfigSet = model.getActiveConfigSet;
    
    % Don't allow deletion of the active config set
    if isequal(configSet,activeConfigSet)
        success = false;
    end

    if (success & reallyDelete)
        h = model.detachConfigSet(configSet.Name);
	success = ~isempty(h);
	if (success)
            delete(configSet);
        end
    end

    i=i+1;
end


catch
    % error okay, just return "not deleteable"
    success = false;
end

