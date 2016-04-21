function varargout = fixpt_extractbits_mask(action)
% fixpt_extractbits_mask.m - Mask helper function for Extract Bits block

% Copyright 1994-2003 The MathWorks, Inc.
% $Date: 2003/05/17 04:49:39 $ $Revision: 1.1.6.1 $

if nargin==0, action = 'dynamic'; end
switch action
    case 'icon'
        varargout(1) = {getIconString(gcb)};
        
    case 'dynamic'
        handleDynamicDialogs(gcb);
        varargout = [];
        
    otherwise
        errordlg('fixpt_extractbits_mask: Invalid mask helper function argument.');
end

%-------------------------------------------------------------------------
function str = getIconString(currBlock)
% Upper half
% Lower half
% Range starting with most significant bit
% Range ending with least significant bit
% Range of bits
extBitsSpecStr = get_param(currBlock,'bitsToExtract');

% Determine Icon String
switch extBitsSpecStr
    case 'Upper half'
        str = 'Extract Bits\nUpper Half';
        
    case 'Lower half'
        str = 'Extract Bits\nLower Half';
        
    case 'Range starting with most significant bit'
        numBitsStr     = num2str(get_param(currBlock,'numBits'));
        str = ['Extract ' numBitsStr ' Bits\nUpper End'];
        
    case 'Range ending with least significant bit'
        numBitsStr     = num2str(get_param(currBlock,'numBits'));
        str = ['Extract ' numBitsStr ' Bits\nLower End'];
        
    otherwise
        % Range of bits
        bitIdxRngNum = str2num(get_param(currBlock,'bitIdxRange'));
        if (length(bitIdxRngNum) == 2)
            bitIdx1Str   = num2str(bitIdxRngNum(1));
            bitIdx2Str   = num2str(bitIdxRngNum(2));
            bitIdxStr    = ['[' bitIdx1Str ' ' bitIdx2Str ']'];
            str = strcat('Extract Bits\n',bitIdxStr);
        elseif (length(bitIdxRngNum) == 1)
            bitIdxStr = num2str(get_param(currBlock,'bitIdxRange'));
            str = ['Extract Bit ' bitIdxStr];
        else
            str = 'Extract Bits';
        end
end

%-------------------------------------------------------------------------
function handleDynamicDialogs(currBlock)
old_vis        = get_param(currBlock,'MaskVisibilities');
new_vis        = old_vis;  % cache current visibilities
extBitsSpecStr = get_param(currBlock,'bitsToExtract');

% Mapping of mask-values to mask parameters:
% mask_vals{1}  -> specification type popup
% mask_vals{2}  -> number of bits
% mask_vals{3}  -> bit indices
new_vis(1) = {'on'};
new_vis(2) = {'off'};
new_vis(3) = {'off'};
new_vis(4) = {'on'};

if strcmp(extBitsSpecStr,'Range of bits')
    new_vis(3) = {'on'};
elseif ~( strcmp(extBitsSpecStr,'Upper half') || strcmp(extBitsSpecStr,'Lower half') )
    new_vis(2) = {'on'};
end

if ~isequal(old_vis,new_vis)
    set_param(currBlock,'MaskVisibilities',new_vis);
end

% [EOF] fixpt_extractbits_mask.m
