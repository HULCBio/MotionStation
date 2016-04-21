function varargout = update(h,Eman,srcisjava)
%UPDATE
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/16 22:20:12 $

% Updates the HG plot and optionally the java tables showing the data/
% axes to reflect the new preprocessing conditions. The output argument
% is the modified @dataset

% If no individiual dataset has been selected then there is nothing to update 
if h.Position<1
    return
end

s = size(h.Datasets(h.Position).Data);
data = h.Datasets(h.Position).Data;
time = h.Datasets(h.Position).Time(:);

% Write new exlusion vector back to this data set
h.ManExcludedpts{h.Position} = reshape(Eman,s);
manexcl = h.ManExcludedpts{h.Position};
ruleexcl = h.Exclusion.feval(h.Datasets(h.Position));

% Modify output data - all excluded  points are NaN
t = (~manexcl & ~ruleexcl);
thisdata = data;
thisdata(~t) = NaN;

% Apply filtering rules
try
    moddataset = h.Filtering.feval(preprocessgui.dataset(thisdata,time));
catch
    msg = ['Could not apply filtering rule. MATLAB returned ' lasterr];
    msgbox(msg,'Data Preprocessing Tool','modal');
    moddataset = preprocessgui.dataset(thisdata,time);
end

% Apply interpolation rules
try
    moddataset = h.Interp.feval(moddataset);
catch
    msg = ['Could not apply interpolation rule. MATLAB returned ' lasterr];
    msgbox(msg,'Data Preprocessing Tool','modal');
end    
modifieddata = moddataset.Data;
modifiedtime = moddataset.Time;

% If necessary export the new @dataset
if nargout>=1
    set(moddataset,'Headings',h.Datasets(h.Position).Headings,'Timeunits', h.Datasets(h.Position).Timeunits);
    varargout{1} = moddataset;
end

% Only perform the HG update if a graphical editor has been created
if ishandle(h.Window)
    % Update HG plots
    
    coldata = data(:,h.Column);
    if ~isempty(modifieddata) % modifieddata can be empty if all excluded and removed
        modcoldata = modifieddata(:,h.Column);
    else
        modcoldata = [];
    end
    t = t(:,h.Column);

    % Modify totally included pts
    set(h.Lines(1),'XData',time,'YData',coldata);
    set(h.Lines(5),'XData',1:length(modcoldata),'YData',modcoldata);
   
    if ~isempty(modcoldata) && sum(~isnan(modcoldata))>2
        ind = ~isnan(modcoldata);
        ylims = [min(modcoldata(ind)) max(modcoldata(ind))];
        ylims = ylims + .05 * [-1 1] * diff(ylims);
        ylims(2) = max(ylims(2),ylims(1)+100*eps);
        set(get(h.Lines(5),'Parent'),'Ylim',ylims,'Xlim',[1 length(modcoldata)]);
    end
    
    % Modify manually excluded points
    t = manexcl(:,h.Column) & ~ruleexcl(:,h.Column);
    set(h.Lines(2),'XData',time(t),'YData',coldata(t));
    
    % Modify rule excluded points

    t = ~manexcl(:,h.Column) & ruleexcl(:,h.Column);
    set(h.Lines(3),'XData',time(t),'YData',coldata(t));
    
    % Modify manually and rule excluded points
    t = manexcl(:,h.Column) & ruleexcl(:,h.Column);
    set(h.Lines(4),'XData',time(t),'YData',coldata(t));
    
     % Update exclusion patches
    if strcmp(h.Exclusion.Boundsactive,'on')
        xlim = [min(time) max(time)];
        xlim = xlim + .05 * [-1 1] * diff(xlim);
        ylim = [min(coldata) max(coldata)];
        ylim = ylim + .05 * [-1 1] * diff(ylim);
        xlo = max(h.Exclusion.Xlow,xlim(1));
        xp = [xlim(1) h.Exclusion.Xlow h.Exclusion.Xlow xlim(1)];
        yp = [ylim(1) ylim(1) ylim(2) ylim(2)];
        set(h.Lines(6),'XData',xp,'Ydata',yp);
        xhi = min(h.Exclusion.Xhigh,xlim(2));
        xp = [xlim(2) h.Exclusion.Xhigh h.Exclusion.Xhigh xlim(2)];
        yp = [ylim(1) ylim(1) ylim(2) ylim(2)];
        set(h.Lines(7),'XData',xp,'Ydata',yp);
        ylocol = min(h.Column,length(h.Exclusion.Ylow));
        yhicol = min(h.Column,length(h.Exclusion.Yhigh));
        ylo = max(h.Exclusion.Ylow(ylocol),ylim(1));
        yhi = min(h.Exclusion.Yhigh(yhicol),ylim(2));
        xp = [xlim(1) xlim(1) xlim(2) xlim(2)];
        yp = [ylim(1) ylo ylo ylim(1)];
        set(h.Lines(8),'XData',xp,'Ydata',yp);
        xp = [xlim(1) xlim(1) xlim(2) xlim(2)];
        yp = [ylim(2) yhi yhi ylim(2)];
        set(h.Lines(9),'XData',xp,'Ydata',yp);
    else
        for k=6:9
           set(h.Lines(k),'XData',[NaN NaN NaN NaN],'Ydata', ...
               [NaN NaN NaN NaN]);
        end
    end
end
    
% Update table in java panel
% TO DO: Fix the situation where the raw data java panel
% modifies the status but the modified panel does not update
if ~srcisjava && ~isempty(h.javaframe)   
   % Update java raw data table 
   h.javaframe.getTable.getModel.setStatus(logical(manexcl(:)),logical(ruleexcl(:)));
end

% Update java modified data table
if length(modifieddata(:))>1
    h.javaframe.getModDataTable.getModel.setData(modifiedtime(:),modifieddata(:));
end
    


