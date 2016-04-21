function [dtInfo]=dspblkacf2(action)
% DSPBLKACF2 Signal Processing Blockset Autocorrelation block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.5.4.3 $ $Date: 2004/04/12 23:05:56 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;

switch action
    
    case 'init'
        dtInfo = dspGetFixptDataTypeInfo(blk,15);
        
    case 'dynamic'
        AllPositiveLags = get_param(blk,'AllPositiveLags');  
        mask_enables = get_param(blk,'maskenables');
        if strcmp(AllPositiveLags,'on'),
            mask_enables(2) = {'off'};
        else
            mask_enables(2) = {'on'};
        end
        set_param(blk,'maskenables',mask_enables);
    
        curVis = get_param(blk,'maskvisibilities');
        [curVis,lastVis] = dspProcessFixptMaskParams(blk,curVis);
        if ~isequal(curVis,lastVis)
            set_param(blk,'maskvisibilities',curVis);
        end
end
