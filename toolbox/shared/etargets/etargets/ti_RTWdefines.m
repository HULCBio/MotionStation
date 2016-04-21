function y = ti_RTWdefines(action,arg)
% This function is called from TLC to set RTW defines.

% $RCSfile: ti_RTWdefines.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:08:14 $
% Copyright 2001-2003 The MathWorks, Inc.

persistent local_storage

switch action
case 'set'
    local_storage = arg;
    y = 0;   
case 'get'
    y = local_storage;  
case 'add'  
    argfields = fieldnames(arg);
    for i=1:length(argfields), % add all arg's fields to local_storage
        local_storage.(argfields{i}) = getfield(arg, argfields{i});
    end  
    y = local_storage; 
case 'clear'
    clear local_storage
end
 
