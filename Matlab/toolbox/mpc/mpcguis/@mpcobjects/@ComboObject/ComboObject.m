function this = ComboObject(ListData, SelectedItemObject, ...

% Copyright 2003 The MathWorks, Inc.

    SelectedItemField, SelectedItemValue)

% Constructor for ComboBox java/UDD object
% Author(s): Larry Ricker

% The UDD storage for the combo box selected item value is
% SelectedItemObject.SelectedItemField
%
% SelectedItemValue sets the initial selected item.

import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.mpc.*;

if ~iscell(ListData)
    error('@ComboObject:  ListData must be a cell array')
elseif ~isstr(SelectedItemField)
    error('@ComboObject:  SelectedItemField must be a string')
end
try 
    Str =get(SelectedItemObject,SelectedItemField);
    if ~ischar(Str)
        error('SelectedItemField is not a string')
    end
catch
    disp(lasterr)
    error(sprintf(['@ComboObject:  "%s" is not a field in', ...
            ' object type "%s".'], SelectedItemField, ...
        class(SelectedItemObject)));
end
this = mpcobjects.ComboObject;
this.SelectedItemObject = SelectedItemObject;
this.SelectedItemField = SelectedItemField;
set(this,'ListData',ListData);
this.Combo = com.mathworks.toolbox.mpc.MPCCombo(this, SelectedItemObject, ...
    SelectedItemField);
