function javaString = getSelectedItem(this)

% Copyright 2003 The MathWorks, Inc.

SelectedItemValue = get(this.SelectedItemObject, this.SelectedItemField);
javaString = java.lang.String(SelectedItemValue);