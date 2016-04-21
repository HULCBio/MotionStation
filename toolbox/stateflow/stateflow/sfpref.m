function result = sfpref(prefName,prefVal)
%SFPREF Manages persistent user preferences for Stateflow.
%       SFPREF by itself displays the set of current user preferences.
%       SFPREF('PREFNAME') gets the current value of PREFNAME
%       SFPREF('PREFNAME',PREFVALUE) sets the current value of PREFNAME

%
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/15 01:01:43 $

availablePrefs = {'hideSymbolWizardAlert','ignoreUnsafeTransitionActions'};
defaultValues = {0,0};


if(nargin==0)
    currentPrefs = [];
    for i=1:length(availablePrefs)
        if(ispref('Stateflow',availablePrefs{i}))
            val = getpref('Stateflow',availablePrefs{i});
        else
            val = defaultValues{i};
        end
        currentPrefs = setfield(currentPrefs, availablePrefs{i},val);
    end
    result = currentPrefs;
else
    found = 0;
    for i=1:length(availablePrefs)
        if(strcmp(lower(availablePrefs{i}),lower(prefName)))
            found = 1;
            break;
        end
    end
    if(~found)
        error(sprintf('Unknown preference string ''%s'' passed to sfpref',prefName));
    end
    if(nargin==2)
        if(~isequal(class(prefVal),class(defaultValues{i})))
            error(sprintf('Preference ''%s'' expects a value of class ''%s''',availablePrefs{i},class(defaultValues{i})));
        end
        setpref('Stateflow',availablePrefs{i},prefVal);
    end
    if(ispref('Stateflow',availablePrefs{i}))
        result = getpref('Stateflow',availablePrefs{i});
    else
        result = defaultValues{i};
    end
end