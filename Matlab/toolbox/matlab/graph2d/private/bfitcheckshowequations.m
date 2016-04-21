function bfitcheckshowequations(showeqnon, datahandle, digits)
%BFITCHECKSHOWEQUATIONS Shows the equations for the fits 
%   BFITCHECKSHOWEQUATIONS(SHOW,DATAHANDLE,DIGITS) shows or removes the 
%   equations according to SHOW, with DIGITS giving the number of digits to show.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 04:06:57 $

axesH = get(datahandle,'parent'); % need this in case subplots in figure
figH = get(axesH,'parent');

bfitlistenoff(figH)

fitsshowing = find(getappdata(datahandle,'Basic_Fit_Showing'));

eqnTxtH = getappdata(datahandle,'Basic_Fit_EqnTxt_Handle');
if ishandle(eqnTxtH)
    figure(figH)
    delete(eqnTxtH);
end

if showeqnon
    eqnTxtH = bfitcreateeqntxt(digits,axesH,datahandle,fitsshowing);
    if ~isempty(eqnTxtH)
        appdata.type = 'eqntxt';
        appdata.index = [];
        setappdata(eqnTxtH,'bfit',appdata);
		p = schema.prop(handle(eqnTxtH), 'Basic_Fit_Copy_Flag', 'MATLAB array');
		p.AccessFlags.Copy = 'off';
    end
else % delete
    eqnTxtH = [];
end
setappdata(datahandle,'Basic_Fit_EqnTxt_Handle',eqnTxtH);
guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
guistate.equations = showeqnon;
guistate.digits = digits;
setappdata(datahandle,'Basic_Fit_Gui_State', guistate);

bfitlistenon(figH)
