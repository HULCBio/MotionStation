function ObjList=findall(HandleList,varargin);
%FINDALL find all objects.
%   ObjList=FINDALL(HandleList) returns the list of all objects 
%   beneath the Handles passed in.  FINDOBJ is used and all objects
%   including those with HandleVisibility set to 'off' are found.
%   FINDALL is called exactly as FINDOBJ is called.  For instance,
%   ObjList=findall(HandleList,Param1,Val1,Param2,Val2, ...).
%
%   For example, try:
%
%     plot(1:10)
%     xlabel xlab
%     a=findall(gcf)
%     b=findobj(gcf)
%     c=findall(b,'Type','text') % return the xlabel handle twice
%     d=findobj(b,'Type','text') % can't find the xlabel handle
%
%   See also ALLCHILD, FINDOBJ.

%   Loren Dean
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2002/04/15 03:25:43 $

if ~all(ishandle(HandleList)),
  error('Invalid handles passed to findall.')  
end  
Temp=get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
try
  ObjList=findobj(HandleList,varargin{:});
catch
  ObjList=-1;
end
set(0,'ShowHiddenHandles',Temp);
if isequal(ObjList,-1),
  error('Invalid Parameter-value pairs passed to findall.');
end
