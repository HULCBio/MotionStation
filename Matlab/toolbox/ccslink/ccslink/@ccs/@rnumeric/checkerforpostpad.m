function sv = checkerforpostpad(mm,usersSV)
%CHECKERFORPOSTPAD - private function to verify operations on property POSTPAD
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $ $Date: 2003/11/30 23:11:19 $

tempI = round(usersSV);
if rem(tempI,8),
    error('POSTPAD is limited to increments of 8 (byte boundaries - 0,8,16,...)');
    return;
end
mm.wordsize = (mm.storageunitspervalue  * mm.bitsperstorageunit) - mm.prepad - tempI;
sv = tempI;

% [EOF] checkerforpostpad.m