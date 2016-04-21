function blkStruct = slblocks
%SLBLOCKS Defines the block library for a specific Toolbox or Blockset.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $

blkStruct.Name = sprintf('Neural\nNetwork\nBlockset');
blkStruct.OpenFcn = 'neural';
blkStruct.IsFlat  = 0;% Is this library "flat" (i.e. no subsystems)?

% blkStruct.MaskDisplay = '';

