function dtype = p_c28x_nativetypes(mm)
% Private. Used to display equivalent datatype
% Copyright 2003 The MathWorks, Inc.

dtype = CheckForIrregularPropValues(mm);
if ~isempty(dtype)
    return;
end

if mm.wordsize==32 && strcmp(mm.represent,'float')
    dtype = 'double'; % 'long double','float' 
    
elseif mm.wordsize==32 && strcmp(mm.represent,'signed')
    dtype = 'long'; % 'signed long'
    
elseif mm.wordsize==16 && strcmp(mm.represent,'signed')
    dtype = 'int'; %'signed int','short','signed short','signed char','int16'
    
elseif mm.wordsize==32 && strcmp(mm.represent,'unsigned')
    dtype = 'unsigned long'; % 'int32'
    
elseif mm.wordsize==16 && strcmp(mm.represent,'unsigned')
    dtype = 'unsigned int'; % 'unsigned short','char','unsigned char','uint32','uint16'

elseif mm.wordsize==16 && strcmp(mm.represent,'fract') && mm.binarypt==15  
    dtype = 'Q0.15';
    
elseif mm.wordsize==32 && strcmp(mm.represent,'fract') && mm.binarypt==31  
    dtype = 'Q0.31';

else
    dtype = 'Unknown';
    % error('Datatype does not match any defined C28x type.');
end

%--------------------------------------
function dtype = CheckForIrregularPropValues(mm)
if (mm.binarypt~=0 && mm.binarypt~=15 && mm.binarypt~=31) || ...
    mm.prepad~=0 || (mm.postpad~=0 && mm.postpad~=24),
    dtype = 'Unknown';
else
    dtype = '';
end

% [EOF] p_c28x_nativetypes.m