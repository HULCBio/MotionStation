%WINQUERYREG Get an item from the Microsoft Windows registry.
%   VALUE = WINQUERYREG(ROOTKEY, SUBKEY, VALNAME) 
%   returns the value of the specified key.
%
%   VALUE = WINQUERYREG(ROOTKEY, SUBKEY)
%   returns value that has no value name property.
% 
%   VALUE = WINQUERYREG('name',...)
%   returns the key names in ROOTKEY\SUBKEY in a cell array.
% 
%   Examples:
%
%       winqueryreg HKEY_CURRENT_USER Environment HOME
%       winqueryreg HKEY_CURRENT_USER Environment USER
%       winqueryreg HKEY_LOCAL_MACHINE SOFTWARE\Classes\.zip
%       winqueryreg HKEY_CURRENT_USER Environment path
%       winqueryreg name HKEY_CURRENT_USER Environment
%
%   
%   This function works only for the following registry
%   value types:
%
%      strings (REG_SZ)
%      expanded strings (REG_EXPAND_SZ)
%      32-bit integer (REG_DWORD)
%
%   If the specified value is a string, this function returns
%   a string. If the value is a 32-bit integer, this function
%   returns the value as an integer of MATLAB type int32. 
%
%   See also ACTXSERVER, REGISTEREVENT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $ $Date: 2004/04/16 22:09:04 $
%   Built-in function.

