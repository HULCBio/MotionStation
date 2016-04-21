function resp = UserDefinedTypes(typeobj)
% USERDEFINEDTYPES (Private) Returns a list of data type information from
% Code Composer(R) Studio. 

% Copyright 2003-2004 The MathWorks, Inc.

resp = callSwitchyard(typeobj.ccsversion,[53,typeobj.boardnum,typeobj.procnum,0,0],'type');        

% [EOF] UserDefinedTypes.m