function isMutable = privateVerifyIsMutableEntry(typeName)
%PRIVATEISMUTABLEENTRY Is the user allowed to change this entry type.
% 

%   PE 10-01-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:01:20 $

isMutable = false;

if any(strcmp(typeName, {'DriverSession', 'HardwareAsset', 'LogicalName'}))
    isMutable = true;
end
