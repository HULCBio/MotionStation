function h = ShowBoundingBox(hSrc,name,val)
%SHOWBOUNDINGBOX 
%
%   SHOWBOUNDINGBOX(NAME,VAL) 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:18 $

h = LayerEvent.ShowBoundingBox(hSrc,'ShowBoundingBox');

h.Name = name;
h.val = val;