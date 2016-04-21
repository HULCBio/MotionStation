function recordtxt(h,TextType,Text)
%RECORDTXT  Records text into the @recorder object.

%   Author: P. Gahinet  
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:04 $

switch lower(TextType)
case 'history'
    h.EventRecorder.add2hist(Text);
case 'commands'
    
end