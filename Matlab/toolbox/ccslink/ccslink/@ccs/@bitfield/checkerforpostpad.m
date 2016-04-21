function sv = checkerforpostpad(mm,usersSV)
%CHECKERFORPOSTPAD - private function to verify operations on property POSTPAD
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:06:19 $

tempI = round(usersSV);
% mm.wordsize = (mm.storageunitspervalue  * mm.bitsperstorageunit) - mm.prepad - tempI;
sv = tempI;

% [EOF] checkerforpostpad.m