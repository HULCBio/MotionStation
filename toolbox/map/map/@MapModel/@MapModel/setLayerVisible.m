function setLayerVisible(this,layername,val)
%SETLAYERVISIBLE Set Visible property
%
%   SETLAYERVISIBLE(LAYER,VALUE) sets the Visible property of LAYER to VALUE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:35 $

layer = this.getLayer(layername);

if islogical(val)
  if val
    val = 'On';
  else
    val = 'Off';
  end
end

layer.setVisible(val);
EventData = LayerEvent.Visible(this,layername,val);
this.send('Visible',EventData);
