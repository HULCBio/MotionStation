function [ret] = dosupport(hThis,hTarget)

% Copyright 2004 The MathWorks, Inc.

% axes 
ret = isa(handle(hTarget),'hg.axes');
