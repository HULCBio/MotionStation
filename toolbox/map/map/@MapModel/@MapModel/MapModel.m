function h = MapModel(id)
%MAPMODEL Construct a mapmodel object.
%
%   H = MAPMODEL constructs a MapModel object.
%

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:24 $

h = MapModel.MapModel;
h.Configuration = {};
h.ViewerCount = [];
if nargin == 0
    h.ModelId = 0;
else
    h.ModelId = id;
end





