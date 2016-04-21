function deleteBlocks(blocksToDelete)
% DELETEBLOCKS  Deletes multiple blocks (in a for loop)

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:17 $

    for i=1:length(blocksToDelete)
        delete_block(blocksToDelete(i));
    end
