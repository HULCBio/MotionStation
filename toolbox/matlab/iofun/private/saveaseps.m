function saveaseps( h, name )
%SAVEASEPS Save Figure to Encapsulated Postscript file with TIFF preview.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/06/17 13:25:13 $

print( h, name, '-deps', '-tiff' )
