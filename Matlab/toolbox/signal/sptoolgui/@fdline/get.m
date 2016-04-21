function ans = get(obj,prop)
%GET Method for fdline object

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

obj = struct(obj);

if ~iscell(prop)
    prop = {prop};
end

prop = prop(:);
obj = obj(:);

ans = cell(length(obj),length(prop));
for i = 1:length(obj)
    for j = 1:length(prop)
        ans{i,j} = getprop(obj(i),prop{j});
    end
end

if all(size(ans)==1)
    ans = ans{:};
end


function val = getprop(obj,prop)
% get the value of a single property of a single object struct

switch prop

case {'xneedrender','yneedrender','delayrender',...
          'vertexdragmode','vertexdragcallback','vertexenddragcallback',...
          'segmentdragmode','segmentdragcallback','segmentenddragcallback', ...
          'segmentpointer','vertexpointer',...
          'buttondownfcn','buttonupfcn',...
          'userdata','help','affectlimits'}
    objud = get(obj.h,'userdata');
    val = eval(['objud.' prop]); %getfield(objud,prop);
case 'xdata'
    objud = get(obj.h,'userdata');
    if objud.xneedrender
        val = objud.xdata;
    else
        val = get(obj.h,'xdata');
    end
case 'ydata'
    objud = get(obj.h,'userdata');
    if objud.yneedrender
        val = objud.ydata;
    else
        val = get(obj.h,'ydata');
    end
case 'h'
    val = obj.h;
otherwise
    val = get(obj.h,prop);
end
