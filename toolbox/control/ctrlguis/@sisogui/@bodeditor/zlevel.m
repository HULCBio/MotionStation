function zdata = zlevel(Editor,ObjectType,TargetSize)
%ZLEVEL  Generates Z data for Z layering of objects.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 04:56:52 $

switch ObjectType
case 'constraint'
    zdata = -6;
case 'backgroundline'
    zdata = -5;
case 'curve'
    zdata = -4;
case 'system'
    zdata = -3;
case 'margin'
    zdata = -2;
case 'compensator'
    zdata = -1;
case 'margintext'
    zdata = 0;
end

if nargin==3
    zdata = repmat(zdata,TargetSize);
end
    
