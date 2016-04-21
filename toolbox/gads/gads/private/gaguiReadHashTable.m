function [options, err] = gaguiReadHashTable(h)
% Transfers data from the java gui to a gaoptimset struct.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.2 $  $Date: 2004/03/18 17:59:30 $

% you will never call this yourself, only the GUI handling code will use
% it.

options = getappdata(0,'gads_gatool_options_data');
err = '';
try
    options = getProperty(h,options,'PopulationType',true);
    options = getProperty(h,options,'PopInitRange');
    options = getProperty(h,options,'PopulationSize');
    options = getProperty(h,options,'EliteCount');
    options = getProperty(h,options,'CrossoverFraction');

    % Migration--------------------------------------------

    options = getProperty(h,options,'MigrationDirection',true);
    options = getProperty(h,options,'MigrationInterval');
    options = getProperty(h,options,'MigrationFraction');

    % Stopping Criteria------------------------------------------

    options = getProperty(h,options,'Generations');
    options = getProperty(h,options,'TimeLimit');
    options = getProperty(h,options,'FitnessLimit');
    options = getProperty(h,options,'StallGenLimit');
    options = getProperty(h,options,'StallTimeLimit');

    % Initialization------------------------------------------

    options = getProperty(h,options,'InitialPopulation');
    options = getProperty(h,options,'InitialScores');
    options = getProperty(h,options,'PlotInterval');

    % Functions------------------------------------------

    options = getProperty(h,options,'FitnessScalingFcn');
    options = getProperty(h,options,'SelectionFcn');
    options = getProperty(h,options,'CrossoverFcn');
    options = getProperty(h,options,'MutationFcn');
    options = getProperty(h,options,'PlotFcns');
    options = getProperty(h,options,'OutputFcns');
    options = getProperty(h,options,'CreationFcn');
    options = getProperty(h,options,'HybridFcn');
    
    % Vectorized------------------------------------
    
    options = getProperty(h,options,'Vectorized',true);
    
    % Display------------------------------------------
    
    options = getProperty(h,options,'Display',true);
catch
    err = lasterr;
end

setappdata(0,'gads_gatool_options_data',options);

% getProperty-------------------------------------------
function options = getProperty(h,options,name,stringify)
if h.containsKey(name)
    v = h.get(name);
else
    return;
end

if(nargin < 4)
    stringify = false;
end
   
if(~stringify)
    try
        v = evalin('base', v);
    catch
        opt = getappdata(0,'gads_gatool_options_data');
        if ~isempty([strfind(v,'<userStructure>')  strfind(v,'<userClass>') strfind(v,'<userData>')])
            v = opt.(name);
        end
    end
end

options.(name) = v;


