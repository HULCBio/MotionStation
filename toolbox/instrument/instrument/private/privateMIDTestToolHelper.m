function varargout = privateMIDTestToolHelper(action, varargin)
%PRIVATEMIDTESTTOOLHELPER helper function used by MIDTESTTOOL.
%
%   PRIVATEMIDTESTTOOLHELPER helper function used by MIDTESTTOOL to:
%      1. Execute test code
%      2. Export test results to MATLAB.
%   
%   This function should not be called directly be the user.
%  
%   See also MIDTESTTOOL.
%
 
%   MP 7-10-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/03/05 18:10:30 $

switch (action)
case 'evaluate'
    code = varargin{1};
    eval(code);
    eval('setappdata(0, ''MIDTestToolResults'', varargout);');
case 'help'  
    doc('instrument');
case 'cleanup'
    if (isappdata(0, 'MIDTestToolResults'))
        rmappdata(0, 'MIDTestToolResults');
    end
case 'createObject'
    constructor   = varargin{1};
    properties    = varargin{2};
    instrfindArgs = varargin{3};
    
    % Determine if object has already been created. If so, use it.
    obj = eval(['instrfind' instrfindArgs]);
    if ~isempty(obj)
        fclose(obj);
        interface = obj(1);
    else
        obj = eval(constructor);
    end    
    
    % Configure the object.
    eval(['set(obj, ' properties ')'])
case 'figure'
    % Parse the input.
    info = varargin{1};
    
    % If there is no data return.
    if info.size <= 1
        return;
    end

    % Extract the data.
    allData = getappdata(0, 'MIDTestToolResults');
    
    % Initialize variables.
    variableNames = {};
    count = 1;
        
    % Assign values that will be plotted.
    for i=0:2:info.size-1;
        varName   = char(info.elementAt(i));
        dataIndex = info.elementAt(i+1) + 1;
        data      = allData{dataIndex};
        variableNames{count} = varName;
        eval([variableNames{count} ' = data;']);
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
    info = varargin{1};
    
    % If there is no data return.
    if info.size <= 1
        return;
    end

    % Extract the data.
    allData = getappdata(0, 'MIDTestToolResults');
        
    % Export data to workspace.
    for i=0:2:info.size-1;
        varName   = char(info.elementAt(i));
        dataIndex = info.elementAt(i+1) + 1;
        data      = allData{dataIndex};
        assignin('base', varName, data);
    end
case 'mat-file'
    % Parse the input.
    filename = varargin{1};
    info     = varargin{2};
    
    % If there is no data return.
    if info.size <= 1
        return;
    end

    % Extract the data.
    allData = getappdata(0, 'MIDTestToolResults');
    
    % Initialize variables.
    variableNames = {};
    count = 1;
    
    % Loop through and assign each object to the user-specified variable name.   
    for i=0:2:info.size-1;
        varName   = char(info.elementAt(i));
        dataIndex = info.elementAt(i+1) + 1;
        data      = allData{dataIndex};
        variableNames{count} = varName;
        eval([variableNames{count} ' = data;']);
        count = count+1;
    end   

    % Save the variables to the MAT-file.
    save(filename, variableNames{:});

case 'arrayeditor'
    % Parse the input.
    info = varargin{1};
    
    % If there is no data return.
    if info.size <= 1
        return;
    end

    % Extract the data.
    allData = getappdata(0, 'MIDTestToolResults');
        
    % Export data to workspace.
    for i=0:2:info.size-1;
        varName   = char(info.elementAt(i));
        dataIndex = info.elementAt(i+1) + 1;
        data      = allData{dataIndex};
        assignin('base', varName, data);
        openvar(varName);
    end
end
