function Name = getSelectedModelName(this)

% Copyright 2003 The MathWorks, Inc.

% Gets name of selected model from the list display on the MPCModels node.

% Larry Ricker

UDDList = this.Handles.UDDList;
Name = UDDList.SelectedItemValue;
