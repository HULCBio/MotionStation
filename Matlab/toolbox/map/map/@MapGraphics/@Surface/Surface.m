function h = Surface(name,varargin)
% SURFACE Constructor for the SURFACE object subclassed from
%   the HG surface object.
%   NAME is the name of the layer on which the surface object
%   lies.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:55:58 $

h = MapGraphics.Surface(varargin{:});
h.LayerName = name;

