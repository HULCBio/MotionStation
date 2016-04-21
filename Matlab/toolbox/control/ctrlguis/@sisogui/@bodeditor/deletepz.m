function deletepz(Editor,CurrentAxes)
%DELETEPZ  Deletes pole or zero graphically.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.23 $  $Date: 2002/04/10 04:56:13 $

% Data and handles
EditModel = Editor.EditedObject;
if isempty(EditModel.PZGroup)  
    % Nothing to delete
    return
end
Ts = EditModel.Ts;
PlotAxes = getaxes(Editor.Axes);
EventMgr = Editor.EventManager;

% Acquire pole/zero position 
iAxes = find(PlotAxes==CurrentAxes);
PlotAxes = PlotAxes(iAxes);  % mag or phase axes
CP = get(PlotAxes,'CurrentPoint');
PZViews = Editor.EditedPZ(:,iAxes);
Xm = CP(1,1);  Ym = CP(1,2);  % pointer location

% Get positions of compensator poles and zeros
hPZ = [get(PZViews,{'Zero'}) ; get(PZViews,{'Pole'})];
hPZ = cat(1,hPZ{:});
X = get(hPZ,{'Xdata'});  X = cat(1,X{:});
Y = get(hPZ,{'Ydata'});  Y = cat(1,Y{:});

% Adjust for X and Y scales (distance measured in pixels, not data units)
Lims = get(PlotAxes,{'Xlim','Ylim'});
if strcmp(Editor.Axes.XScale,'log')
    Lims{1} = log2(Lims{1});   Xm = log2(Xm);
    ispos = (X>0);
    X(ispos,:) = log2(X(ispos,:));   
    X(~ispos,:) = -Inf;   
end
if strcmp(Editor.Axes.YScale{iAxes},'log')
    Lims{2} = log2(Lims{2});   Ym = log2(Ym);
    ispos = (Y>0);
    Y(ispos,:) = log2(Y(ispos,:));   
    Y(~ispos,:) = -Inf;   
end

% Determine nearest match
[distmin,imin] = ...
    min(abs(((Xm-X)/diff(Lims{1})).^2 + ((Ym-Y)/diff(Lims{2})).^2));

if distmin < 0.03^2,
    % Identify selected group and get its description
    SelectedGroup = get(getappdata(hPZ(imin),'PZVIEW'),'GroupData');
    isel = find(EditModel.PZGroup==SelectedGroup);
    Description = EditModel.PZGroup(isel).describe(Ts);
    
    % Start transaction
    T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Delete %s',Description{1}),...
        'OperationStore','on','InverseOperationStore','on');
    
    % Delete selected group from list of compensator PZ groups
    delete(EditModel.PZGroup(isel));
    EditModel.PZGroup = EditModel.PZGroup([1:isel-1,isel+1:end],:);
    
    % Register transaction
    EventMgr.record(T);
    
    % Notify peers of deletion
    Editor.LoopData.dataevent('all');
    
    % Notify status and history listeners
    Status = sprintf('Deleted %s',Description{2});
    EventMgr.newstatus(Status);
    EventMgr.recordtxt('history',Status);
end
