function setstatus(figHandle, string)
%SETSTATUS Set status text string in figure.
%  SETSTATUS(FIGHANDLE, STRING) sets the 'String' property
%  of the uicontrol text object with 'Tag' equal to
%  'Status', if one exists.
%
%  SETSTATUS(STRING) is equivalent to SETSTATUS(gcf,
%  STRING). 
%
%  See also GETSTATUS.

%  Steven L. Eddins, 1 July 1994
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.15 $  $Date: 2002/04/15 03:25:19 $

error(nargchk(1,2,nargin));

if (nargin == 1)
  string = figHandle;
  figHandle = gcf;
end

statusBar = findobj(get(figHandle, 'Children'), 'flat', 'Tag', 'Status');
if (~isempty(statusBar))
  set(statusBar, 'String', string);
end
