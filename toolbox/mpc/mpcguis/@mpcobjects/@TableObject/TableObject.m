function this = TableObject(Header, isEditable, javaClass, ...
                    CellData, DataCheckFcn, varargin)

% Class constructor

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2004/04/10 23:37:28 $

this=mpcobjects.TableObject;
% if nargin == 0, creating object from a saved state.
if nargin > 0
    this.Header = Header;
    this.isEditable = isEditable;
    this.isString = javaClass;
    this.setCellData(CellData);
    this.DataCheckFcn = {DataCheckFcn};
    this.DataCheckArgs = varargin;
    this.selectedRow = -1;
    this.DataListener = handle.listener(this, this.findprop('CellData'), ...
        'PropertyPostSet', {@LocalDataListener, this});
    this.EditListener = handle.listener(this, this.findprop('isEditable'), ...
        'PropertyPostSet', {@LocalDataListener, this});
    this.SelectionListener = handle.listener(this, this.findprop('selectedRow'), ...
        'PropertyPostSet', {@LocalRowListener, this});
    this.ListenerEnabled = true;
    this.CellEditor = [];
end

% -------------------------------------------------------------- %

function LocalDataListener(eventSrc, eventData, this)
% Responds to change in CellData and/or isEditable property.  Updates 
% data in the java table.

%disp('In LocalDataListener')
if this.ListenerEnabled
    this.Table.getModel.updateTableData(this.Table, this, ...
        this.isEditable', this.CellData');
else
    % If not enabled, turn back on for next event
    this.ListenerEnabled = true;
end
% Make sure cell activation selects contents
if isempty(this.CellEditor)
    Editable = find(this.isEditable); % Look for an editable column
    if ~isempty(Editable)
        this.Table.editCellAt(0,Editable(1)-1);
        this.CellEditor = this.Table.getCellEditor;
        if ~isempty(this.CellEditor)
            this.CellEditor.setClickCountToStart(1);
        end
    end
end


% -------------------------------------------------------------- %

function LocalRowListener(eventSrc, eventData, this)
% Responds to change in selectedRow property.  
% Selects the row in the java table.

%disp('In LocalRowListener')
if this.ListenerEnabled
    this.Table.updateSelectedRow(this.selectedRow-1);
end
