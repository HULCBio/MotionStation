function h = Text(name,varargin)
%TEXT 
%
%  TEXT(NAME,...) is a subclass of the HG Text object.  NAME is the name of
%  the text object.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:48 $

h = MapGraphics.Text(varargin{:});
h.LayerName = name;
