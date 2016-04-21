function count_fixpt = count_fixpt_blks(SystemName);
% COUNT_FIXPT_BLKS(SystemName)
%
% Counts all blocks in the (sub)system that are linked to the 
% Fixed Point Blockset library.  The search looks under masks
% and follows links, so this are included in the count.
%
%    See also FIND_SYSTEM, GET_PARAM

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.5 $  
% $Date: 2002/04/10 18:57:59 $

to_do = find_system(SystemName,'LookUnderMasks','all','FollowLinks','on');

count_fixpt = 0;

nblks = length(to_do);

for i=1:nblks

    try
        mn = get_param(to_do{i},'ReferenceBlock');
        
        if ~isempty(mn)
        
            if strcmp( strtok(mn,'/'),fixptlibname )
            
                count_fixpt = count_fixpt + 1;
                
            end
        end
    catch
    end

end
