function zdata = zlevel(Editor,ObjectType,TargetSize)
%ZLEVEL  Generates Z data for Z layering of objects.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 04:58:23 $

switch ObjectType
case 'constraint'
    zdata = -2;
case 'backgroundline'
    zdata = -1;
case 'curve'
    zdata = 0;
case 'system'
    zdata = 1;
case 'compensator'
    zdata = 2;
case 'clpole'
    zdata = 3;
end

if nargin==3
    zdata = repmat(zdata,TargetSize);
end
    
