function fcnHandles = exportccsplugin
%EXPORTCCSPLUGIN Return function handles to insert and delete functions.

%   Author(s): J. Schickler, R. Losada
%   Copyright 2000-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:31:38 $ 

fcnHandles.fdatool = @insertplugin;

%-------------------------------------------------------------------
function insertplugin(hFDA)
% Makes the necessary changes to FDATool to enable the launch of the 
% plugin.  This function should communicate with FDATool ONLY through
% APIs provided FDATool.
%
% This function is REQUIRED by FDATool's plugin API infrastructure.

% Use SIGGUI_CBS' method callback to execute the lcl function.
cbs = siggui_cbs(hFDA);
cb  = {cbs.method, hFDA, @export2ccs}; % Define the callback

% Add a menu item under the "Targets" menu to export to Code Composer Studio (tm) IDE
hm = addtargetmenu(hFDA,'Code Composer Studio (r) IDE ...',...
    cb,'export2ccs');
setappdata(hFDA, 'xportccsmenu', hm);
addlistener(hFDA, 'FilterUpdated', @filterlistener);


%-------------------------------------------------------------------
function export2ccs(hFDA)
% Callback for the Create Header File menu item

hEH = getcomponent(hFDA, 'tag', 'siggui.exportfilt2hw');

% If hEH is empty the Export2CHeaderFile component has not been installed.
if isempty(hEH),
        
    % Get the filter from FDATool
    G = getfilter(hFDA);
    
    % Instantiate the ExportFilt2HW dialog
    hEH = siggui.exportfilt2hw(G);
    addcomponent(hFDA, hEH);
    
    % Render the Export Header dialog
    render(hEH);
    hEH.centerdlgonfig(hFDA);
    
    % Add listeners to the Undo Manager if it exists
    hUndo = siggetappdata(hFDA.FigureHandle, 'siggui', 'UndoManager');
    if ~isempty(hUndo),
        
        % Create the Listeners
        listener(1) = handle.listener(hUndo, 'UndoPerformed', @filterlistener);
        listener(2) = handle.listener(hUndo, 'RedoPerformed', @filterlistener);
        
        % Change the callback target from the Undomanager to FDATool
        set(listener, 'CallbackTarget', hFDA);
        
        % Save the listener
        setappdata(hFDA, 'CreateExport2CHeaderFile', listener);
    end

    addlistener(hFDA, 'sigguiClosing', {@deleteplugin, hEH});
end

% Make the dialog visible and bring it to the front.
set(hEH, 'Visible', 'On');
figure(hEH.FigureHandle);

%-------------------------------------------------------------------
function deleteplugin(hFDA, eventData, hEH)
% Deletes any figures, including dialog boxes, that the plugin creates.
% This function does not need to delete any uicontrols created in 
% FDATool GUI.
%
% This function is REQUIRED by FDATool's plugin API infrastructure.

destroy(hEH);


%-------------------------------------------------------------------
function filterlistener(hFDA, eventData)
% Function is executed whenever the filter of FDATool is modified

filtobj = getfilter(hFDA);

hEH = getcomponent(hFDA, 'tag', 'siggui.exportfilt2hw');
if any(strcmp(class(filtobj), {'dfilt.cascade', 'dfilt.parallel'})),
    enabState = 'Off';
else
    enabState = get(hFDA, 'Enable');
    
    if ~isempty(hEH),
        % When there is a new filter, or the UndoManager has performed an action
        % Sync the filters of FDATool and ExportHeader
        hEH.Filter = getfilter(hFDA);
    end
end

hm = getappdata(hFDA, 'xportccsmenu');
set(hm, 'Enable', enabState);
set(hEH, 'Enable', enabState);

% [EOF]
