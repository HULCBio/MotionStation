function h = render(this,layerName,legend,ax,visibility)
%RENDER Render the IntensityComponent.
%
%   H = RENDER(LAYERNAME,LEGEND,AX,VISIBILITY) renders all features
%   as an Intensity Image, into the axes AX, using the symbolization
%   defined in the legend, LEGEND, for the layer defined by LAYERNAME.
%   The image visibility is defined by VISIBILITY.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:07 $

R = this.ReferenceMatrix;
I = this.ImageData;
h = size(I,1);
w = size(I,2);
cc = pix2map(R,[1  1;...
                h  w]);

cdata = repmat(I,[1 1 3]);

h = MapGraphics.Image(layerName,...
                      'Parent',ax,'CData',cdata,...
                      'XData',cc(:,1),'YData',cc(:,2));

%[gridx,gridy] = meshgrid(linspace(cc(1,1),cc(2,1),w),...
%                         linspace(cc(1,2),cc(2,2),h));
%h = MapViewer.Surface(layer.getLayerName,...
%                      'Parent',ax,...
%                      'XData',gridx,...
%                      'YData',gridy,...
%                      'ZData',zeros([size(cdata,1),size(cdata,2)]),...
%                      'CData',cdata,...
%                      'LineStyle','none',...
%                      'FaceColor','texturemap');


set(h,'Visible',visibility);
