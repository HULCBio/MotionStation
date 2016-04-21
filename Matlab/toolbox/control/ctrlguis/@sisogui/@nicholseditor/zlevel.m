function zdata = zlevel(Editor, ObjectType, TargetSize)
%ZLEVEL  Generates Z data for Z layering of objects.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 05:05:40 $

% RE: Because text object throws away Z value when using 
%     normalized units, always set Z=0 for margintext

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

if nargin == 3
  zdata = repmat(zdata, TargetSize);
end
