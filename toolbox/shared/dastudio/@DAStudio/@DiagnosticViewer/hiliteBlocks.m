

%------------------------------------------------
function hilite_blocks_l(h, blockHandles),
%  HILITE_BLOCKS_L
%  This is the function that hilites the blocks
%  Copyright 1990-2004 The MathWorks, Inc.
  
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:36 $
  
% hilits the new one.
% Get this info from the h (handle of the diagnosticViewer)
%
%
% if the last block hilit was you, just return;
%
  hiliteH = blockHandles;
  
  %oldLastErr = lasterr;  % cache lasterr

  for bidx = 1:length(hiliteH)
      blockH = hiliteH(bidx);
      isABlock = strcmp(get_param(blockH, 'Type'),'block');
      
      % Set the hiliting of new error ON
      try,
          if isABlock
            if ~strcmp(get_param(blockH,'iotype'),'none')
              bd = bdroot(blockH);
              iomanager('Create',bd);
            else
              h.prevHilitObjs = [h.prevHilitObjs; blockH];
              color =  get_param(blockH,'HiliteAncestors');
              h.prevHilitClrs = [h.prevHilitClrs, {color}];
              hilite_system(blockH,'error');
            end;
          end;
      end;
  end

  % Restore lasterr
  %lasterr(oldLastErr);
  
%-----------------------------------------------------------------
 




