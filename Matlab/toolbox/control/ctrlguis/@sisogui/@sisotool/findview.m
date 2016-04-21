function ViewHandle = findview(sisodb,ViewID)
%FINDVIEW  Finds handle of requested data view.
%
%   See also SISOTOOL.

%   Author: P. Gahinet  
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/10 04:59:53 $

% Clean up handles of deleted views 
sisodb.DataViews = sisodb.DataViews(ishandle(sisodb.DataViews),:);

% Determine if view already exists
ViewTags = get(sisodb.DataViews,'Tag');
ViewHandle = sisodb.DataViews(strcmpi(ViewTags,ViewID),:);
