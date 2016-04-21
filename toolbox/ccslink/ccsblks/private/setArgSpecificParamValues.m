function setArgSpecificParamValues(handles,arg);
% Sets uicontrol values according to data in specified "arg" structure
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:14 $

set(handles.argNameTextTag,  'string', arg.name);
set(handles.cTypeTextTag,    'string', arg.cType);
set(handles.equivTypeTextTag,'string', arg.equivType);

set(handles.portAssignPopupTag,'value', ...
    popupVal(handles,'portAssignPopupTag',arg.portAssign));
if strcmp(arg.name,'Return value') || ~arg.isPtr,
    set(handles.portAssignPopupTag,'enable', 'off');
    set(handles.portAssignTextTag,'enable',  'off');
else
    set(handles.portAssignPopupTag,'enable', 'on');
    set(handles.portAssignTextTag,'enable',  'on');
end    
if arg.isPtr,
    % Size param in UDATA is always 2 elements of type uint32. 
    % Display as string.
    sz = mat2str(double(arg.size));
    set(handles.sizeEditBoxTag,'string',sz);
    % Storage option, Address, Global Var do not apply for return value.
    if ~strcmp(arg.name,'Return value'),
        set(handles.storageOptionPopupTag,'value', ...
            popupVal(handles,'storageOptionPopupTag',arg.storageOption));
        setStorageOptionDependentParamValues(handles,arg);
    end
end
