function dtype = p_Rxx_nativetypes(mm)
% Private. Used to display equivalent datatype
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:09:57 $

dtype = CheckForIrregularPropValues(mm);
if ~isempty(dtype)
    return;
end

if mm.wordsize==64 && strcmp(mm.represent,'float')
    dtype = 'double'; % 'long double'

elseif mm.wordsize==32 && strcmp(mm.represent,'float')
    dtype = 'float'; % 'single','float' 
       
elseif mm.wordsize==32 && strcmp(mm.represent,'signed')
    dtype = 'int'; %'signed int','int32','signed long'
    
elseif mm.wordsize==32 && strcmp(mm.represent,'unsigned')
    dtype = 'unsigned int'; % 'uint32', unsigned long'
    
elseif mm.wordsize==16 && strcmp(mm.represent,'signed')
    dtype = 'short'; % 'int16'
    
elseif mm.wordsize==16 && strcmp(mm.represent,'unsigned')
    dtype = 'unsigned short'; % 'uint16'
    
elseif mm.wordsize==8 && strcmp(mm.represent,'signed')
    dtype = 'signed char'; % 'signed char', 'int8'
    
elseif mm.wordsize==8 && strcmp(mm.represent,'unsigned')
    dtype = 'unsigned char'; % 'uint8'
    
elseif mm.wordsize==64 && strcmp(mm.represent,'signed')
    dtype = 'int64';
    
elseif mm.wordsize==64 && strcmp(mm.represent,'unsigned')
    dtype = 'uint64';
    
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
   (mm.prepad~=0 || mm.postpad~=0) ,
    dtype = 'Unknown';
else
    dtype = '';
end

% [EOF] p_Rxx_nativetypes.m