function setSelectedItem(this, SelectedItem)

% Copyright 2003 The MathWorks, Inc.

% If the specified selected item is in the list, update the
% SelectedItem property
ListData = this.ListData;
if ~isempty(this.getIndexOf(SelectedItem))   
    % Note:  if selected item isn't in the list, request is ignored.
    set(this.SelectedItemObject, this.SelectedItemField, SelectedItem);
end