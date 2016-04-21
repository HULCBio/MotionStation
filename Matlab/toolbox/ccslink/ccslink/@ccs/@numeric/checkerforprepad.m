function sv = checkerforprepad(mm,usersSV)
%CHECKERFORPREPAD - private function to verify operations on property PREPAD
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2004/04/08 20:46:34 $

tempI = round(usersSV);
if rem(tempI,8),
    error('PREPAD is limited to increments of 8 (byte boundaries - 0,8,16,...)');
    return;
end
mm.wordsize = (mm.storageunitspervalue  * mm.bitsperstorageunit) - mm.postpad - tempI;
sv = tempI;

% [EOF] checkerforprepad.m