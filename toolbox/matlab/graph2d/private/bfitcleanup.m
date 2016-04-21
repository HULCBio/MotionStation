function bfitcleanup(fighandle, numberpanes)
% BFITCLEANUP clean up anything needed for the Basic Fitting GUI.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 04:06:01 $

if ishandle(fighandle) % if figure still open or in the process of being deleted
    datahandle = getappdata(fighandle,'Basic_Fit_Current_Data');
    if ~isempty(datahandle)
        guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
        guistate.panes = numberpanes;
        setappdata(datahandle,'Basic_Fit_Gui_State', guistate);
    end
    set(handle(fighandle), 'Basic_Fit_GUI_Object', []);
	if ~isempty(findprop(handle(fighandle),'Data_Stats_GUI_Object'))
		bfitguiobj = get(handle(fighandle), 'Data_Stats_GUI_Object');
	else
		bfitguiobj = [];
	end
    if isempty(bfitguiobj) % both gui's gone, reset double buffer state
        set(fighandle,'doublebuffer',getappdata(fighandle,'bfit_doublebuffer'));    
        rmappdata(fighandle,'bfit_doublebuffer'); % remove it so we set doublebuffer on if reopen gui
    end
% reset normalized?
end

