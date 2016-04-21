function saveasepsc( h, name )
%SAVEASEPSC Save Figure to color Encapsulated Postscript file with TIFF preview.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/06/17 13:25:16 $

print( h, name, '-depsc', '-tiff' )
