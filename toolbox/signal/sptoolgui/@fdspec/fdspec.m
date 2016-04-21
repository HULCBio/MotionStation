function obj = fdspec(varargin)
%FDSPEC  Constructor for filtdes Specifications object
% Syntax:
%    obj = fdspec('prop1',val1,'prop2',val2,...)  creates a new object
%    obj = fdspec(objstruct) where objstruct is a structure array with a single
%             field named 'h' and the handle is to a valid object, simply calls
%             class(objstruct,'fdspec').

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

if isstruct(varargin{1}) & isequal(fieldnames(varargin{1}),{'h'})
    obj = class(varargin{1},'fdspec');
    return
end

fig = findobj('type','figure','tag','filtdes');
ud = get(fig,'userdata');

if ~isfield(ud.Objects,'fdspec') | isempty(ud.Objects.fdspec)
    pos = 1;
else
    pos = length(ud.Objects.fdspec)+1;
end

% first define default property values
% objud - object's userdata structure
objud.label = '';
objud.callback = '';
% objud.numeric = 1;  % if 0, the value of this object is a string, not a number
objud.value = 0; 
objud.lastvalue = 0;
objud.revertvalue = 0;
objud.format = '%g';
objud.range = [-Inf Inf];
objud.inclusive = [0 0];
objud.integer = 0;
objud.complex = 0;   % if 0, number must be real; if 1, number can be real or cmplx
objud.editable = 'on';
objud.visible = 'on';
objud.position = pos;  % next available
objud.radiogroup = '';
% toggle button properties:
  objud.modepointer = 'arrow';
  objud.modebuttondownmsg = '';
  objud.leavemodecallback = '';  
  objud.modemotionfcn = '';
  objud.defaultmode = 'off'; 
objud.userdata = [];
objud.help = {''};

% HP - handle properties structure
hp.parent = fig;
hp.style = 'edit';
hp.callback = 'filtdes(''fdspec'')';

for i = 1:2:length(varargin)

    varargin{i} = lower(varargin{i});
    switch varargin{i}
    case {'label','complex','callback','format','value','lastvalue','revertvalue',...
           'range','inclusive','integer','editable','visible','position',...
           'radiogroup','userdata','help','modepointer',...
           'modebuttondownmsg','leavemodecallback','modemotionfcn',...
           'defaultmode'}
        objud = setfield(objud,varargin{i:i+1});
    otherwise
        hp = setfield(hp,varargin{i:i+1});
    end
    
end

switch hp.style
case 'edit'
    hp.backgroundcolor = 'w';
    hp.horizontalalignment = 'left';
case 'text'
    hp.horizontalalignment = 'left';
case 'popupmenu'
    if objud.value < 1
        objud.value = 1;
    end
case 'frame'
    if ~isfield(objud,'position')
        objud.position = [pos pos+1];
    end
end

hp.visible = objud.visible;
obj.h = uicontrol(hp);
objud.hlabel = fdutil('newlabel',obj.h,objud.label,...
                         objud.position,ud.ht.specFrame);

set(objud.hlabel,'visible',objud.visible)
obj = class(obj,'fdspec');

objud.lastvalue = objud.value;
objud.revertvalue = objud.value;

set(obj.h,'userdata',objud)

switch hp.style
case {'edit','text'}
    set(obj.h,'string',fdutil('formattedstring',obj));
case {'popupmenu','checkbox','radiobutton'}
    set(obj.h,'value',objud.value)
case 'frame'
    % move to bottom of stacking order if necessary
    needSendToBack = 0;
    for i = 1:length(ud.Objects.fdspec)
        tempObjHand = ud.Objects.fdspec(i).h;
        tempObjUD = get(tempObjHand,'userdata');
        tpos = tempObjUD.position;
        switch length(tpos)
        case 1
            if tpos>=objud.position(1) & tpos<=objud.position(2)
                needSendToBack = 1;
            end
        case 2
            if (tpos(1)>=objud.position(1) & tpos(1)<=objud.position(2)) | ...
               (tpos(2)>=objud.position(1) & tpos(2)<=objud.position(2))
                needSendToBack = 1;
            end
        otherwise
            needSendToBack = 1;
        end
        if needSendToBack
            break
        end
    end
    if needSendToBack
        fdutil('sendToBack',fig,[objud.hlabel obj.h ud.ht.specFrame])
    end
end

%
% Add this object to figure's object list
%
if ~isfield(ud.Objects,'fdspec') | isempty(ud.Objects.fdspec)
    ud.Objects.fdspec = obj;
else
    ud.Objects.fdspec(end+1) = obj;
end
set(fig,'userdata',ud)
