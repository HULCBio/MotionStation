function h = Polygon(name,varargin);
%POLYGON 
%
%  POLYGON(NAME,...) is a subclass of the HG patch object.  NAME is the name of
%  the Polygon object.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:44 $

defaultFaceColor = [0 0 1];
h = MapGraphics.Polygon(varargin{:},'FaceColor',defaultFaceColor);
h.LayerName = name;