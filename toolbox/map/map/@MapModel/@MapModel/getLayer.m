function layer = getLayer(this,name)
%GETLAYER Return a layer in the mapmodel.
%
%   GETLAYER(NAME) returns the layer NAME in the mapmodel.  

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:27 $

if isempty(strmatch(name,getLayerOrder(this)))  
  error('The layer %s does not exist in this map.',name);
end

for i=1:length(this.layers)
  names{i} = this.Layers(i).getLayerName;
end
I = strmatch(name,names,'exact');
layer = this.Layers(I);