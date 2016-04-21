function [strings, err, pp, resid] = bfitcalcfit(datahandle,fit)
% BFITCALCFIT  Calculate coefficients and residuals of FIT to data DATAHANDLE.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.21.4.3 $  $Date: 2004/04/29 03:39:46 $

strings = ' ';
err = 0;

if fit < 0 % select fit is cleared
    setappdata(datahandle,'Basic_Fit_NumResults_',[]);
    return
end

% get data
guistate = getappdata(datahandle,'Basic_Fit_Gui_State');
xdata = get(datahandle,'xdata');
ydata = get(datahandle,'ydata');

% calculate fit
[pp, resid, err] = calcfit(xdata,ydata,fit,datahandle,guistate);
if err
    return;
end

value = getappdata(datahandle,'Basic_Fit_Coeff');
% we assume this is initialized in setup as cell array
value{fit + 1} = pp;
setappdata(datahandle,'Basic_Fit_Coeff', value);

value = getappdata(datahandle,'Basic_Fit_Resids');
% we assume this is initialized in setup as a cell array
value{fit + 1} = resid;
setappdata(datahandle,'Basic_Fit_Resids', value);

% save last fit calculated
setappdata(datahandle,'Basic_Fit_NumResults_',fit);

% get other needed strings
strings = bfitcreateeqnstrings(fit,pp,norm(resid));

% ----------------------------------------------
function [pp, resid, err, mu] = calcfit(xdata,ydata,fit,datahandle,guistate)
% CALCFIT calculates a fit.
%    [COEFF, NORMRESID, ERR, MU] = CALCFIT(X,Y,FIT) calculates a fit and returns 
%    coefficients in a form PPVAL or POLYVAL can understand, and 
%    the residuals.

err = 0; mu = [];
dlgh = [];
distincterrid = 'MATLAB:chckxy:RepeatedSites';
twodataerrid = 'MATLAB:chckxy:NotEnoughPts';
title = 'Basic Fitting';
if fit == 0 % spline
	if guistate.normalize
	    normalized = getappdata(datahandle,'Basic_Fit_Normalizers');
        newxdata  = (xdata - normalized(1))./(normalized(2));
	else
		newxdata = xdata;
	end
	try
        pp = spline(newxdata,ydata);
    catch
        pp = [];
        resid = [];
        err = 1;
        [lastmsg, lastid] = lasterr;
        if strcmp(lastid,distincterrid)
            errmsg = sprintf(['Repeated X values are not permitted when fitting\n' ...
                    'with a cubic interpolating spline.\n' ...
                    'Remove repeated values.']); 
            dlgh = bfitcascadeerr(errmsg,title);
        elseif strcmp(lastid,twodataerrid)
            errmsg = sprintf(['At least two data points are required when\n' ...
                    'fitting with a cubic interpolating spline.\n' ...
                    'Add more data points to fit with spline.']);
            dlgh = bfitcascadeerr(errmsg,title);
        else
            dlgh = bfitcascadeerr({lasterr},title);
        end
        setappdata(datahandle,'Basic_Fit_Dialogbox_Handle',dlgh);
        return;
    end
    y = ppval(pp,newxdata);     % this should be all zeros for spline
elseif fit == 1 % pchip
	if guistate.normalize
    	normalized = getappdata(datahandle,'Basic_Fit_Normalizers');
        newxdata  = (xdata - normalized(1))./(normalized(2));
	else
		newxdata = xdata;
	end
	try
		pp = pchip(newxdata,ydata);
    catch
        pp = [];
        resid = [];
        err = 1;
        [lastmsg, lastid] = lasterr;
        if strcmp(lastid,distincterrid)
            errmsg = sprintf(['Repeated X values are not permitted when fitting\n' ...
                    'with shape-preserving interpolants.\n' ...
                    'Remove repeated values.']);
            dlgh = bfitcascadeerr(errmsg,title);
        elseif strcmp(lastid,twodataerrid)
            errmsg = sprintf(['At least two data points are required when\n' ...
                    'fitting with shape-preserving interpolants.\n' ...
                    'Add more data points.']);
            dlgh = bfitcascadeerr(errmsg,title);
        else
            dlgh = bfitcascadeerr({lasterr},title);
        end
        setappdata(datahandle,'Basic_Fit_Dialogbox_Handle',dlgh);
        return;
    end
    y = ppval(pp,newxdata);     % this should be all zeros for pchip
else % polynomial
    order = fit-1;
    centerscalestr = sprintf( ...
            ['Polynomial is badly conditioned. Remove repeated data points\n' ...
                '         or try centering and scaling as described in HELP POLYFIT.']);
    repeatptsstr = ...
      sprintf('Polynomial is badly conditioned. Remove repeated data points');
    ws = warning('off', 'all'); 
    [warnmsg, lastid] = lastwarn; % save warning in case no new warning
    lastwarn('')
    if guistate.normalize
		% polyfit calculates normalizers, so we don't have to getappdata.
        [pp,tmp,normalizers] = polyfit(xdata,ydata,order);
    else
        pp = polyfit(xdata,ydata,order);
    end
    if ~isempty(lastwarn)
        waswarned = getappdata(datahandle,'Basic_Fit_Scaling_Warn');
        if  ~isempty(findstr(centerscalestr,lastwarn)) 
            % only give centering and scaling warning once per data set
            if isempty(waswarned)
                setappdata(datahandle,'Basic_Fit_Scaling_Warn',1);
                warnmsg = sprintf( ...
                    ['Polynomial is badly conditioned. Removing repeated data points, \n' ...
                        'or centering and scaling, may improve results.']);
                dlgh = warndlg(warnmsg,title);
             end
        elseif ~isempty(findstr(repeatptsstr,lastwarn)) 
            if isempty(waswarned)
                setappdata(datahandle,'Basic_Fit_Scaling_Warn',1);
                warnmsg = sprintf( ...
                    ['Polynomial is badly conditioned. \nRemoving repeated data points ' ...
                        'may improve results.']);
                dlgh = warndlg(warnmsg,title);
             end
        else % other warnings from polyfit
           dlgh = warndlg(lastwarn,title); 
        end
    end
    lastwarn(warnmsg, lastid); % set lastwarn to last warning
    warning(ws);
    setappdata(datahandle,'Basic_Fit_Dialogbox_Handle',dlgh);
	if guistate.normalize
		y = polyval(pp,xdata,[],normalizers);
	else
		y = polyval(pp,xdata);
	end
end

resid = ydata(:) - y(:);  % always column


