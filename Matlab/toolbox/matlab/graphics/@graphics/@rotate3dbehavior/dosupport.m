function [ret] = dosupport(hThis,hTarget)

% Copyright 2003 The MathWorks, Inc.

% axes 
ret = isa(handle(hTarget),'hg.axes');
