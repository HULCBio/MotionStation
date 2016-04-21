function mode = rtwenvironmentmode(mdl)
%   Return the appropriate mode for RTW passthrough control.
%
%   true:  Simulation target
%   false: RTW target

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2003/11/19 21:46:32 $

cs = getActiveConfigSet(mdl);

switch get_param(mdl, 'TargetStyle')
    case 'StandAloneTarget'
        % RTW (true RTW targets return false)
        if strcmp(get_param(cs,'IsPILTarget'),'on')
            mode = true;
        else
            mode = false;
        end
    otherwise
        % Simulation (true Simulation targets return true)
        if strcmp(get(cs,'SimulationMode'),'external')
            mode = false;
        else
            mode = true;
        end
end