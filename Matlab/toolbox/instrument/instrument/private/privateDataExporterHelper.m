function out = privateDataExporterHelper(action, obj, varargin)
%PRIVATEDATAEXPORTERHELPER helper function used by INSTRCOMM and TMTOOL.
%
%   PRIVATEDATAEXPORTERHELPER helper function used by INSTRCOMM and
%   TMTOOL to export data to:
%      1. the MATLAB workspace
%      2. MATLAB figure window
%      3. MAT-file
%      4. MATLAB array editor.
%   
%   This function should not be called directly be the user.
%  
%   See also INSTRCOMM, TMTOOL.
%
 
%   MP 9-08-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:02:33 $

% Initialize output.
out = '';

switch action
case 'figure'
    % Parse the input.
    selectedVariables = obj;
    variables = varargin{1};

    % If there is no data return.
    if isempty(selectedVariables)
        return;
    end
   
    % Initialize variables.
    variableNames = {};
    count = 1;
    
    % Loop through and assign each object to the user-specified variable name.
    for i=0:2:selectedVariables.size-1
        varName = char(selectedVariables.elementAt(i));
        lookupName = char(selectedVariables.elementAt(i+1));
        variableNames{count} = varName;
        eval([variableNames{count} ' = variables.get(lookupName);'])
        count = count+1;
    end

    % Get the default colors and plot each variable.
    colorOrder = get(gca, 'ColorOrder');    
    for i=1:length(variableNames)
        plot(eval(variableNames{i}), 'Color', colorOrder(rem(i, length(colorOrder))+1,:));
        hold on;
    end
    
    % Create a legend.
    legend(variableNames{:});
    hold off;
case 'workspace'
    % Parse the input.
    selectedVariables = obj;
    variables = varargin{1};

    % If there is no data return.
    if isempty(selectedVariables)
        return;
    end
    
    % Export data to workspace.
    for i=0:2:selectedVariables.size-1;
        varName = char(selectedVariables.elementAt(i));
        lookupName = char(selectedVariables.elementAt(i+1));
        data = variables.get(lookupName);
        assignin('base', varName, data);
    end
case 'mat-file'
    % Parse the input.
    filename = obj;
    selectedVariables = varargin{1};
    variables = varargin{2};
    
    % If there is no data return.
    if isempty(selectedVariables)
        return;
    end
    
    % Initialize variables.
    variableNames = {};
    count = 1;
    
    % Loop through and assign each object to the user-specified variable name.
    for i=0:2:selectedVariables.size-1
        varName = char(selectedVariables.elementAt(i));
        lookupName = char(selectedVariables.elementAt(i+1));
        variableNames{count} = varName;
        eval([variableNames{count} ' = variables.get(lookupName);'])
        count = count+1;
    end

    % Save the variables to the MAT-file.
    save(filename, variableNames{:});

case 'arrayeditor'
    % Parse the input.
    selectedVariables = obj;
    variables = varargin{1};

    for i=0:2:selectedVariables.size-1;
        lookupName = char(selectedVariables.elementAt(i+1));
        varName = char(selectedVariables.elementAt(i));
        data = variables.get(lookupName);
        assignin('base', varName, data);
        openvar(varName);
    end
end
