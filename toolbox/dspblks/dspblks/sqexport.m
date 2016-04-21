function varargout = sqexport(varargin)
% SQEXPORT open export dialog for SQDTOOL

% Copyright 2002-2003 The MathWorks, Inc.

hMainFigParent = varargin{1};
ud = get(hMainFigParent, 'UserData');
data = {ud.finalCodebook(:) ud.finalPartition(:) ud.errorArray(:)};

hXP = getappdata(hMainFigParent,'sqExportDialog');

if isempty(hXP)
    % create export dialog
    hXP = sigio.export(data);
    set(hXP,'DefaultLabels',{'Final Codebook';'Final Boundary Points';'Mean Square Error'});
    set(hXP.Destination','VariableNames',{'finalCB';'finalBP';'Err'});       
    setappdata(hMainFigParent,'sqExportDialog',hXP);     
    
    % notification listener
    l =  handle.listener(hXP, 'Notification', {@lclnotification_listener,hMainFigParent});
    setappdata(hMainFigParent,'sqExportNotificationListener',l);   
   
    % cancel listener
    l =  handle.listener(hXP, 'DialogCancelled', {@lcldlgcancelled_listener,hMainFigParent});
    setappdata(hMainFigParent,'sqExportCancelledListener',l);
end

% Render the Export dialog (figure).
if ~isrendered(hXP),
    render(hXP);
    centerdlgonfig(hXP, hMainFigParent);
end

set(hXP, 'Visible', 'On');


%-------------------------------------------------------------------------
function lclnotification_listener(h, eventData,hMainFigParent)

notifyType = get(eventData,'NotificationType');
data = get(eventData,'Data');

switch notifyType
    case 'WarningOccurred'
        str = data.WarningString;
        sqdtool('updateWarningError',hMainFigParent,[],guidata(hMainFigParent),str);
    case 'ErrorOccurred'
        str = data.ErrorString;
        sqdtool('updateWarningError',hMainFigParent,[],guidata(hMainFigParent),str);
    case 'StatusChanged'
        str = data.StatusString;
        sqdtool('updateStatus',hMainFigParent,[],guidata(hMainFigParent),str);
    otherwise
end

%-------------------------------------------------------------------------
function lcldlgcancelled_listener(h, eventData,hMainFigParent)

str = 'Ready';
sqdtool('updateStatus',hMainFigParent,[],guidata(hMainFigParent),str);

