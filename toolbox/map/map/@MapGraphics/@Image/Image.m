function h = Image(name,varargin)
%IMAGE 
%
%  IMAGE(NAME,...) is a subclass of the HG Image object.  NAME is the name of
%  the image object.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:31 $

h = MapGraphics.Image(varargin{:});
h.LayerName = name;