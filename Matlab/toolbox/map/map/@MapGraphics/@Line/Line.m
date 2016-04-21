function h = Line(name,varargin)
%LINE 
%
%  LINE(NAME,...) is a subclass of the HG Line object.  NAME is the name of
%  the line object.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:33 $

h = MapGraphics.Line(varargin{:});
h.LayerName = name;