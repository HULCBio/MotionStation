function [dtInfo]=dspblkconvcorr(action)
% DSPBLKCONVCORR Signal Processing Blockset Convolution/Correlation block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.4.2 $ $Date: 2004/04/12 23:06:10 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;

switch action
    
    case 'init'
        dtInfo = dspGetFixptDataTypeInfo(blk,15);
        
    case 'dynamic'
        curVis = get_param(blk,'maskvisibilities');
        [curVis,lastVis] = dspProcessFixptMaskParams(blk,curVis);
        if ~isequal(curVis,lastVis)
            set_param(blk,'maskvisibilities',curVis);
        end
end
