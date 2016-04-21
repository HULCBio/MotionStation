function addlistener(hThis,hListener)

% Copyright 2003 The MathWorks, Inc.

l = get(hThis,'ExternalListeners');
set(hThis,'ExternalListener',[hListener;l]);