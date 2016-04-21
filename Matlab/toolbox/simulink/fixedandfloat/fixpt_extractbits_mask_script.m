% fixpt_extractbits_mask_script.m
% Mask post-initialization code for Extract Bits block.
%
% This is a script NOT a function because direct access
% to mask parameters is desired.  In addition, it is
% desired to have parameters defined here be available
% to the masks underneath

% Copyright 1994-2003 The MathWorks, Inc.
% $Date: 2003/05/17 04:49:40 $ $Revision: 1.1.6.1 $

currBlock = gcb;

% Choices for bitsToExtract
UpperHalf = 1;
LowerHalf = 2;
N_MS_Bits = 3;
N_LS_Bits = 4;
Arb_Bits  = 5;

% Default Values
SlopeMult = 1;
SlopeAdd  = 0;

BiasMult = 1;
BiasAdd  = 0;

% Scaling of first conversion block should be
% based on inputs precision or inputs range?
% ie MS Bits or LS Bits
switch bitsToExtract
    case { UpperHalf, N_MS_Bits }
        % Output of first conversion block should have
        % same range as input, ie keep MS Bits
        curSlopeBase = 'PosRange1';
        
    otherwise
        % Output of first conversion block should have
        % same precision as input, ie keep LS Bits
        curSlopeBase = 'Slope1';
end

% The number of bits output by the first conversion block is
% 
%   NumBitsMult * NumBitsInput + NumBitsAdd
%
% by controlling the mult term and the add term we can
% get the desired number of bits.
switch bitsToExtract
    case { UpperHalf, LowerHalf }
        NumBitsMult = 0.5;
        NumBitsAdd  = 0;
        
    case { N_MS_Bits, N_LS_Bits }
        NumBitsMult = 0;
        NumBitsAdd  = numBits;
        
    otherwise
        NumBitsMult = 0;
        if (length(bitIdxRange) == 2)
            NumBitsAdd  = bitIdxRange(2) - bitIdxRange(1) + 1;
        else
            % Not sure what is right here
            NumBitsAdd = 1; % xxx
        end
end

% In 4 of the 5 cases, we want just the MS or just the LS bits.
% In the range case, we may be taking some middle bits.  The
% output scaling of the first conversion block needs to be
% adjusted in this case.  Suppose we want bits [ 3 10 ]
% then the slope of the conversion output should be
%
%  SlopeConvertOutput = 2^3 * SlopeConvertInput
%
% this is easy to do
%
switch bitsToExtract
    case Arb_Bits
        MiddleSlopeMultExp = bitIdxRange(1);
        
    otherwise
        MiddleSlopeMultExp = 0;
end

set_param([currBlock,'/DTProp1'],...
    'NumBitsMult',num2str(NumBitsMult),...
    'NumBitsAdd', num2str(NumBitsAdd),...
    'SlopeBase',curSlopeBase, ...
    'SlopeMult',  ['2^',num2str(MiddleSlopeMultExp)]);


%% handle modifications to scaling
%%
RetainRealWorld = 1;
IntegerOnly     = 2;

switch outScalingMode
    case RetainRealWorld
        set_param([currBlock,'/DTProp2'],...
            'PropScalingMode', 'Inherit via propagation rule', ...
            'PropScaling', '1', ...
            'SlopeMult', '1', ...
            'SlopeAdd',  '0', ...
            'BiasMult', '1', ...
            'BiasAdd',  '0' );
        
    otherwise
        % IntegerOnly
        set_param([currBlock,'/DTProp2'],...
            'PropScalingMode', 'Inherit via propagation rule', ...
            'PropScaling', '1', ...
            'SlopeMult', '0', ...
            'SlopeAdd',  '1', ...
            'BiasMult', '0', ...
            'BiasAdd',  '0' );
end

% [EOF] fixpt_extractbits_mask_script.m
