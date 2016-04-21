function [ret] = dosupport(hThis,hTarget)

% axes 
ret = isa(handle(hTarget),'hg.axes');
