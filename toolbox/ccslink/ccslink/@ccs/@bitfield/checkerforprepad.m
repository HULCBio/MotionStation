function sv = checkerforprepad(mm,usersSV)
%CHECKERFORPREPAD - private function to verify operations on property PREPAD
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:06:20 $

tempI = round(usersSV);
% mm.wordsize = (mm.storageunitspervalue  * mm.bitsperstorageunit) - mm.postpad - tempI;
sv = tempI;

% [EOF] checkerforprepad.m