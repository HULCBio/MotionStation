function BlockInfo = getSelectedBlockInfo(this,idx);
%getSelectedBlockInfo

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

BlockInfo = javaArray('java.lang.Object',1);
BlockInfo(1) = java(this.Blocks(idx+1));

%% Flash Highlight the block
% count = 0.1;
% hilite_system(this.Blocks(idx+1).FullBlockName,'find')
% pause(count)
% hilite_system(this.Blocks(idx+1).FullBlockName,'none')
% pause(count)
% hilite_system(this.Blocks(idx+1).FullBlockName,'find')
% pause(count)
% hilite_system(this.Blocks(idx+1).FullBlockName,'none')
% pause(count)
% hilite_system(this.Blocks(idx+1).FullBlockName,'find')
% pause(count)
% hilite_system(this.Blocks(idx+1).FullBlockName,'none')
% pause(count)