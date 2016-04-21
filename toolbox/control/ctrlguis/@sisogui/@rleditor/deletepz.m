function deletepz(Editor,varargin)
%DELETEPZ  Deletes pole or zero graphically.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.20 $  $Date: 2002/04/10 04:57:37 $

% Pointers
EditedModel = Editor.EditedObject;
if isempty(EditedModel.PZGroup)  
    % Nothing to delete
    return
end
Ts = EditedModel.Ts;
PlotAxes = getaxes(Editor.Axes);
EventMgr = Editor.EventManager;

% Acquire pole/zero position 
CP = get(PlotAxes,'CurrentPoint');     % mouse position
Lims = get(PlotAxes,{'Xlim','Ylim'});  % axis extent
Xscale = Lims{1}(2)-Lims{1}(1);
Yscale = Lims{2}(2)-Lims{2}(1);

% Determine nearest match
hPZ = [get(Editor.EditedPZ,{'Zero'}) ; get(Editor.EditedPZ,{'Pole'})];
hPZ = cat(1,hPZ{:});
X = get(hPZ,{'Xdata'});  X = cat(1,X{:});
Y = get(hPZ,{'Ydata'});  Y = cat(1,Y{:});
[distmin,imin] = ...
    min(abs(((CP(1,1)-X)/Xscale).^2 + ((CP(1,2)-Y)/Yscale).^2));

if distmin < 0.03^2,
    % Identify selected group and get its description
    SelectedGroup = get(getappdata(hPZ(imin),'PZVIEW'),'GroupData');
    isel = find(EditedModel.PZGroup==SelectedGroup);
    Description = EditedModel.PZGroup(isel).describe(Ts);
    
    % Start transaction
    T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Delete %s',Description{1}),...
        'OperationStore','on','InverseOperationStore','on');
    
    % Delete selected group from list of compensator PZ groups
    delete(EditedModel.PZGroup(isel));
    EditedModel.PZGroup = EditedModel.PZGroup([1:isel-1,isel+1:end],:);
    
    % Register transaction
    EventMgr.record(T);
    
    % Notify peers of deletion
    Editor.LoopData.dataevent('all');
    
    % Notify status and history listeners
    Status = sprintf('Deleted %s',Description{2});
    EventMgr.newstatus(Status);
    EventMgr.recordtxt('history',Status);
end
