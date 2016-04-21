function bfitreinitbfitdata(datahandle)
%BFITREINITBFITDATA is a utility function for the Basic Fitting GUI
%   BFITREINITBFITDATA is used to re initialize Basic Fit appdata.
%   See bfitsetup for more information.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/02/25 07:53:42 $

emptycell = cell(12,1);
infarray = repmat(inf,1,12);
fitsShowing = false(1,12);
 
setappdata(datahandle,'Basic_Fit_Coeff', emptycell); % cell array of pp structures
setappdata(datahandle,'Basic_Fit_Resids', emptycell); % cell array of residual arrays
setappdata(datahandle,'Basic_Fit_Handles', infarray); % array of handles of fits
setappdata(datahandle,'Basic_Fit_Showing', fitsShowing); % array of logicals: 1 if showing
setappdata(datahandle,'Basic_Fit_NumResults_',[]);
data.x = [];
data.y = [];
setappdata(datahandle,'Basic_Fit_Data',data); % if sorted or normalized, store here
setappdata(datahandle,'Basic_Fit_EqnTxt_Handle', []);  
setappdata(datahandle,'Basic_Fit_ResidTxt_Handle', []); % norm of residuals txt
setappdata(datahandle,'Basic_Fit_Resid_Handles', infarray); % array of handles of residual plots
evalresults.string = '';
evalresults.x = []; % x values
evalresults.y = []; % f(x) values
evalresults.handle = [];
setappdata(datahandle,'Basic_Fit_EvalResults',evalresults);
setappdata(datahandle,'Basic_Fit_Normalizers', []);

% don't need to turn off listeners while sorting data because they are not 
% called recursively.
xdata = get(datahandle,'xdata');
ydata = get(datahandle,'ydata');
[xdata,xind] = sort(xdata);
ydata = ydata(xind);
set(datahandle,'xdata',xdata);
set(datahandle,'ydata',ydata);


