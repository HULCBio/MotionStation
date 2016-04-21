function saveaseps2c( h, name )
%SAVEASEPS2C Save Figure to color Encapsulated Postscript file with TIFF preview.
%   Uses level 2 PostScript operators.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/06/17 13:25:15 $

print( h, name, '-deps2c', '-tiff' )
