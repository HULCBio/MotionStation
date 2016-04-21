function name = unmangleFunctionName(h,name)
% SDK 2.2 new behavior - function names are coupled with parentheses '()'

% Copyright 2004 The MathWorks, Inc.

name = strrep(name,'()','');

% [EOF] unmangleFunctionName.m