function btnup(figHandle, groupId, buttonId)
%BTNUP  Raise button in toolbar button group.
%  BTNUP(FIGHANDLE, GROUPID, BUTTONID) raises the button
%  specified by the string BUTTONID in the button group
%  specified by the string GROUPID in figure FIGHANDLE.  
%
%  BTNUP(FIGHANDLE, GROUPID, BUTTONNUM) raises the button
%  numbered BUTTONNUM.  Buttons are numbered down the
%  columns of the button group.
%
%  See also BTNGROUP, BTNSTATE, BTNPRESS, BTNDOWN, BTNRESIZE.

%  Steven L. Eddins, 29 June 1994
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.25 $  $Date: 2002/04/15 03:24:19 $


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
  buttonId(buttonId ==' ' | buttonId==0) = []; % Deblank
end

if ~isempty(ud.uicontrolButtons)  % in uicontrol mode
  set(ud.uicontrolButtons(buttonNumber),'value',0)
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

  set(ulLine, 'FaceColor', bevelLight);
  set(lrLine, 'FaceColor', bevelDark);
  %set(downBorder, 'FaceColor', buttonColor);
end

ud.state(buttonNumber) = 0;
set(axesHandle, 'UserData', ud);

set(0, 'ShowHiddenHandles', oldHiddenHandle);
