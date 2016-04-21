function gpzoom(obj, light, medium, dark, black),
%GPZOOM( OBJ, LIGHT, MEDIUM, DARK, BLACK )

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:58:16 $

bmp = get(obj,'cdata');
bmp(light)  = 2;
bmp(medium) = 3;
bmp(dark)   = 4;
bmp(black)  = 0;
set(obj,'cdata',bmp);

