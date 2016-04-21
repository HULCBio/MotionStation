function handleDeclaration(blk,handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:02 $

% Code shared between Query callback and Declaration callback.
% Assumes HilBlkSetUpLinkObjects has just been executed.
% This function then handles the GUI tasks needed at that
% stage.

UDATA = get_param(blk,'UserData');
PDATA = HilBlkPersistentData(blk,'get');
set(handles.funcDeclEditBoxTag,'string',UDATA.funcDecl);
if PDATA.tgtFcnObjFullyDeclared && ~PDATA.tgtFcnObjStale && ...
        UDATA.tgtQueried,
    set(handles.statusTextTag,'string', ...
        'Parameters synchronized with function in target memory');
    updateGuiForFunctionInfo(handles,blk);
else
    set(handles.specifyPrototypeCheckboxTag,'value', ...
        ~UDATA.declAutoDetermined);
    if UDATA.declAutoDetermined,
        set(handles.funcDeclEditBoxTag,'enable','off');
        set(handles.funcDeclTextTag,'enable','off');
    else
        set(handles.funcDeclEditBoxTag,'enable','on');
        set(handles.funcDeclTextTag,'enable','on');
    end
end
