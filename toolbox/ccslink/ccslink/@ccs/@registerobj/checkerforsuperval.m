function sv = checkerforsuperval(mm,usersSV)
%CHECKERFORSUPERVAL - private function to verify operations on property STORAGEUNITSPERVALUE
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.6.3 $ $Date: 2004/01/22 18:19:04 $

if strcmp(mm.procsubfamily,'C6x')
    totalBytes = round((usersSV  * mm.bitsperstorageunit)/8);
    if totalBytes > 8,
        error('C6x Register values are limited to a maximum of 64 bits (8 bytes)');
        return;
    end
elseif strcmp(mm.procsubfamily,'C54x'),
    totalBytes = round((usersSV  * mm.bitsperstorageunit)/16);
    if totalBytes > 2,
        error('C54x Register values are limited to a maximum of 32 bits (2 bytes)');
        return;
    end
elseif strcmp(mm.procsubfamily,'C55x'),
    totalBytes = round((usersSV  * mm.bitsperstorageunit)/16);
    if totalBytes > 4,
        error('C55x Register values are limited to a maximum of 64 bits (4 bytes)');
        return;
    end

elseif strcmp(mm.procsubfamily,'C28x'),
    totalBytes = round((usersSV  * mm.bitsperstorageunit)/16);
    if totalBytes > 2,
        error('C28x Register values are limited to a maximum of 32 bits (2 bytes)');
        return;
    end
elseif any(strcmp(mm.procsubfamily,{'R1x','R2x'}))
    totalBytes = round((usersSV  * mm.bitsperstorageunit)/8);
    if totalBytes > 8,
        error('Rxx Register values are limited to a maximum of 64 bits (8 bytes)');
        return;
    end
    if totalBytes < 1,
        error('Register bit sizes are limited to byte increments (8,16,24,etc)');
        return;
    end
end

sv = round(usersSV);
mm.wordsize = (sv  * mm.bitsperstorageunit) - mm.postpad - mm.prepad;

% [EOF] checkerforsuperval.m
