function iduivis(handles,onoff)
%IDUIVIS Sets the visibility ONOFF for the valid handles in the list HANDLES.

%   L. Ljung 9-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2001/04/06 14:22:41 $

hand=handles(:);
z=hand(find(ishandle(hand)));
for kh=z'
   
      set(kh,'vis',onoff);
      
end