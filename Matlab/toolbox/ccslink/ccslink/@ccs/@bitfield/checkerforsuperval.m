function sv = checkerforsuperval(nn,usersSV)
%CHECKERFORSUPERVAL - private function to verify operations on property STORAGEUNITSPERVALUE

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.6.2 $  $Date: 2003/11/30 23:06:23 $

if strcmp(nn.procsubfamily,'C6x')
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/8);
    if totalBytes > 8,
        error('''C6x memory bit sizes are limited to increments of 8 (8,16,24,...)');
        return;
    end
elseif strcmp(nn.procsubfamily,'C54x') 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/16);    
    if totalBytes > 2,
        error('''C54x memory bit sizes are limited to increments of 16 (16,32,...)');
        return;
    end
elseif strcmp(nn.procsubfamily,'C55x') 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/16);
    if totalBytes > 4,
        error('''C55x memory bit sizes are limited to increments of 16 (16,32,...)');
        return;
    end
elseif strcmp(nn.procsubfamily,'C28x') 
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/16);    
    if totalBytes > 2,
        error('''C28x memory bit sizes are limited to increments of 16 (16,32,...)');
        return;
    end
elseif any(strcmp(nn.procsubfamily,{'R1x','R2x'}))
    totalBytes = round((usersSV  * nn.bitsperstorageunit)/8);
    if totalBytes > 8,
        error('''Rxx memory bit sizes are limited to increments of 8 (8,16,24,...)');
        return;
    end
end

if totalBytes < 1,
    error('Numeric bit sizes are limited to byte increments (8,16,24,etc)');
    return;
end

sv = round(usersSV);
nn.wordsize = (sv  * nn.bitsperstorageunit);
nn.numberofstorageunits = sv*prod(nn.size);

