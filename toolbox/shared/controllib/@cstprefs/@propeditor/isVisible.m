function boo = isVisible(h)
%ISVISIBLE  True if Property Editor is visible.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:40 $
boo = h.Java.Frame.isVisible;