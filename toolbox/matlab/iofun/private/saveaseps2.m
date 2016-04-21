function saveaseps2( h, name )
%SAVEASEPS2 Save Figure to Encapsulated Postscript file with TIFF preview.
%   Uses level 2 PostScript operators.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/06/17 13:25:14 $

print( h, name, '-deps2', '-tiff' )
