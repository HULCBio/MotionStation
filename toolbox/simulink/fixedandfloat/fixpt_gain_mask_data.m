function out = fixpt_gain_mask_data(curBlock,doX);
% FIXPT_GAIN_MASK_DATA is a helper function used by the Fixed Point Blocks.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.7 $  
% $Date: 2002/04/10 18:58:32 $

block_orient = get_param(curBlock,'Orientation');
if strcmp(block_orient,'right')
   xx = [0 0 1   0];
   yy = [0 1 0.5 0];
elseif strcmp(block_orient,'left')
   xx = [1 1 0   1];
   yy = [0 1 0.5 0];
elseif strcmp(block_orient,'up')
   xx = [0 1 0.5 0];
   yy = [0 0 1   0];
else
   xx = [0 1 0.5 0];
   yy = [1 1 0   1];
end

if doX
    out = xx;
else
    out = yy;
end
