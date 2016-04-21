function sv = checkerforpostpad(mm,usersSV)
%CHECKERFORPOSTPAD - private function to verify operations on property POSTPAD
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2004/04/08 20:46:33 $

tempI = round(usersSV);
if rem(tempI,8),
    error('POSTPAD is limited to increments of 8 (byte boundaries - 0,8,16,...)');
    return;
end
mm.wordsize = (mm.storageunitspervalue  * mm.bitsperstorageunit) - mm.prepad - tempI;
sv = tempI;

% [EOF] checkerforpostpad.m