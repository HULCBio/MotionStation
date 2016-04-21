function [slTypeId, mxTypeId] = HilBlkGetTypeIds(nativeTypeStr)

% Simulink type ID enumeration
% (See simulink/src/include/simstruc_types.h)
% 	SS_DOUBLE  = 0
% 	SS_SINGLE  = 1
% 	SS_INT8    = 2
% 	SS_UINT8   = 3
% 	SS_INT16   = 4
% 	SS_UINT16  = 5
% 	SS_INT32   = 6
% 	SS_UINT32  = 7
% 	SS_BOOLEAN = 8
% MATLAB (mxArray) class enumeration
% (See src/include/matrix.h)
%   mxUNKNOWN_CLASS  = 0
% 	mxCELL_CLASS     = 1
% 	mxSTRUCT_CLASS   = 2
% 	mxLOGICAL_CLASS  = 3
% 	mxCHAR_CLASS     = 4
% 	mxSPARSE_CLASS   = 5
% 	mxDOUBLE_CLASS   = 6
% 	mxSINGLE_CLASS   = 7
% 	mxINT8_CLASS     = 8
% 	mxUINT8_CLASS    = 9
% 	mxINT16_CLASS    = 10
% 	mxUINT16_CLASS   = 11
% 	mxINT32_CLASS    = 12
% 	mxUINT32_CLASS   = 13
% 	mxINT64_CLASS    = 14
% 	mxUINT64_CLASS   = 15
% 	mxFUNCTION_CLASS = 16
% 	mxOPAQUE_CLASS   = 17
% 	mxOBJECT_CLASS   = 18

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:43 $

switch nativeTypeStr,
    case 'double',
        slTypeId = 0;
        mxTypeId = 6;
    case 'single',
        slTypeId = 1;
        mxTypeId = 7;
    case 'int8',
        slTypeId = 2;
        mxTypeId = 8;
    case 'uint8',
        slTypeId = 3;
        mxTypeId = 9;
    case 'int16',
        slTypeId = 4;
        mxTypeId = 10;
    case 'uint16',
        slTypeId = 5;
        mxTypeId = 11;
    case 'int32',
        slTypeId = 6;
        mxTypeId = 12;
    case 'uint32',
        slTypeId = 7;
        mxTypeId = 13;
    case 'boolean',
        slTypeId = 8;
        mxTypeId = 3;
    otherwise,
        error('Unrecognized type')
end        

slTypeId = int32(slTypeId);
mxTypeId = int32(mxTypeId);
