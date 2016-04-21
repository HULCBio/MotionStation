function sv = checkerforlength(mm,usersSV)
%CHECKERFORLENGTH - private function to verify operations on property LENGTH

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.6.2 $  $Date: 2003/11/30 23:06:17 $

tempI = round(usersSV);
if any(strcmp(mm.procsubfamily,{'R1x','R2x','C6x'})), %C6x,Rxx
    if tempI>32
        error('Invalid size for a bitfield.');
    end
elseif any(strcmp(mm.procsubfamily,{'C54x','C55x','C28x'})), % C5000, C2800
    if tempI>16
        error('Invalid size for a bitfield.');
    end
end
sv = tempI;

% [EOF] checkerforlength.m