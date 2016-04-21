function name = getLayerName(this)
%GETLAYERNAME Get the name of the layer.
%
%   NAME = GETLAYERNAME returns a string with the name of the layer.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:14 $

name = this.LayerName;

%name = cell(1,length(this));
%for i=1:length(this)
%  name(i) = {this.LayerName};
%end



