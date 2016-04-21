function legends = bfitcreatelegend(axesH,remove,removedataH)
% BFITCREATELEGEND Create or update legend on figure for Data Stats 
%    and Basic Fitting GUIs.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.26.4.5 $  $Date: 2004/04/10 23:26:24 $


if nargin < 3
    % These are when we need to update the legend after a RemoveLine listener fires:
    %   the line is still in the HG hierarchy, so we have to take it out directly.
    remove = 0;
    removedataH = [];
end

legends = [];
fighandle = get(axesH,'parent');

datahandles = getappdata(fighandle,'Basic_Fit_Data_All');
axeshandles = getappdata(fighandle,'Basic_Fit_Axes_All');

% Remove data that is gone from the figure but still in the HG hierarchy.
% Leave axes list alone in case axes still there even though data deleted so
%  legend will be deleted.
if remove
    if ~isempty(removedataH)
        datahandles(removedataH==datahandles) = [];
    end
end

% For all potential data, get the parent axes and turn into an array
dataaxescell = get(datahandles,'parent');
if iscell(dataaxescell)
    dataaxes = [dataaxescell{:}];
else
    dataaxes = dataaxescell;
end

% For each unique axis handle, call legend on that axis with 
% all the data handles in that axis
if isempty(axeshandles)
    legends = createaxislegend(axesH,[]);
end
for i=1:length(axeshandles)
    if ~isempty(datahandles)
        axesdata = datahandles(dataaxes == axeshandles(i));
    else
        axesdata = [];
    end
    legendH = createaxislegend(axeshandles(i),axesdata);
    legends = [legends, legendH];
end

%-------------------------------------------------------------------------------------
function legendH = createaxislegend(axesH,datahandles)

allH = []; allM = [];

% get legend info
[legh,objh,oldhandles,oldstrings] = legend('-find',axesH);
if ~isempty(legh)
	ud = get(legh, 'userdata');
	if isequal(length(ud.legendpos),1)
		legendpos = ud.legendpos;
	else
		% legend position must be in units of points
        legendpos = hgconvertunits(ancestor(axesH, 'figure'), ...
            get(legh,'position'), get(legh,'units'), 'points', ...
            get(legh,'parent'));
	end

	% for each handle in legend put in legend entry
	% If it's a datahandle, create a legend for it.
    bfit = zeros(length(oldhandles),1);
	for i=1:length(oldhandles)
		if ishandle(oldhandles(i)) % could be a deleted handle
			appdata = getappdata(oldhandles(i),'bfit');
			bfit(i) = ~isempty(appdata);
			if bfit(i)
				% if datahandle, then create legend for it.
				% otherwise, it was created by basic fit, so ignore:
				% it will get recreated with it's datahandle legend.
				if ~isempty(datahandles) && any(oldhandles(i) == datahandles)
					[tmpH, tmpM] = createdatalegend(axesH,oldhandles(i));
					allH = [allH, tmpH];
					allM = strvcat(allM,tmpM);
				end
			else % not bfit
				allH = [allH, oldhandles(i)];
				allM = strvcat(allM,oldstrings{i});
			end
		end
	end
else
	legendpos = 1;
end

% Check for any data not in a legend
for i=1:length(datahandles)
	if isempty(oldhandles) || all(oldhandles ~= datahandles(i))
		[tmpH, tmpM] = createdatalegend(axesH,datahandles(i));
		allH = [allH, tmpH];
		allM = strvcat(allM,tmpM);
	end
end
if length(oldstrings) > length(oldhandles)
	allM = strvcat(allM, oldstrings{(length(oldhandles)+1):end});
end

if ~isempty(allH)
	bfitlistenoff(get(axesH,'parent'));
	legendH = legend(axesH, allH, allM, legendpos);
	bfitlistenon(get(axesH,'parent'));
	bfitlisten(legendH);
else
    legend(axesH,'off');
    legendH = [];
end

%------------------------------------------------------------------------
function [H, M] = createdatalegend(axesH,dataH)

numdata = 1;
dataname = getappdata(dataH,'bfit_dataname');
% 16+3=19 since 16 the longest character string in the legend (add
% 3 spaces for indent)
maxstringlength = max(19,length(dataname));  

bfitappdata = getappdata(dataH,'bfit');
if ~isempty(bfitappdata) && ~isequal(bfitappdata.type,'data')
    H = dataH;
    M = char(repmat(32,1,maxstringlength)); 
    if ~isempty(dataH) % data
        M(1,1:length(dataname)) = dataname;
    end
else
    % get bfit info
    evalresults = getappdata(dataH, 'Basic_Fit_EvalResults');
    if isempty(evalresults)
        evalresultsH = [];
    else
        evalresultsH = evalresults.handle;
    end
    fitshandles = getappdata(dataH,'Basic_Fit_Handles');
    fitsvalid = find(isfinite(fitshandles));
    
    % get datastat info
    xstathandles = getappdata(dataH,'Data_Stats_X_Handles');
    xstatvalid = find(isfinite(xstathandles));
    ystathandles = getappdata(dataH,'Data_Stats_Y_Handles');
    ystatvalid = find(isfinite(ystathandles));
    Hstat = [xstathandles(xstatvalid), ystathandles(ystatvalid)];
    H = [dataH, fitshandles(fitsvalid), evalresultsH, Hstat];
    
    numfits = length(fitsvalid);
    numxstats = length(xstatvalid);
    numystats = length(ystatvalid);
    if isempty(evalresultsH)
        numevalresults = 0;
    else
        numevalresults = 1;
    end
    
    n = numdata + numfits + numevalresults + numxstats + numystats;
    M = char(repmat(32,n,maxstringlength)); 
    if ~isempty(dataH) % data
        M(1,1:length(dataname)) = dataname;
    end
    for i = 1:numfits
        % get fit type
        fittype = fitsvalid(i)-1;
        % add string to matrix
        M(numdata+i,:) = legendstring('fit',fittype,maxstringlength);
    end
    if numevalresults
        M(numdata+numfits+numevalresults,:) = legendstring('eval results',0,maxstringlength);
    end
    for i = 1:numxstats
        % add string to matrix
        M(numdata+numfits+numevalresults+i,:) = legendstring('xstat',xstatvalid(i),maxstringlength);
    end
    for i = 1:numystats
        % add string to matrix
        M(numdata+numfits+numevalresults+numxstats+i,:) = legendstring('ystat',ystatvalid(i),maxstringlength);
    end
end




%-------------------------------------------------------
function legstring = legendstring(whichstring,strtype,maxstringlength)

start = 4;
legstring = blanks(maxstringlength);
if maxstringlength < 16
    error('MATLAB:bfitcreatelegend:LegendStringLength', 'Maxstringlength must be at least 16.')
end

switch whichstring
case {'fit'}
    switch strtype
    case 0
        legstring(start:start+5) = 'spline';
    case 1
        legstring(start:start+15) = 'shape-preserving';
    case 2
        legstring(start:start+5) = 'linear';
    case 3
        legstring(start:start+8) = 'quadratic';
    case 4
        legstring(start:start+4) = 'cubic';
    otherwise
        if (strtype==11)
            legstring(start:start+10) = [num2str(strtype-1),'th degree'];
        else
            legstring(start:start+9) = [num2str(strtype-1),'th degree'];
        end
    end
case {'xstat','ystat'}
    if isequal('xstat',whichstring)
        legstring(start) = 'x';
    else
        legstring(start) = 'y';
    end
    startplusskip = start + 2;
    switch strtype
    case 1
        legstring(startplusskip:startplusskip+2) = 'min';
    case 2
        legstring(startplusskip:startplusskip+2) = 'max';
    case 3
        legstring(startplusskip:startplusskip+3) = 'mean';
    case 4
        legstring(startplusskip:startplusskip+5) = 'median';
    case 5
        legstring(startplusskip:startplusskip+2) = 'std';
    otherwise
        error('MATLAB:bfitcreatelegend:LegendNoRangeString','No legend string for range.')
    end
case 'eval results'
    legstring(start:start+7) = 'Y = f(X)';
otherwise
    error('MATLAB:bfitcreatelegend:NoStringType', 'No such whichstring strtype.')
end    
