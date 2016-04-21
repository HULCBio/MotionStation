function draw(this)
% DRAW does a layout of all the visible views and updates the responses of
% each view (visible or otherwise)

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/05/04 02:09:37 $

ActiveView = getCurrentViews(this);
for v=ActiveView'
    draw(v)
end