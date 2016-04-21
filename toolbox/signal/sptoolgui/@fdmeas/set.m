function set(obj,varargin)
%SET  Method for FD meas object
%   - currently supports only scalar object inputs
% Syntax supported:
%   SET(obj,'propname',val,...)
%   SET(obj,struct,...)
%   SET(obj,{'propname1' 'propname2' ...},{val1 val2 ...},...

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

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
                     objud.position,ud.ht.measFrame,objud.hlabel);
        case 'value'
            objud.lastvalue = objud.value;
            objud.value = vals{i};
            set(obj.h,'userdata',objud)
            switch get(obj.h,'style')
            case {'edit','text'}
                set(obj.h,'string',fdutil('formattedstring',obj))
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
                                     objud.hlabel,ud.ht.measFrame);
            set(obj.h,'position',pos)
            set(objud.hlabel,'position',labelpos)
            objud = setfield(objud,fields{i},vals{i});
            
        case {'lastvalue','range','inclusive','userdata','help'}
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

