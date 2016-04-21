function bfitdatastatcleanup(fighandle)
% BFITDATASTATCLEANUP clean up anything needed for the Data Statistics GUI.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 04:06:07 $

if ishandle(fighandle) % if figure still open or in the process of being deleted
    set(handle(fighandle), 'Data_Stats_GUI_Object',[]);
	if ~isempty(findprop(handle(fighandle),'Basic_Fit_GUI_Object'))
		bfitguiobj = get(handle(fighandle), 'Basic_Fit_GUI_Object');
	else
		bfitguiobj = [];
	end
	if isempty(bfitguiobj) % both gui's gone, reset double buffer state
        set(fighandle,'doublebuffer',getappdata(fighandle,'bfit_doublebuffer'));    
        rmappdata(fighandle,'bfit_doublebuffer'); % remove it so we set doublebuffer on if reopen gui
    end
end
% reset normalized?

