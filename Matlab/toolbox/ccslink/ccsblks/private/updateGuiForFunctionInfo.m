function updateGuiForFunctionInfo(handles,blk)
% Update the parts of the gui that depend on the function.
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:28 $


UDATA = get_param(blk,'UserData');
if ~isempty(UDATA.funcName),
    set(handles.funcDeclEditBoxTag,'string',UDATA.funcDecl);
    set(handles.specifyPrototypeCheckboxTag,'value', ...
        ~UDATA.declAutoDetermined);
    if UDATA.declAutoDetermined,
        set(handles.funcDeclEditBoxTag,'enable','off');
        set(handles.funcDeclTextTag,'enable','off');
    else
        set(handles.funcDeclEditBoxTag,'enable','on');
        set(handles.funcDeclTextTag,'enable','on');
    end
    
    setEnablesOnAllQueryDependentParams(handles, 'on');
    
    argList = '';
    for k = 1:UDATA.numArgs,
        if k>1,
            argList = [argList '|'];
        end
        argList = [argList UDATA.args(k).name];
    end
    if UDATA.hasReturnValue,
        if UDATA.numArgs>0,
            argList = [argList '|'];
        end        
        argList = [argList 'Return value'];
    end
    set(handles.argChooserListboxTag,'string',argList);
    if UDATA.numArgs>0 || UDATA.hasReturnValue,
        selectedArgNum = 1;
        set(handles.argChooserListboxTag,'value',selectedArgNum);
        if UDATA.numArgs>0
            arg = UDATA.args(selectedArgNum);
        else
            arg = UDATA.retval;
        end
        setVisOnAllArgSpecificParams(handles,arg,'on');
        setArgSpecificParamValues(handles,arg);
        if arg.isPtr,
        else
            % Force to input port
            val = popupVal(handles,'portAssignPopupTag','Input port');
            set(handles.portAssignPopupTag,'Value',val);
        end
        if strcmp(arg.name,'Return value'),
            % Force to output port
            val = popupVal(handles,'portAssignPopupTag','Output port');
            set(handles.portAssignPopupTag,'Value',val);
        end
    else % No args to display:
        setVisOnAllArgSpecificParams(handles,[],'off');
    end
end
