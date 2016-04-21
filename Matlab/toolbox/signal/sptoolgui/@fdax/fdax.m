function obj = fdax(varargin)
%FDAX  Constructor for filtdes axes object
% Syntax:
%    obj = fdax('prop1',val1,'prop2',val2,...)  creates a new object
%    obj = fdax(objstruct) where objstruct is a structure array with a single
%             field named 'h' and the handle is to a valid object, simply calls
%             class(objstruct,'fdax').

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

if isstruct(varargin{1}) & isequal(fieldnames(varargin{1}),{'h'})
    obj = class(varargin{1},'fdax');
    return
end

fig = findobj('type','figure','tag','filtdes');
ud = get(fig,'userdata');

% first define default property values
% objud - object's userdata structure
objud.title = '';
objud.xlabel = '';
objud.ylabel = '';
objud.pointer = 'arrow';
objud.position = 1;  % if this is a scalar, position is automatically found
objud.xlimbound = 'auto';
objud.ylimbound = 'auto';
objud.xlimpassband = 'nochange';
objud.ylimpassband = 'nochange';
objud.aspectmode = 'normal';  % can be 'normal' or 'equal'
objud.overlay = 'on';
objud.overlayhandle = [];
objud.visible = 'on';
objud.userdata = [];
objud.help = {''};

% HP - handle properties structure
hp.units = 'pixels';
hp.box = 'on';
hp.parent = fig;

for i = 1:2:length(varargin)

    varargin{i} = lower(varargin{i});
    switch varargin{i}
    case {'title','xlabel','ylabel','pointer','xlimbound',...
           'ylimbound','xlimpassband','ylimpassband','aspectmode','overlay',...
           'overlayhandle',...
           'visible','position',...
           'userdata','help'}
        objud = setfield(objud,varargin{i:i+1});
    otherwise
        hp = setfield(hp,varargin{i:i+1});
    end
    
end

grid = filtdes('grid',fig);
hp.xgrid = grid;
hp.ygrid = grid;

hp.visible = objud.visible;
obj.h = axes(hp);
co = get(0,'defaultaxescolororder');
L = line('parent',obj.h,'color',co(min(3,size(co,1)),:),'visible','off',...
         'tag','overlayline');
objud.overlayhandle = L;

set(get(obj.h,'title'),'string',objud.title,'tag',get(obj.h,'tag'))
set(get(obj.h,'xlabel'),'string',objud.xlabel,'tag',get(obj.h,'tag'))
set(get(obj.h,'ylabel'),'string',objud.ylabel,'tag',get(obj.h,'tag'))

set(obj.h,'userdata',objud)

obj = class(obj,'fdax');

%
% Add this object to figure's object list
%
if ~isfield(ud.Objects,'fdax') | isempty(ud.Objects.fdax)
    ud.Objects.fdax = obj;
else
    ud.Objects.fdax(end+1) = obj;
end
set(fig,'userdata',ud)

setpos(obj,fig)
if strcmp(objud.overlay,'on')
    set(ud.toolbar.overlay,'enable','on')
end
