function varargout = slDDGUtil(source, action, varargin)
% Utility function for Simulink block dialog source objects (subclasses of 
% SLDialogSource). 
% The following signatures are assumed for each action:
% sync:
%   slDialogUtil(source, action, activedlg, widgetType, paramName, paramValue)
% getParamIndex:
%   index = slDialogUtil(source, action, paramName)

% Copyright 2003 The MathWorks, Inc.

switch action
    case 'sync'             % sync any open dialogs
        activeDlg  = varargin{1};
        widgetType = varargin{2}; 
        paramName  = varargin{3};
        paramValue = varargin{4};
        syncDialogs(source, activeDlg, widgetType, paramName, paramValue);
        
    otherwise
     warning('DDG:slDDGUtil','Unknown action');
end


% sync any open dialogs that containts the same properties ---------------------
function syncDialogs(source, activeDlg, widgetType, paramName, paramValue)

r=DAStudio.ToolRoot;
d=r.getOpenDialogs;

for i=1:length(d)
  if isequal(source.getBlock, d(i).getDialogSource.getBlock)
    d(i).setWidgetValue(paramName, paramValue);
    d(i).refresh;
  end
end 
