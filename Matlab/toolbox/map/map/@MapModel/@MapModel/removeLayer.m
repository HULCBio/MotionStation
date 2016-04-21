function removeLayer(this,name)
%REMOVELAYER Remove a layer from the model.
%
%   REMOVELAYER(NAME) Removes the layer NAME from the model.  The layer is also
%   removed from the configuration. A LayerRemoved event is broadcast.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:29 $

if isempty(strmatch(name,this.getLayerOrder))
  error('The layer %s does not exist in this map.',name);
end

% Remove the layer from the unordered array of layers and the configuration
removed = false;
i = 1;
idx = 1:length(this.Layers);
while removed == false
  if strmatch(name,this.layers(i).getLayerName,'exact');
    idx(i) = [];
    this.Layers = this.Layers(idx);
    % this.Layers(i) = []; % *** Doesn't work? ****
    Iordered = strmatch(name,getLayerOrder(this),'exact');
    this.Configuration(Iordered) = [];
    removed = true;
  end
  i = i + 1;
end

% Generate and broadcast an event that a layer has been removed.
EventData = LayerEvent.LayerRemoved(this,name);
this.send('LayerRemoved',EventData);


