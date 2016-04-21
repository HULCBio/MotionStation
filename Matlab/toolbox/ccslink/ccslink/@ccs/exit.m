function exit()

% Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/08 20:47:16 $

h = p_createCCSVersionObj;

if ispc
   callSwitchyard(h,[31,0,0,0,0]);
end

% [EOF] exit.m