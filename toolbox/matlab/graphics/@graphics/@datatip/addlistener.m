function addlistener(hThis,hListener)

% Copyright 2002-2003 The MathWorks, Inc.

l = hThis.ExternalListenerHandles;
l = [hListener,l(:)'];
hThis.ExternalListenerHandles = l;
