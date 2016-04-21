function fixpt_set_all(SystemName,pName,pValue);
% FIXPT_SET_ALL Sets a property for every Fixed Point Block in a subsystem.
%
% Usage
%   FIXPT_SET_ALL( SystemName, fixptPropertyName, fixptPropertyValue )
%
% Example
%   FIXPT_SET_ALL( 'myModel/mySubsystem', 'RndMeth', 'Floor' )
%   FIXPT_SET_ALL( 'myModel/mySubsystem', 'DoSatur', 'on' )
% would set every fixed point block in the subsystem to use to floor rounding
% and to saturate on overflows.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.6 $  
% $Date: 2002/04/10 18:59:14 $

to_do = find_system(SystemName,'LookUnderMasks','all');

nblks = length(to_do);

for i=1:nblks

    try
        mn = get_param(to_do{i},'MaskNames');
        
        if ~isempty(mn)
        
            if any( strcmp(mn,pName) )
            
                set_param(to_do{i},pName,pValue)
                
            end
        end
    catch
    end
end