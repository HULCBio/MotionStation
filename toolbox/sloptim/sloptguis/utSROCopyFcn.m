function C = utSROCopyFcn(blk,Action)
% Update settings of copied SRO block.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:24 $
%   Copyright 1990-2004 The MathWorks, Inc.
Model = bdroot(blk);
SROBlocks = find_system(Model,'FollowLinks','on','LookUnderMasks','all',...
   'RegExp','on','BlockType','SubSystem','LogID','SRO_DataLog_\d');

% Get inherited constraint settings (to be applied to copied block)
BlockData = get_param(blk,'UserData');
if isfield(BlockData,'Project') && ishandle(BlockData.Project)
   LogID = get_param(blk,'LogID');
   C = findspec(BlockData.Project.Tests(1),LogID);
else
   C = [];
end

% Enforce unique LogID across model
LogID = get_param(SROBlocks,'LogID');
for ct=1:length(LogID)
   LogID{ct} = str2double(strrep(LogID{ct},'SRO_DataLog_',''));
end
LogID = cat(1,LogID{:});
if length(unique(LogID))<length(LogID)
   set_param(blk,'LogID',sprintf('SRO_DataLog_%d',max(LogID)+1))
end

% Align SaveIn/SaveAs settings with other blocks
if strcmp(Action,'copy')
   if isscalar(SROBlocks)
      % Copying to new model
      set_param(blk,'SaveAs','')
   else
      % Inherit from other blocks
      OtherBlks = setdiff(SROBlocks,blk);
      set_param(blk,...
         'SaveIn',get_param(OtherBlks{1},'SaveIn'),...
         'SaveAs',get_param(OtherBlks{1},'SaveAs'))
   end
end

   
