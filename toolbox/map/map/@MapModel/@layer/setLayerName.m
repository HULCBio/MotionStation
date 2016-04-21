function setLayerName(this,name)
%SETLAYERNAME Sets the name of the layer.
%
%   SETLAYERNAME(NAME) changes the name of the layer to NAME.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:49:24 $

this.LayerName = name;

%name = cell(1,length(this));
%for i=1:length(this)
%  name(i) = {this.LayerName};
%end
