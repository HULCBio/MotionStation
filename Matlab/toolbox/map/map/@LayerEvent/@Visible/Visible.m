function h = Visible(hSrc,name,val)
%VISIBLE Event for setting Visible property.
%
%   VISIBLE(NAME,VAL) 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:20 $

h = LayerEvent.Visible(hSrc,'Visible');

h.Name = name;
h.val = val;