function addModel(this,model)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:56:08 $

this.Model = model;

% Install Listeners
this.Listeners = [this.Listeners(:);...
                  handle.listener(model,'LayerAdded',{@newlayer model this});...
                  handle.listener(model,'LayerRemoved',{@removelayer this});...
                  handle.listener(model,'LayerOrderChanged',{@layerorderchanged this});...
                  handle.listener(model,'LegendChanged',{@legendchanged this});...
                  handle.listener(model,'ShowBoundingBox',{@showBoundingBox this});...
                  handle.listener(model,'Visible',{@setVisible this})
                 ];

% Render the graphics in the model
model.render(this);

%-------------------------------------------------------------------------
function h = createComponentListener(layer,model,hMapViewer)
componentProp = findprop(layer,'Components');
h = handle.listener(layer,componentProp,...
                    'PropertyPostSet',{@newcomponent model hMapViewer});

%-------------------------------------------------------------------------%
function reorderChildren(hMapViewer,layerorder)
newChildren = [];
for i=1:length(layerorder)
  newChildren = [newChildren; hMapViewer.getLayerHandles([layerorder{i} '_BoundingBox']);...
                 hMapViewer.getLayerHandles(layerorder{i})];
end
set(hMapViewer,'Children',newChildren);
refresh(get(hMapViewer,'Parent'))

%%%%%%%%%%%%%%%%%%%LISTENERS%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------------------------------%
function setVisible(src,eventData,hMapViewer)
set(hMapViewer.getLayerHandles(eventData.Name),...
    'Visible',eventData.Value);

%-------------------------------------------------------------------------%
function showBoundingBox(src,eventData,hMapViewer)
delete(hMapViewer.getLayerHandles([eventData.Name '_BoundingBox']));
hMapViewer.Model.getLayer(eventData.Name).renderBoundingBox(hMapViewer);


%-------------------------------------------------------------------------%
function layerorderchanged(src,eventData,hMapViewer)
reorderChildren(hMapViewer,eventData.layerorder);

%-------------------------------------------------------------------------%
function removelayer(src,eventData,hMapViewer)
% Remove Layer
delete(hMapViewer.getLayerHandles(eventData.LayerName));
% Remove Bounding Box
delete(hMapViewer.getLayerHandles([eventData.LayerName '_BoundingBox']))

%-------------------------------------------------------------------------%
function newlayer(src,eventData,model,hMapViewer)
% Update graphics when a layer is added or removed
layername = eventData.LayerName;
model.renderLayer(hMapViewer,layername);
% Add a listener to the new layer's component property
hMapViewer.ComponentListener= createComponentListener(model.getLayer(layername),model,hMapViewer);
%-------------------------------------------------------------------------%
function legendchanged(src,eventData,this)
layer = eventData.layer;
legend = layer.Legend;
handles = this.getLayerHandles(layer.getLayerName);
for i=1:length(handles)
  % Make a "fake" feature using the real feature's attributes
  tmpfeature.Attributes = handles(i).Attributes;
  try
    props = legend.getGraphicsProperties(tmpfeature);
    set(double(handles(i)),props);
  end
end

%-------------------------------------------------------------------------%
function newcomponent(src,eventData,model,hMapViewer)
% Update graphics when a new component is added to a layer
layer = eventData.AffectedObject;
component = eventData.NewValue(end,:);
model.renderComponent(hMapViewer,layer,component);
reorderChildren(hMapViewer,model.getLayerOrder);

