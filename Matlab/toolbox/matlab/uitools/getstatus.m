function statusString = getstatus(figHandle)
%GETSTATUS Get status text string in figure.
%  STATUS = GETSTATUS(FIGHANDLE) returns the 'String'
%  property value of the uicontrol text object with 'Tag'
%  equal to 'Status'.  If such an object does not exist,
%  GETSTATUS returns [].
%
%  STATUS = GETSTATUS is equivalent to STRING =
%  GETSTATUS(gcf).
%
%  See also SETSTATUS.

%  Steven L. Eddins, October 1994
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.13 $  $Date: 2002/04/15 03:25:29 $

error(nargchk(0,1,nargin));

if (nargin == 0)
  figHandle = gcf;
end

statusBar = findobj(get(figHandle, 'Children'), 'flat', 'Tag', 'Status');
if (isempty(statusBar))
  statusString = [];
else
  statusString = get(statusBar(1), 'String');
end
