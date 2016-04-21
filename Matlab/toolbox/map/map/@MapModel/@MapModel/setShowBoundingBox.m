function setShowBoundingBox(this,layername,val)
%SETSHOWBOUNDINGBOX Set ShowBoundingBox property
%
%   SETSHOWBOUNDINGBOX(LAYER,VALUE) sets the ShowBoundingBox property of
%   LAYER to VALUE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:36 $

layer = this.getLayer(layername);
layer.setShowBoundingBox(val);

EventData = LayerEvent.ShowBoundingBox(this,layername,val);
this.send('ShowBoundingBox',EventData);
