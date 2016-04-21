function setVisOnStorageOptionDependentParams(handles,arg,val)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:23 $

if ~isempty(arg),
    if strcmp(val,'on') && ~strcmp(arg.name,'Return value'),
        switch arg.storageOption
            case 'Specify address',
                set(handles.addressEditBoxTag,'Visible','on');
                set(handles.addressTextTag,'Visible','on');
                set(handles.globVarNameEditBoxTag,'Visible','off');
                set(handles.globVarNameTextTag,'Visible','off');
            case 'Global variable',
                set(handles.addressEditBoxTag,'Visible','off');
                set(handles.addressTextTag,'Visible','off');
                set(handles.globVarNameEditBoxTag,'Visible','on');
                set(handles.globVarNameTextTag,'Visible','on');
            case 'Automatic',
                set(handles.addressEditBoxTag,'Visible','off');
                set(handles.addressTextTag,'Visible','off');
                set(handles.globVarNameEditBoxTag,'Visible','off');
                set(handles.globVarNameTextTag,'Visible','off');
        end
    else
        % Arg does not show these params; make invisible
        set(handles.addressEditBoxTag,'Visible','off');
        set(handles.addressTextTag,'Visible','off');
        set(handles.globVarNameEditBoxTag,'Visible','off');
        set(handles.globVarNameTextTag,'Visible','off');
    end
else 
    % No arg to display
    set(handles.addressEditBoxTag,'Visible','off');
    set(handles.addressTextTag,'Visible','off');
    set(handles.globVarNameEditBoxTag,'Visible','off');
    set(handles.globVarNameTextTag,'Visible','off');
end

