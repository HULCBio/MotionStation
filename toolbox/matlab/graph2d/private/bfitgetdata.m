function [hList,nList]=bfitgetdata(figureH)
%BFITGETDATA Finds all lines of a figure 
% and returns a list of those handles with appropriate names  

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.19.4.3 $  $Date: 2004/04/29 03:39:47 $

axesList = findobj(figureH, 'type', 'axes');
taglines = get(axesList,'tag');
notlegendind = ~(strcmp('legend',taglines));
tmp = findobj(axesList(notlegendind),'type','line');
tmp = flipud(tmp(:)); % so comes out as added to figure
bfitdataall = getappdata(figureH,'Basic_Fit_Data_All');

% This function needs to return "good" lines as well as lines that 
% have just become "bad". "Good" lines have no zdata and lengths of 
% xdata and ydata are equal. 
 
j = 1;
h = [];
for i = 1:length(tmp)
    if shouldBeAdded(tmp(i))
	   	h(j) = tmp(i);
		j = j+1;
	end
end

% reorder h so fits, residuals, eval results, data stats, if any, are at the end
bfitind = false(size(h));
for i = 1:length(h)
    value = getappdata(h(i),'bfit');
    if isempty(value)
        fitappdata.type = 'data potential';
        fitappdata.index = [];
        setappdata(h(i),'bfit',fitappdata);
		p = schema.prop(handle(h(i)), 'Basic_Fit_Copy_Flag', 'MATLAB array');
		p.AccessFlags.Copy = 'off';
        if ~isempty(bfitdataall) & ~any(h(i) == bfitdataall)
            bfitdataall(end + 1) = h(i);
        else
            bfitdataall(1) = h(i);
        end
    elseif ~isequal(value.type,'data') & ~isequal(value.type,'data potential')
        bfitind(i) = true; 
    end
end % for
setappdata(figureH,'Basic_Fit_Data_All', bfitdataall);

% This is all data or potential data in the figure that isn't created by the gui (fit or data stat)
% and the axes that goes with them.
bfitdata = h(~bfitind);
dataaxescell = get(bfitdata,'parent');
if iscell(dataaxescell)
    dataaxes = unique([dataaxescell{:}]);
else % scalar
    dataaxes = dataaxescell;
end
setappdata(figureH,'Basic_Fit_Axes_All',dataaxes);

% code to get selected handles
selectedHandles = [];
aFigObjH = getobj(figureH);
if ~isempty(aFigObjH)
    dragBinH = aFigObjH.DragObjects;
    if ~isempty(dragBinH.Items)
        objectVector = struct(dragBinH.Items);
        if ~isempty(objectVector)
            selectedHandles = [objectVector.HGHandle];
        end
    end
end
selected = ismember(h,selectedHandles);

% Move the selected lines to the front, then the unselected lines,
% then the selected fits followed by the unselected fits.
% If you want data and fit/stat lines, use this:
% h = [h(selected & ~bfitind); h(~selected & ~bfitind); 
%    h(selected & bfitind); h(~selected & bfitind)];
% If you want just data lines, use this:
h = [h(selected & ~bfitind), h(~selected & ~bfitind)]; 

% If data is not tagged, give it a name.
% Put the tag or name in the appdata
[hList, nList] = datanames(h,figureH);

%-----------------------------------------------------------------
function retval = shouldBeAdded(line)
% Should be added if the line is "good" (there is no zdata and length of xdata and ydata 
% are the same) OR if it was "good" data that has gone "bad" (there is z data or lengths of
% xdata or ydata are not equal).

retval = false;
zd = get(line, 'zdata');
xd = get(line, 'xdata');
yd = get(line, 'ydata');

if isempty(zd) &&  length(xd) == length(yd)
    retval = true;
elseif isappdata(line, 'bfit')
    retval = true;
end

%-----------------------------------------------------------------
function [hList,tagList]=datanames(h,figureH)

%Gets name descriptions for handles
%returns two column cell arrays
if length(h)==0
    hList={};
    tagList={};
    countstart = 1; % Start counting at one
else
    
    hList=num2cell(h);
    hList=hList(:);
    
    countstart = getappdata(figureH,'Basic_Fit_Data_Counter');
    tagList=get(h,'tag');
    if length(h)==1
        tagList={tagList};
    end
    
    % if appdataname exists, use it.
    % else if it is a graph2d.lineseries and there is a displayname, use it
    % else use 'tag'
    % else create a name using the counter.
    for i=1:length(h)
        appdataname = getappdata(h(i),'bfit_dataname');
        if isempty(appdataname)
            if isa(handle(h(i)), 'graph2d.lineseries') && ~isempty(get(h(i), 'DisplayName'))
                tagList{i} = get(h(i), 'DisplayName');
            elseif isempty(tagList{i})
                tagList{i} = ['data ',int2str(countstart)];
                countstart = countstart + 1;
            end
            d = tagList{i};
            % name must be a char row vector.
            if ~isequal(size(d,1),1)
                d = d';
                d = (d(:))';
            end
            setappdata(h(i),'bfit_dataname',d);
        else
            tagList{i} = appdataname;
        end
    end
end
setappdata(figureH,'Basic_Fit_Data_Counter',countstart);

