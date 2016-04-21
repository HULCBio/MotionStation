
%-----------------------------------------------------------------
function  dehilite_previously_hilit_blocks(h),
%  DEHILITE_PREVIOUSLY_HILIT_BLOCKS
%  This function will dehilit all previously
%  hilited blocks
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 
 
%
  for bidx = 1:length(h.prevHilitObjs)
    blockH   = h.prevHilitObjs(bidx);
    blockClr = h.prevHilitClrs{bidx};
    if ishandle(blockH),
        try, set_param(blockH,'HiliteAncestors',blockClr); end;
    end;
  end
  h.prevHilitObjs = [];
  h.prevHilitClrs = {};

%------------------------------------------------------------------------------
 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:29 $
