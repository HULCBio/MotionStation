function setCurrentViews(this,NewViewList,SilentFlag)
%SETCURRENTVIEWS  Brings up the specified view types.
%
%   SETCURRENTVIEWS(this,NewViews)
%   SETCURRENTVIEWS(this,NewViewTypes)
%
%   SETCURRENTVIEWS(this,...,'silent') leaves new plots with Visible=off
%   and does not notify clients of the configuration change.  This allows
%   for proper configuration of the response visibility prior to making the 
%   new plots visible.

%   Author(s): Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/05/04 02:09:43 $

if ischar(NewViewList)
   NewViewList = {NewViewList};
elseif length(NewViewList)>length(this.Views)
   error(sprintf('A maximum of %d views can be displayed.',length(this.Views)))
end
nviews = length(NewViewList);

% Construct new view list
NewViews = repmat(handle(NaN),size(this.Views));
if iscell(NewViewList)
   NewViewList = [NewViewList(:) ; repmat({'none'},length(this.Views)-nviews,1)];
   for ct=1:length(NewViewList)
      NewViews(ct) = this.switchView(ct,NewViewList{ct});
   end
else
   NewViews(1:nviews) = NewViewList;
end
this.Views = NewViews;
      
if nargin<3
   % Make specified views visible
   set(NewViews(1:nviews),'Visible','on')
   % Trigger layout update
   this.send('ConfigurationChanged')
end
