function btndown(figHandle, groupId, buttonId)
%BTNDOWN Depress button in toolbar button group.
%  BTNDOWN(FIGHANDLE, GROUPID, BUTTONID) depresses the
%  button specified by the string BUTTONID in the button
%  group specified by the string GROUPID in figure
%  FIGHANDLE.
%
%  BTNUP(FIGHANDLE, GROUPID, BUTTONNUM) depresses the button
%  numbered BUTTONNUM.  Buttons are numbered down the
%  columns of the button group.
%
%  See also BTNGROUP, BTNSTATE, BTNPRESS, BTNUP, BTNRESIZE.

%  Steven L. Eddins, 29 June 1994
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.27 $  $Date: 2002/04/15 03:26:19 $

oldHiddenHandle = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

axesHandle = findobj(get(figHandle, 'children'), 'flat', ...
    'Tag', groupId);
axesHandle = axesHandle(1);
ud = get(axesHandle,'userdata');
  
if (isstr(buttonId))
  % Determine the button number.
  buttons = ud.buttonId;
  for k = 1:size(buttons,1)
    temp = buttons(k,:);
    temp(temp==' ' | temp==0) = []; % deblank
    if (strcmp(temp, buttonId))
      buttonNumber = k;
      break;
    end
  end
else
  buttonNumber = buttonId;
  % Determine the button ID.
  buttons = ud.buttonId;
  buttonId = buttons(buttonNumber,:);
  buttonId(buttonId==' ' | buttonId==0) = []; % Deblank
end

if ~isempty(ud.uicontrolButtons)  % in uicontrol mode
  set(ud.uicontrolButtons(buttonNumber),'value',1)
else % in axes mode
  colorSet = getuprop(axesHandle, 'Colors');
  buttonColor = colorSet(1,:);
  buttonColorDark = colorSet(2,:);
  bevelLight = colorSet(3,:);
  bevelDark = colorSet(4,:);

  buttonObjects = findobj(axesHandle, 'Tag', buttonId);
  ulLine = findobj(buttonObjects, 'flat', 'UserData', 'ULBorder');
  lrLine = findobj(buttonObjects, 'flat', 'UserData', 'LRBorder');
  downBorder = findobj(buttonObjects, 'flat', 'UserData', 'DownBorder');

  set(ulLine, 'FaceColor', bevelDark);
  set(lrLine, 'FaceColor', bevelLight);
  %set(downBorder, 'FaceColor', buttonColorDark);
end

ud.state(buttonNumber) = 1;
set(axesHandle, 'UserData', ud);

set(0, 'ShowHiddenHandles', oldHiddenHandle);
