function setShowBoundingBox(this,b)
%SETSHOWBOUNDINGBOX Set ShowBoundingBox property
%

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:23 $

if islogical(b)
  if b
    b = 'On';
  else
    b = 'Off';
  end
end

this.ShowBoundingBox = b;

