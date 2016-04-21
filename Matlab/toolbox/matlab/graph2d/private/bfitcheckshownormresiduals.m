function bfitcheckshownormresiduals(checkon,datahandle)
% BFITCHECKSHOWNORMRESIDUALS Show norm of residuals as text on figure.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/15 04:06:59 $

residinfo = getappdata(datahandle,'Basic_Fit_Resid_Info');
residfigure = findobj(0,'Basic_Fit_Fig_Tag',residinfo.figuretag);
fitsshowing = find(getappdata(datahandle,'Basic_Fit_Showing'));

residnrmTxtH = getappdata(datahandle,'Basic_Fit_ResidTxt_Handle');

if checkon
    residnrmTxtH = bfitcreatenormresidtxt(residinfo.axes,residfigure,datahandle,fitsshowing);
    if ~isempty(residnrmTxtH)
        appdata.type = 'residnrmtxt';
        appdata.index = [];
        setappdata(residnrmTxtH,'bfit',appdata);
		p = schema.prop(handle(residnrmTxtH), 'Basic_Fit_Copy_Flag', 'MATLAB array');
		p.AccessFlags.Copy = 'off';
	end	   
else % delete
    if ~isempty(residinfo.axes) % The axes could have been deleted already
        delete(residnrmTxtH)
    end
    residnrmTxtH = [];
end
setappdata(datahandle,'Basic_Fit_ResidTxt_Handle', residnrmTxtH); % norm of residuals txt

guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
guistate.showresid = checkon;
setappdata(datahandle,'Basic_Fit_Gui_State', guistate);

