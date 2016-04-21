function CurrentViews = getCurrentViews(this,Request)
%GETCURRENTVIEWS  Get type of currently active views.
%
%   Views = GETCURRENTVIEWS(this,'Handle')
%   ViewTypes = GETCURRENTVIEWS(this,'Type')

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1 $  $Date: 2002/05/03 01:09:03 $
ViewHandles = find(this.Views(ishandle(this.Views)),'Visible','on');
if nargin==1 || strcmpi(Request,'handle')
   CurrentViews = ViewHandles;
else
   CurrentViews = get(ViewHandles,{'Tag'});
end