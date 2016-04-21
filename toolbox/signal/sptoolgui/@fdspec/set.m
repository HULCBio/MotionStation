function set(obj,varargin)
%SET  Method for FD spec object
%   - currently supports only scalar object inputs
% Syntax supported:
%   SET(obj,'propname',val,...)
%   SET(obj,struct,...)
%   SET(obj,{'propname1' 'propname2' ...},{val1 val2 ...},...

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

objud = get(obj.h,'userdata');
fig = get(obj.h,'parent');
ud = get(fig,'userdata');

hp = [];  % handle properties struct
ind = 1;
while ind < length(varargin)

    if isstruct(varargin{ind}) % struct
        fields = fieldnames(varargin{ind});
        vals = {};
        for i = 1:length(fields)
            vals{i} = getfield(varargin{ind},fields{i});
        end
        ind = ind + 1;
    elseif iscell(varargin{ind})  % cell array of properties
        fields = varargin{ind};
        vals = varargin{ind+1};
        if length(fields)~=length(vals)
            error('When using cell syntax, number of props must match values.')
        end
        ind = ind + 2;
    else % property name
        fields = varargin(ind);
        vals = varargin(ind+1);
        ind = ind + 2;
    end

    for i = 1:length(fields)
        fields{i} = lower(fields{i});
        switch fields{i}
        case 'label' 
            objud.label = vals{i};
            fdutil('newlabel',obj.h,objud.label,...
                     objud.position,ud.ht.specFrame,objud.hlabel);

        case 'value'
            objud.lastvalue = objud.value;
            objud.value = vals{i};
            set(obj.h,'userdata',objud)
            switch get(obj.h,'style')
            case {'edit','text'}
                set(obj.h,'string',fdutil('formattedstring',obj))
            case 'togglebutton'
                if vals{i}==0  % turn mode off
                    %  no-op
%                     if ud.pointer == 3 & isequal(ud.modeObject.h,obj.h)
%                         if isempty(ud.defaultModeObject)
%                             ud.pointer = 0;
%                             setptr(fig,'arrow')
%                             set(fig,'userdata',ud)
%                         elseif ~isequal(ud.defaultModeObject.h,obj.h)
%                             defaultModeObject = ud.defaultModeObject.h;
%                             defUd = get(defaultModeObject,'userdata');
%                             modePointer = defUd.modepointer;
%                             setptr(fig,modePointer)
%                             set(defaultModeObject,'value',1)
%                             defUd.value = 1;
%                             set(defaultModeObject,'userdata',defUd)
%                         end
%                     end
                else  % turn mode on
                    if strcmp(objud.defaultmode,'on')
                        ud.pointer = 0;
                        setptr(fig,'arrow')
                    else
                        ud.pointer = 3;
                        setptr(fig,objud.modepointer)
                    end
                    % turn off mouse zoom mode if it's on:
                    if strcmp(get(ud.toolbar.mousezoom,'state'),'on') 
                        set(ud.toolbar.mousezoom,'state','off');
                        set(fig,'windowbuttondownfcn','filtdes(''down'')')
                    end
                    ud.modeObject = obj;
                    set(fig,'userdata',ud)
    
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
                end
                set(obj.h,'value',vals{i})
            otherwise
                set(obj.h,'value',objud.value)
            end
        case 'format'
            objud.format = vals{i};
            set(obj.h,'userdata',objud)
            switch get(obj.h,'style')
            case {'edit','text'}
                set(obj.h,'string',fdutil('formattedstring',obj))
            otherwise
                set(obj.h,'value',objud.value)
            end
        case {'callback', 'radiogroup'}
            if ~isstr(vals{i})
                str = sprintf('Value for property ''%s'' must be a string.',...
                              fields{i});
                error(str)
            end
            objud = setfield(objud,fields{i},vals{i});
        case 'integer'
            if ~isequal(vals{i},0) & ~isequal(vals{i},1)
                error('''integer'' property must be 0 or 1.')
            end
            objud = setfield(objud,fields{i},vals{i});
        case {'editable','visible'}
            if ~isequal(vals{i},'on') & ~isequal(vals{i},'off')
                error(sprintf('''%s'' property must be ''on'' or ''off''.',...
                               fields{i}))
            end
            objud = setfield(objud,fields{i},vals{i});
            if strcmp(fields{i},'editable')
                hp.enable = vals{i};
            else
                hp.visible = vals{i};
                set(objud.hlabel,'visible',vals{i})
            end
        case 'position'
            [pos,labelpos] = fdutil('specpos',vals{i},obj.h,...
                                     objud.hlabel,ud.ht.specFrame);
            set(obj.h,'position',pos)
            set(objud.hlabel,'position',labelpos)
            objud = setfield(objud,fields{i},vals{i});
        case 'defaultmode'
            if strcmp(vals{i},'on')
                ud.defaultModeObject = obj;
                set(fig,'userdata',ud)
            else
                if isequal(ud.defaultModeObject,obj)
                    ud.defaultModeObject = [];
                    set(fig,'userdata',ud)
                end
            end
            objud = setfield(objud,fields{i},vals{i});
        case {'lastvalue','complex','revertvalue','range',...
              'inclusive','userdata','help','modepointer',...
              'modebuttondownmsg','leavemodecallback','modemotionfcn',...
              'defaultmode'}
            objud = setfield(objud,fields{i},vals{i});
        otherwise  % HG property
            hp = setfield(hp,fields{i},vals{i});
        end
    
    end
end

if ~isempty(hp)
    set(obj.h,hp)
end
set(obj.h,'userdata',objud)

