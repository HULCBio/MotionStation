function set(obj,varargin)
%SET  Method for FD line object
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
        case {'xdata' 'ydata'}
            if ~strcmp(objud.delayrender,'on')
                hp = setfield(hp,fields{i},vals{i});
            else
                objud = setfield(objud,fields{i},vals{i});
                if strcmp(fields{i},'xdata')
                    objud.xneedrender = 1;
                else
                    objud.yneedrender = 1;
                end
            end
        case 'delayrender'
            objud = setfield(objud,fields{i},vals{i});
            if strcmp(objud.delayrender,'off')
                if objud.xneedrender
                    objud.xneedrender = 0;
                    hp.xdata = objud.xdata;
                    objud.xdata = [];
                end
                if objud.yneedrender
                    objud.yneedrender = 0;
                    hp.ydata = objud.ydata;
                    objud.ydata = [];
                end
            end
        case {'vertexdragmode','vertexdragcallback','vertexenddragcallback',...
              'segmentdragmode','segmentdragcallback','segmentenddragcallback', ...
              'segmentpointer','vertexpointer',...
              'buttonupfcn','buttondownfcn',...
              'userdata','help','affectlimits'}
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
