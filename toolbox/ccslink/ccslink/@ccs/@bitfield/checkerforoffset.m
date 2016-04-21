function sv = checkerforoffset(mm,usersSV)
%CHECKERFOROFFSET - private function to verify operations on property OFFSET

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.6.2 $  $Date: 2003/11/30 23:06:18 $

tempI = round(usersSV);
if tempI<0
    error('Bitfield offset cannot be negative.');
end
if any(strcmp(mm.procsubfamily,{'R1x','R2x','C6x'})), %C6x,Rxx
    if tempI>32
        error('The bitfield offset cannot be greater than an integer size.')
    end
elseif any(strcmp(mm.procsubfamily,{'C54x','C55x','C28x'})), % C5000, C2800
    if tempI>16
        error('The bitfield offset cannot be greater than an integer size.')
    end
end
sv = tempI;

% [EOF] checkerforoffset.m