function state = btnstate(figHandle, groupId, buttonId, arg4)
%BTNSTATE Query state of toolbar button group.
%  STATE = BTNSTATE(FIGHANDLE, GROUPID, BUTTONID) returns
%  the state of the button specified by the string BUTTONID
%  in the button group specified by the string GROUPID in
%  the figure FIGHANDLE.  STATE = 1 indicates that the
%  button is down.  STATE = 0 indicates that the button is
%  up.
%
%  STATE = BTNSTATE(FIGHANDLE, GROUPID, BUTTONNUM) returns
%  the state of the button specified by the scalar
%  BUTTONNUM.  Button numbers go down the columns of the
%  button group.
%
%  STATE = BTNSTATE(FIGHANDLE, GROUPID) returns a state
%  vector containing the state of all the buttons in the
%  button group.
%
%  BTNSTATE('set', FIGHANDLE, GROUPID, STATE) sets the state
%  of the specified button group according to values on the
%  STATE vector.
%
%  See also BTNGROUP, BTNPRESS, BTNDOWN, BTNUP, BTNRESIZE.

%  Steven L. Eddins, 29 June 1994
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.20 $  $Date: 2002/04/15 03:25:47 $

oldHiddenHandle = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

if (isstr(figHandle))
  % Set state
  
  stateVector = arg4(:);
  figHandle = groupId;
  groupId = buttonId;
  
  axesHandle = findobj(get(figHandle, 'children'), 'flat', ...
      'type', 'axes', 'Tag', groupId);
  axesHandle = axesHandle(1);
  
  ud = get(axesHandle,'UserData');
  oldStateVector = ud.state;
  changes = stateVector - oldStateVector;
  upChanges = find(changes == -1);
  downChanges = find(changes == 1);
  for k = 1:length(downChanges)
    btndown(figHandle, groupId, downChanges(k));
  end
  for k = 1:length(upChanges)
    btnup(figHandle, groupId, upChanges(k));
  end
  
else
  % Query state
  
  axesHandle = findobj(get(figHandle, 'children'), 'flat', ...
      'type', 'axes', 'Tag', groupId);
  axesHandle = axesHandle(1);
  
  ud = get(axesHandle,'UserData');
  stateVector = ud.state;
  if (nargin == 2)
    % BTNSTATE(FIGHANDLE, GROUPID)
    state = stateVector;
  else
    state = [];
    if (isstr(buttonId))
      % BTNSTATE(FIGHANDLE, GROUPID, BUTTONID)
      buttons = ud.buttonId;
      for k = 1:size(buttons,1)
          temp = buttons(k,:);
          temp(temp==' ' | temp==0) = []; % deblank short-cut
          if (strcmp(buttonId, temp))
              state = stateVector(k);
              break;
          end
      end
    else
      % BTNSTATE(FIGHANDLE, GROUPID, BUTTONNUM)
      state = stateVector(buttonId);
    end
  end
  
end

set(0, 'ShowHiddenHandles', oldHiddenHandle);
