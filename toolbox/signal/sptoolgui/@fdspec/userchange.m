function UserChange(obj)
%UserChange  Method for FD spec object

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

obj = struct(obj);
objud = get(obj.h,'userdata');

switch get(obj.h,'style')
case 'edit'
    str = get(obj.h,'string');
    [val,errstr] = fdutil('fdvalidstr',str,objud.complex,objud.integer,...
                              objud.range,objud.inclusive);
    if isempty(errstr)
        fig = get(obj.h,'parent');
        ud = get(fig,'userdata');
        if strcmp(get(ud.ht.revert,'enable'),'off')
            objud.revertvalue = objud.value;
        end
        objud.lastvalue = objud.value;
        objud.value = val;
        set(obj.h,'userdata',objud)
        set(obj.h,'string',fdutil('formattedstring',obj))
        if ~isempty(objud.callback) & objud.lastvalue ~= objud.value
            cb_error = 0;
            evalin('base',objud.callback,'cb_error = 1;')
            if cb_error
                errstr = sprintf('Error in evaluating callback:\n%s',lasterr);
                msgbox(errstr,'Error','error','modal')
            end
        end
    else
        msgbox(errstr,'Error','error','modal')
        set(obj.h,'string',fdutil('formattedstring',obj))
    end

case {'popupmenu', 'checkbox'}
    fig = get(obj.h,'parent');
    ud = get(fig,'userdata');
    if strcmp(get(ud.ht.revert,'enable'),'off')
        objud.revertvalue = objud.value;
    end
    objud.lastvalue = objud.value;
    objud.value = get(obj.h,'value');
    set(obj.h,'userdata',objud)
    if ~isempty(objud.callback)
        cb_error = 0;
        evalin('base',objud.callback,'cb_error = 1;')
        if cb_error
            errstr = sprintf('Error in evaluating callback:\n%s',lasterr);
            msgbox(errstr,'Error','error','modal')
        end
    end

case 'radiobutton'
    fig = get(obj.h,'parent');
    ud = get(fig,'userdata');
    if objud.value == 1     % if radio button is already on, leave it on!
        set(obj.h,'value',1)
        return
    end
    if strcmp(get(ud.ht.revert,'enable'),'off')
        objud.revertvalue = objud.value;
    end
    objud.lastvalue = objud.value;
    objud.value = get(obj.h,'value');
    set(obj.h,'userdata',objud)
    
    % find other radiobuttons with this radiogroup property
    % and set their values to 0.
    h = [ud.Objects.fdspec.h];
    for i=length(h):-1:1
        h_ud = get(h(i),'userdata');
        if strcmp(get(h(i),'style'),'radiobutton') & ...
           strcmp(h_ud.radiogroup,objud.radiogroup) & (h(i)~=obj.h)
            set(h(i),'value',0)
            if strcmp(get(ud.ht.revert,'enable'),'off')
                h_ud.lastvalue = h_ud.value;
            end
            h_ud.value = 0;
            set(h(i),'userdata',h_ud)
        end
    end
    
    if ~isempty(objud.callback)
        cb_error = 0;
        evalin('base',objud.callback,'cb_error = 1;')
        if cb_error
            errstr = sprintf('Error in evaluating callback:\n%s',lasterr);
            msgbox(errstr,'Error','error','modal')
        end
    end
    
case 'pushbutton'
    if ~isempty(objud.callback)
        cb_error = 0;
        evalin('base',objud.callback,'cb_error = 1;')
        if cb_error
            errstr = sprintf('Error in evaluating callback:\n%s',lasterr);
            msgbox(errstr,'Error','error','modal')
        end
    end
    
case 'togglebutton'
% go into or out of 'mode' for this button
    fig = get(obj.h,'parent');
    ud = get(fig,'userdata');
    if strcmp(get(ud.ht.revert,'enable'),'off')
        objud.revertvalue = objud.value;
    end
    
    if objud.value == 1     % if toggle button is being turned off:
        set(obj.h,'value',1)    % don't allow this!
        return
    end
    
    objud.lastvalue = objud.value;
    objud.value = get(obj.h,'value');
    set(obj.h,'userdata',objud)
    
    % otherwise, turn on the toggle button's mode:
    if strcmp(objud.defaultmode,'on')
        ud.pointer = 0;
        setptr(fig,'arrow')
    else
        ud.pointer = 3;
        setptr(fig,objud.modepointer)
    end
    ud.modeObject = fdspec(obj);
    set(fig,'userdata',ud)
    % turn off mouse zoom mode if it's on:
    if strcmp(get(ud.toolbar.mousezoom,'state'),'on') 
        set(ud.toolbar.mousezoom,'state','off')
        set(fig,'windowbuttondownfcn','filtdes(''down'')')
    end
    
    % find other togglebuttons and set their values to 0.
    h = [ud.Objects.fdspec.h];
    for i=length(h):-1:1
        h_ud = get(h(i),'userdata');
        if strcmp(get(h(i),'style'),'togglebutton') & (h(i)~=obj.h)
            set(h(i),'value',0)
            if strcmp(get(ud.ht.revert,'enable'),'off')
                h_ud.lastvalue = h_ud.value;
            end
            h_ud.value = 0;
            set(h(i),'userdata',h_ud)
        end
    end
    
    if ~isempty(objud.callback)
        cb_error = 0;
        evalin('base',objud.callback,'cb_error = 1;')
        if cb_error
            errstr = sprintf('Error in evaluating callback:\n%s',lasterr);
            msgbox(errstr,'Error','error','modal')
        end
    end

otherwise
    warning('No support for this style of specification object yet')
end

