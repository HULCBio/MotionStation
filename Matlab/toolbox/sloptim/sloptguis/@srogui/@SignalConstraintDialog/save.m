function save(this,SaveIn,SaveAs,UpdateBlocks)
% Saves current project.
%   SAVE(PROJ)                           % initiated from save button
%   SAVE(PROJ,SAVEIN,SAVEAS,UPDATEBLKS)  % initiated from Save As... dialog

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:44:28 $
%   Copyright 1990-2004 The MathWorks, Inc.
if nargin<3
   SaveAs = get_param(this.Block,'SaveAs');
   if isempty(SaveAs)
      % Open Save As... dialog
      saveas(this)
      return
   end
   SaveIn = get_param(this.Block,'SaveIn');
   UpdateBlocks = true;
else
   SaveAs = strtrim(SaveAs);
end

% Save project data
% RE: Only idf specified target is not blank
if ~isempty(SaveAs)
   try
      save(this.Project,SaveIn,SaveAs)
   catch
      [junk,errmsg]=strtok(lasterr,sprintf('\n'));
      errordlg(errmsg,'Save Error','modal')
      return
   end
end

% Update SaveIn/SaveAs settings for all blocks in model
if UpdateBlocks
   % Find all blocks in model
   blks = find_system(bdroot(this.Block),...
      'FollowLinks','on','LookUnderMasks','all',...
      'RegExp','on','BlockType','SubSystem','LogID','SRO_DataLog_\d');
   for ct=1:length(blks)
      set_param(blks{ct},'SaveIn',SaveIn,'SaveAs',SaveAs)
   end
end
