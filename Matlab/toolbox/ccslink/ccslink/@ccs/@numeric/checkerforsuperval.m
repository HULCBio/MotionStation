function sv = checkerforsuperval(nn,usersSV)
%CHECKERFORSUPERVAL - private function to verify operations on property STORAGEUNITSPERVALUE

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.8.6.3 $ $Date: 2004/04/08 20:46:36 $

if strcmp(nn.procsubfamily,'C6x')
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/8);
    if totalBytes > 8,
        error('C6x Memory bit sizes are limited to increments of 8 (8,16,24,...)');
        return;
    end
elseif strcmp(nn.procsubfamily,'C54x') 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/16);    
    if totalBytes > 2,
        error('C54x Memory bit sizes are limited to increments of 16 (16,32,...)');
        return;
    end
elseif strcmp(nn.procsubfamily,'C55x') 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/16);
    if totalBytes > 4,
        error('C55x Memory bit sizes are limited to increments of 16 (16,32,...)');
        return;
    end
elseif strcmp(nn.procsubfamily,'C28x') 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/16);    
    if totalBytes > 4,
        error('C28x Memory bit sizes are limited to increments of 16 (16,32,...)');
        return;
    end
elseif any(strcmp(nn.procsubfamily,{'R1x','R2x'})) 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/8);    
    if totalBytes > 8,
        error('Rxx Memory bit sizes are limited to increments of 8 (8,16,24,...)');
        return;
    end
end

if totalBytes < 1,
    error('Memory bit sizes are limited to byte increments (8,16,24,etc)');
    return;
end

sv = round(usersSV);
nn.wordsize = (sv  * nn.bitsperstorageunit) - nn.postpad - nn.prepad;
nn.numberofstorageunits = sv*prod(nn.size);

% [EOF] checkerforsuperval.m