function renderLayer(this,ax,layername)
%RENDERLAYER Render one layer in the model
%
%   H = RENDERLAYER(AX,LAYERNAME) renders the layer LAYERNAME into the axes
%   AX. 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:31 $

for i=1:length(this.Layers)
  names{i} = this.Layers(i).getLayerName;
end
I = strmatch(layername,names,'exact');
if isempty(I)
  error('A layer named %s does not exist in this model.',layername);
end
this.Layers(I).render(ax);



