function staleFound = fixpt_clear_tag(SystemName);
% FIXPT_CLEAR_TAG(SystemName)
%
% Finds all blocks in the (sub)system that are linked to the 
% Fixed Point Blockset library.  For these blocks, the parameters named 
% Tag and AttributesFormatString may be modified.  
%     Fixed Point Blockset 2.0 put current information in these parameters
% each time a model was updated.  To increase speed, newer releases of
% Fixed Point Blockset do not set these parameters.  For models created using
% version 2.0, the information in Tag and AttributesFormatString will be 
% stale and possibly incorrect.  This script removes the stale information.
%     If one or more blocks was modified, the return value is true, otherwise
% the return value is false.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.6 $  
% $Date: 2002/04/10 18:58:20 $

staleFound = 0;

to_do = find_system(SystemName,'LookUnderMasks','all','AttributesFormatString','%<Tag>');

nblks = length(to_do);

for i=1:nblks

    try
        mn = get_param(to_do{i},'ReferenceBlock');
        
        if ~isempty(mn)
        
            if any(strcmp( strtok(mn,'/'),{fixptlibname,'fixpt_test_lib'} ))
                            
                set_param(to_do{i},'Tag','','AttributesFormatString','');
                
                staleFound = 1;
            end
        end
    catch
    end

end