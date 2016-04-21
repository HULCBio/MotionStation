function set(obj,varargin)
%SET  Method for FD ax object
%   - currently supports only scalar object inputs
% Syntax supported:
%   SET(obj,'propname',val,...)
%   SET(obj,struct,...)
%   SET(obj,{'propname1' 'propname2' ...},{val1 val2 ...},...

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

objStruct = struct(obj);

objud = get(objStruct.h,'userdata');
fig = get(objStruct.h,'parent');
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
        case {'position','aspectmode'}
            objud = setfield(objud,fields{i},vals{i});
            set(objStruct.h,'userdata',objud)
            setpos(obj,fig)
        case {'title','xlabel','ylabel'}
            objud = setfield(objud,fields{i},vals{i});
            hand = get(objStruct.h,fields{i});
            set(hand,'string',vals{i})
        case 'visible'
            objud = setfield(objud,fields{i},vals{i});
            hp = setfield(hp,fields{i},vals{i});
        case 'overlay'  % might need to enable/disable ud.ht.overlay button of filtdes
            objud = setfield(objud,fields{i},vals{i});
            switch vals{i}
            case 'on'
                set(ud.ht.overlay,'enable','on')
            case 'off'
                allAxes = [ud.Objects.fdax.h];
                allAxes(find(allAxes==objStruct.h))=[];
                enable = 'off';
                for k = 1:length(allAxes)
                    tempud = get(allAxes(k),'userdata');
                    if strcmp(tempud.overlay,'on')
                        enable = 'on';
                        break
                    end
                end
                set(ud.ht.overlay,'enable',enable)
            end
            
        case {'pointer','xlimbound','overlayhandle',...
              'ylimbound','xlimpassband','ylimpassband',...
              'visible','position',...
              'userdata','help'}
            objud = setfield(objud,fields{i},vals{i});
        otherwise  % HG property
            hp = setfield(hp,fields{i},vals{i});
        end
    
    end
end

if ~isempty(hp)
    set(objStruct.h,hp)
end
set(objStruct.h,'userdata',objud)

