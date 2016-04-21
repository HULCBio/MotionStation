function varargout = slDialogUtil(source, action, varargin)
% Utility function for Simulink block dialog source objects (subclasses of 
% SLDialogSource). 
% The following signatures are assumed for each action:
% sync:
%   slDialogUtil(source, action, activedlg, widgetType, paramName)
% getParamIndex:
%   index = slDialogUtil(source, action, paramName)

% Copyright 2003 The MathWorks, Inc.

switch action
    case 'sync'             % sync any open dialogs
        activeDlg  = varargin{1};
        widgetType = varargin{2}; 
        paramName  = varargin{3};
        syncDialogs(source, activeDlg, widgetType, paramName);
        
    case 'getParamIndex'    % get parameter index given object property
        paramName  = varargin{1};
        varargout{1} = getParamIndex(source, paramName);
                
    case 'refactor'         % refactor getDialogSchema structure
        % TODO (maybe): make a function to refactor a given dlgStruct
        % taking into account the known caveats for getDialogSchema
        
    otherwise
        warning('DDG:slDialogSource','Unknown action');
end

% get parameter index given object property -------------------------------
function index = getParamIndex(source, paramName)
index = 0;
if isprop(source, 'paramsMap')
    paramsMap = source.paramsMap;
else
    if strcmp(source.getBlock.Mask, 'on')
        paramsMap = source.getBlock.MaskNames;
    else
        paramsMap = fieldnames(source.state);
    end
end
for i = 1:length(paramsMap)
    if strcmp(paramsMap{i},paramName)
        break;
    end
    index = index+1;
end

% sync any open dialogs ---------------------------------------------------
function syncDialogs(source, activeDlg, widgetType, paramName)
value = activeDlg.getWidgetValue(paramName);
index = slDialogUtil(source, 'getParamIndex', paramName);
switch widgetType
    case 'edit'
        source.handleEditEvent(value, index, activeDlg);
    case 'checkbox'
        source.handleCheckEvent(value, index, activeDlg);
    case 'combobox'
        source.handleComboSelectionEvent(value, index, activeDlg);
    otherwise
        warning('DDG:slDialogSource','Unknown widget type');
end
