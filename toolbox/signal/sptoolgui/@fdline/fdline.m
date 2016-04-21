function obj = fdline(varargin)
%FDLINE  Constructor for filtdes line object
% Syntax:
%    obj = fdline('prop1',val1,'prop2',val2,...)  creates a new object
%    obj = fdline(objstruct) where objstruct is a structure array with a single
%             field named 'h' and the handle is to a valid object, simply calls
%             class(objstruct,'fdline').

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

if nargin>0 & isstruct(varargin{1}) & isequal(fieldnames(varargin{1}),{'h'})
    obj = class(varargin{1},'fdline');
    return
end

fig = findobj('type','figure','tag','filtdes');
ud = get(fig,'userdata');

% define default properties
objud.xdata = [0 1];
objud.ydata = [0 1];
objud.delayrender = 'off';
objud.xneedrender = 0;
objud.yneedrender = 0;
objud.vertexdragmode = {'none'};
objud.vertexdragcallback = {''};
objud.vertexenddragcallback = {''};
objud.segmentdragmode = {'none'};
objud.segmentdragcallback = {''};
objud.segmentenddragcallback = {''};
objud.buttondownfcn = '';
objud.buttonupfcn = '';
objud.affectlimits = 'on';
objud.help = {''};
objud.vertexpointer = {''};
objud.segmentpointer = {''};
objud.userdata = [];

% HP - handle properties structure
hp.parent = [];

for i=1:2:length(varargin)
    varargin{i} = lower(varargin{i});
    switch varargin{i}
    case {'delayrender' 'affectlimits'}
        objud = setfield(objud,varargin{i:i+1});
    case 'vertexdragmode'
        objud = setfield(objud,varargin{i:i+1});
    case 'vertexdragcallback'
        objud = setfield(objud,varargin{i:i+1});
    case 'vertexenddragcallback'
        objud = setfield(objud,varargin{i:i+1});
    case 'segmentdragmode'
        objud = setfield(objud,varargin{i:i+1});
    case 'segmentdragcallback'
        objud = setfield(objud,varargin{i:i+1});
    case 'segmentenddragcallback'
        objud = setfield(objud,varargin{i:i+1});
    case {'buttondownfcn','buttonupfcn'}
        objud = setfield(objud,varargin{i:i+1});
    case 'help'
        objud = setfield(objud,varargin{i:i+1});
    case 'vertexpointer'
        objud = setfield(objud,varargin{i:i+1});
    case 'segmentpointer'
        objud = setfield(objud,varargin{i:i+1});
    case 'userdata'
        objud = setfield(objud,varargin{i:i+1});
    otherwise
      % send to hg object
        hp = setfield(hp,varargin{i:i+1});
    end
    
end

hp.buttondownfcn = 'filtdes(''lineclick'',gcbo)';
if ~isfield(objud,'parent')
    % place in last axes object
    if length(ud.Objects.fdax)<1
        error('must create fdax axes object before fdline')
    else
        hp.parent = ud.Objects.fdax(end).h;
    end
end

obj.h = line(hp);
set(obj.h,'userdata',objud)

obj = class(obj,'fdline');
%
% Add this object to figure's object list
%
if ~isfield(ud.Objects,'fdline') | isempty(ud.Objects.fdline)
    ud.Objects.fdline = obj;
else
    ud.Objects.fdline(end+1) = obj;
end
set(fig,'userdata',ud)

