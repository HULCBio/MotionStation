function b = getShowBoundingBox(this)
%GETSHOWBOUNDINGBOX

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:15 $

b = this.ShowBoundingBox;

%if strcmp(lower(this.ShowBoundingBox),'on')
%  b = true;
%elseif strcmp(lower(this.ShowBoundingBox),'off')
%  b = false;
%end