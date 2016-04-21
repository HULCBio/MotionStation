function dtype = p_c55x_nativetypes(mm)
% Private. Used to display equivalent datatype
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:11:35 $

dtype = CheckForIrregularPropValues(mm);
if ~isempty(dtype)
    return;
end

if mm.wordsize==32 && strcmp(mm.represent,'float')
    dtype = 'double'; % 'long double','float' 
    
elseif mm.wordsize==40 && strcmp(mm.represent,'signed') && mm.postpad==24
    dtype = 'long long';
    
elseif mm.wordsize==40 && strcmp(mm.represent,'unsigned') && mm.postpad==24
    dtype = 'unsigned long long';
    
elseif mm.wordsize==32 && strcmp(mm.represent,'signed')
    dtype = 'long';
    
elseif mm.wordsize==32 && strcmp(mm.represent,'unsigned')
    dtype = 'unsigned long';
    
elseif mm.wordsize==16 && strcmp(mm.represent,'unsigned')
    dtype = 'unsigned int'; % 'unsigned short','char','unsigned char','unsigned int','uint32','uint16'

elseif mm.wordsize==16 && strcmp(mm.represent,'signed')
    dtype = 'int'; % 'signed int','short','signed short','signed char','int16'
    
elseif mm.wordsize==16 && strcmp(mm.represent,'fract') && mm.binarypt==15  
    dtype = 'Q0.15';
    
elseif mm.wordsize==32 && strcmp(mm.represent,'fract') && mm.binarypt==31  
    dtype = 'Q0.31';

else
    dtype = 'Unknown';
end

%--------------------------------------
function dtype = CheckForIrregularPropValues(mm)
if (mm.binarypt~=0 && mm.binarypt~=15 && mm.binarypt~=31) || ...
    mm.prepad~=0 || (mm.postpad~=0 && mm.postpad~=24),
    dtype = 'Unknown';
else
    dtype = '';
end

% [EOF] p_c54x_nativetypes.m