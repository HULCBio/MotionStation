function [nativeTypeStr, slTypeId, mxTypeId] = ...

% Copyright 2003-2004 The MathWorks, Inc.

    HilBlkEquivNativeType( procFamily, typeInfo )
%HilBlkEquivNativeType:   
%
% Determine Simulink and MATLAB native types 
% equivalent to the specified attributes. 
%
% typeInfo must be a structure with fields
%    wordsize
%    represent 
%    binarypt
%    prepad
%    postpad

if ~(strcmp(procFamily,'c6xxx') | strcmp(procFamily,'c54xx') ...
    | strcmp(procFamily,'c55xx') | strcmp(procFamily,'c28xx')),
    error('Unsupported procFamily.  Need to update HilBlkEquivNativeType.m')
end

nativeTypeStr = getNativeTypeStr(procFamily, typeInfo);

[slTypeId, mxTypeId] = HilBlkGetTypeIds(nativeTypeStr);



% -----------------------------------------------
function nativeTypeStr = getNativeTypeStr(procFamily, typeInfo);
% This function contains specific data type mappings for the HIL Block.
% typeInfo contains the fields:
%    wordsize
%    represent 
%    binarypt
%    prepad
%    postpad
% We do not actually care what the TI chip family is at this point.
% We already know the word sizes and other characteristics, 
% and we simply need to know the equivalent MALTAB types.
% The only use for procFamily at this point is to catch unexpected
% cases.

if typeInfo.wordsize==64 && strcmp(typeInfo.represent,'float')
    switch procFamily
        case 'c6xxx',
            nativeTypeStr = 'double';
        case {'c54xx','c5500','c2800'},
            error('Unexpected 64-bit floating-point type on c5xxx or c2xxx.')
    end

elseif typeInfo.wordsize==32 && strcmp(typeInfo.represent,'float')
    nativeTypeStr = 'single'; 
    
elseif typeInfo.wordsize==32 && strcmp(typeInfo.represent,'signed')
    nativeTypeStr = 'int32'; 
    
elseif typeInfo.wordsize==32 && strcmp(typeInfo.represent,'unsigned')
    nativeTypeStr = 'uint32'; 
    
elseif typeInfo.wordsize==16 && strcmp(typeInfo.represent,'signed')
    nativeTypeStr = 'int16'; 
    
elseif typeInfo.wordsize==16 && strcmp(typeInfo.represent,'unsigned')
    nativeTypeStr = 'uint16';
    
elseif typeInfo.wordsize==8 && strcmp(typeInfo.represent,'signed')
    switch procFamily
        case 'c6xxx',
            nativeTypeStr = 'int8';
        case {'c54xx','c5500','c2800'},
            error('Unexpected 8-bit type on c5xxx or c2xxx')
    end
    
elseif typeInfo.wordsize==8 && strcmp(typeInfo.represent,'unsigned')
    switch procFamily
        case 'c6xxx',
            nativeTypeStr = 'uint8';
        case {'c54xx','c5500','c2800'},
            error('Unexpected 8-bit type on c5xxx or c2xxx.')
    end

% UNSUPPORTED CASES
    
% elseif typeInfo.wordsize==40 && strcmp(typeInfo.represent,'signed') ...
%     && typeInfo.postpad==24
%     nativeTypeStr = 'long'; % 'signed long'
%     
% elseif typeInfo.wordsize==40 && strcmp(typeInfo.represent,'unsigned') ...
%         && typeInfo.postpad==24
%     nativeTypeStr = 'unsigned long';
    
% elseif typeInfo.wordsize==64 && strcmp(typeInfo.represent,'signed')
%     nativeTypeStr = 'int64';
%     
% elseif typeInfo.wordsize==64 && strcmp(typeInfo.represent,'unsigned')
%     nativeTypeStr = 'uint64';
%     
% elseif typeInfo.wordsize==16 && strcmp(typeInfo.represent,'fract') ...
%         && typeInfo.binarypt==15
%     nativeTypeStr = 'Q0.15';
%     
% elseif typeInfo.wordsize==32 && strcmp(typeInfo.represent,'fract') ...
%         && typeInfo.binarypt==31  
%     nativeTypeStr = 'Q0.31';

else
    error(['The HIL Block does not support ' ...
        'these data type attributes:  ' sprintf('\n') ...
        '    wordsize:  ' num2str(typeInfo.wordsize) sprintf('\n') ...
        '    represent:  ' typeInfo.represent sprintf('\n') ...
        '    binarypt:  ' num2str(typeInfo.binarypt) sprintf('\n') ...
        '    prepad:  ' num2str(typeInfo.prepad) sprintf('\n') ...
        '    postpad:  ' num2str(typeInfo.postpad) sprintf('\n') ...
        'All C types used by the function must be equivalent ' ...
        'to a native Simulink data type: ' ...
        'int8, uint8, int16, uint16, int32, uint32, single, or ' ...
        'double.']);
end

