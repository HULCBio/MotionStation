function targetType = getTargetType_DSPtarget(modelName)
% Return user-specified target type (e.g., 'C6711DSK' or 'C6701EVM' etc)

% $RCSfile: getTargetType_DSPtarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/02/06 00:33:55 $
% Copyright 2001-2004 The MathWorks, Inc.

configSet = getActiveConfigSet(modelName);
targetType = get_param(configSet,'BoardType');

switch targetType
    case 'Custom_C6416',
        targetType = 'C6416DSK';
    case 'Custom_C6701',
        targetType = 'C6701EVM';
    case 'Custom_C6711',
        targetType = 'C6711DSK';
    case 'Custom_C6713',
        targetType = 'C6713DSK';
end

% [EOF] getTargetType_DSPtarget.m
