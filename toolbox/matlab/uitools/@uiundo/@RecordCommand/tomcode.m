function [str] = tomcode(hThis)

% Copyright 2002 The MathWorks, Inc.

target = get(hThis,'Target');
obj = sprintf('h_%s',get(target(1),'type'));
prop = get(hThis,'TargetProperties');
prop = prop{1};
val = '...';
comment = get(hThis,'Name');

str = sprintf('set(%s,''%s'',%s); %% %s',obj,prop,val,comment);

