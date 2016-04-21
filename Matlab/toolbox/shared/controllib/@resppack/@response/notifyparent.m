function notifyparent(this,ViewChangedEvent)
%NOTIFYPARENT  Broadcasts ViewChanged event to axes grid.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:25 $

this.Parent.AxesGrid.send(ViewChangedEvent);