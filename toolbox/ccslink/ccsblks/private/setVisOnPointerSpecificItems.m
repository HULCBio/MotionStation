function setVisOnPointerSpecificItems(handles,arg,val)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:22 $

if ~isempty(arg),
    if arg.isPtr,
        set(handles.sizeEditBoxTag,'Visible',val);
        set(handles.sizeTextTag,'Visible',val);
        if ~strcmp(arg.name,'Return value'),
            set(handles.storageOptionTextTag,'Visible',val);
            set(handles.storageOptionPopupTag,'Visible',val);
            setVisOnStorageOptionDependentParams(handles,arg,val);
        else  % Return value:
            set(handles.storageOptionTextTag,'Visible','off');
            set(handles.storageOptionPopupTag,'Visible','off');
            setVisOnStorageOptionDependentParams(handles,arg,'off');
        end
    else   
        %arg not a pointer
        set(handles.sizeEditBoxTag,'Visible','off');
        set(handles.sizeTextTag,'Visible','off');
        set(handles.storageOptionTextTag,'Visible','off');
        set(handles.storageOptionPopupTag,'Visible','off');
        set(handles.addressEditBoxTag,'Visible','off');
        set(handles.addressTextTag,'Visible','off');
        set(handles.globVarNameEditBoxTag,'Visible','off');
        set(handles.globVarNameTextTag,'Visible','off');
        setVisOnStorageOptionDependentParams(handles,arg,'off');
    end
else
    % No arg to display:
    set(handles.sizeEditBoxTag,'Visible',val);
    set(handles.sizeTextTag,'Visible',val);
    set(handles.storageOptionTextTag,'Visible',val);
    set(handles.storageOptionPopupTag,'Visible',val);
    set(handles.addressEditBoxTag,'Visible',val);
    set(handles.addressTextTag,'Visible',val);
    set(handles.globVarNameEditBoxTag,'Visible',val);
    set(handles.globVarNameTextTag,'Visible',val);
    setVisOnStorageOptionDependentParams(handles,arg,val);
end

