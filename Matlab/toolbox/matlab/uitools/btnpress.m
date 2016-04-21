function btnpress(figHandle, groupId, buttonId, a4,a5,a6,a7,a8,a9,a10)
%BTNPRESS Button press manager for toolbar button group.
%  All objects that make up a toolbar button group have a
%  ButtonDownFcn that calls BTNPRESS.  BTNPRESS is
%  responsible for doing the right thing based on the
%  'PressType' property of the button and the 'Exclusive'
%  property of the button group.  BTNPRESS calls BTNDOWN and
%  BTNUP to do the actual work of changing button
%  appearances.
%
%  BTNPRESS may also be used from the command line to
%  simulate a button press with the following calls:
%  BTNPRESS(FIGHANDLE, GROUPID, BUTTONID)
%  BTNPRESS(FIGHANDLE, GROUPID, BUTTONNUM)
%
%  See also BTNGROUP, BTNSTATE, BTNUP, BTNDOWN, BTNRESIZE.

%  Steven L. Eddins, 29 June 1994
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.31 $  $Date: 2002/04/15 03:25:15 $

% Get all the information we need about which button was pressed
% and the properties of the button/button group.


if (nargin == 0)
  % BTNPRESS
  % Get button press information from the current object.
  currentObject = gcbo;
  currentObjectType = get(currentObject, 'Type');
  if strcmp(currentObjectType,'uicontrol') % uicontrol mode of operation
    % T. Krauss, 6/27/99
    axesHandle = get(gcbo,'userdata');
    ud = get(axesHandle,'userdata');
    buttonNumber = find(gcbo==ud.uicontrolButtons);
    uicontrolModeBtnPress(axesHandle,ud,buttonNumber)
    return

  elseif (~all(currentObjectType(1:2) == 'ax'))
    buttonNumber = get(currentObject, 'UserData');
    buttonId = get(currentObject, 'Tag');
    axesHandle = get(currentObject, 'Parent');
  else
    % User clicked on the axes.  We've got to do extra work to
    % figure out which button has been pressed.
    axesHandle = currentObject;
    currentPoint = get(axesHandle, 'CurrentPoint');
    x = currentPoint(1,1);
    y = currentPoint(1,2);
    bevelPatches = findobj(axesHandle, 'UserData', 'ULBorder');
    buttonNumber = [];
    for bevelPatch = bevelPatches.'
      xi = get(bevelPatch, 'XData');
      yi = get(bevelPatch, 'YData');
      xmin = min(xi);
      xmax = max(xi);
      ymin = min(yi);
      ymax = max(yi);
      if ((x >= xmin) & (x <= xmax) & (y >= ymin) & (y <= ymax))
        buttonNumber = get(bevelPatch, 'UserData');
        buttonId = get(bevelPatch, 'Tag');
        break;
      end
    end
    % If we get here and buttonNumber is not defined, then
    % somehow the user clicked on the axes outside all of the
    % buttons.  Don't do anything.
    if (~length(buttonNumber))
      return;
    end
  end    
  mousedown = 1;

elseif (nargin == 3)
  % BTNPRESS(FIGHANDLE, GROUPID, BUTTONID) or
  % BTNPRESS(FIGHANDLE, GROUPID, BUTTONNUM)
  axesHandle = findall(figHandle, 'Type', 'axes', 'Tag', groupId);
  ud = get(axesHandle,'userdata');
  
  buttonNumber = buttonId;
  if ~isempty(ud.uicontrolButtons)
     uicontrolModeBtnPress(axesHandle,ud,buttonNumber)
     return
  end
  mousedown = 0;  

else
  error('Invalid number of input arguments.');
end

ud = get(axesHandle,'userdata');
buttons = ud.buttonId;
if (isstr(buttonNumber))
  % The UserData of border and background patches is a string, not the
  % buttonNumber.  If buttonNumber is a string, then we need to
  % do some work to find the real buttonNumber.
  for k = 1:size(buttons,1)
    temp = buttons(k,:);
    temp(temp==' ' | temp==0) = []; % deblank
    if (strcmp(temp, buttonId))
      buttonNumber = k;
      break;
    end
  end
else
  % Get the buttonID string.
  buttonId = buttons(buttonNumber,:);
  buttonId(buttonId==' ' | buttonId==0) = [];  % deblank
end
currentFig = get(axesHandle, 'Parent');
groupId = get(axesHandle, 'Tag');
numButtons = prod(size(ud.state));
exFlag = ud.exFlag;
callbacks = ud.callbacks;
buttonDownFcn = ud.buttonDownFcn;
types = ud.pressType;
if (isempty(types))
  pressType = 'toggle';
elseif (size(types,1) == 1)
  pressType = types;
else
  pressType = types(buttonNumber,:);
  pressType(pressType==' ' | pressType==0) = []; % deblank short-cut
end

% OK, we've got all the state info/properties, now do the right
% thing based on 'Exclusive' and 'PressType' properties.

initialState = btnstate(currentFig, groupId, buttonNumber);
exclusiveState = (strcmp(exFlag, 'yes'));
if ~initialState
  % Button is currently up.
  btndown(currentFig, groupId, buttonNumber);
elseif ~exclusiveState  
  % Button is currently down.
  btnup(currentFig, groupId, buttonNumber);
end
currentState = btnstate(currentFig, groupId, buttonNumber);

if mousedown
  % wait here until mouse up event

  bevelPatches = findobj(axesHandle, 'UserData', 'ULBorder');
  for bevelPatch = bevelPatches'
      xi = get(bevelPatch, 'XData');
      yi = get(bevelPatch, 'YData');
      xmin = min(xi);
      xmax = max(xi);
      ymin = min(yi);
      ymax = max(yi);
      currentPoint = get(axesHandle, 'CurrentPoint');
      x = currentPoint(1,1);
      y = currentPoint(1,2);
      p = pinrect([x y],[xmin xmax ymin ymax]);
      if p
          break;
      end
  end
  old_x = x;  old_y = y;  old_p = p;

  userhand = get(axesHandle, 'ZLabel');
  set(userhand,'tag','btnpressuserhand')
  save_callBacks = ...
     installCallbacks(userhand,currentFig,...
         {'windowbuttonmotionfcn', 'windowbuttonupfcn'}, ...
	 {'motion', 'up'});

  % Process buttondown functions:
  haveDownFcn = ~isempty(deblank(buttonDownFcn));
  if haveDownFcn,
      if (size(buttonDownFcn,1) == 1)
	eval(buttonDownFcn);
      else
	eval(buttonDownFcn(buttonNumber, :));
      end
  end

  done = 0;
  while ~done
      event = waitForNextEvent(userhand);
      switch event
      case 'motion'
          currentPoint = get(axesHandle, 'CurrentPoint');
          x = currentPoint(1,1);
          y = currentPoint(1,2);
          p = pinrect([x y],[xmin xmax ymin ymax]);
          if p~=old_p
              currentState = xor(~p,~initialState | exclusiveState);
              if currentState
                  btndown(currentFig, groupId, buttonNumber);
              else
	          if ~haveDownFcn,
                    btnup(currentFig, groupId, buttonNumber);
		  end
              end
          end
          old_x = x;  old_y = y;  old_p = p;
      case 'up'
          done = 1;
	  if haveDownFcn,
             btnup(currentFig, groupId, buttonNumber);
	  end
      end
  end
  set(currentFig,{'windowbuttonmotionfcn' 'windowbuttonupfcn'}, ...
       save_callBacks)
end

if ~exclusiveState
  if currentState == initialState
    needCallBack = 0;  % mouse moved and stayed off button
  else
    needCallBack = 1;
    if strcmp(pressType,'flash')
       % restore button into up position
       btnup(currentFig, groupId, buttonNumber);
    end
  end
else
  % exclusive group
  needCallBack = currentState;
  if ~currentState & initialState
    btndown(currentFig, groupId, buttonNumber);
  end
  if currentState & ~initialState 
    % need to set all the other buttons to up
    stateVector = btnstate(currentFig, groupId);
    for k = [(1:buttonNumber-1) (buttonNumber+1):numButtons]
      if (stateVector(k))
        btnup(currentFig, groupId, k);
        break
      end
    end
  end
  
end

if needCallBack | haveDownFcn,
  if (size(callbacks,1) == 1)
    eval(callbacks);
  else
    eval(callbacks(buttonNumber, :));
  end
end

function saveCallbacks = installCallbacks(h,fig,callbackList,valueList)
% installCallbacks
%   inputs:
%      h - handle of object which will be changed by callbacks
%      fig - handle of figure
%      callbackList - list of figure callbacks in cell array
%           elements are e.g., 'windowbuttonmotionfcn'
%      valueList - same length as callbackList - cell array containing
%           values  (string or numeric) for h's userdata
%   outputs:
%      saveCallbacks - cellarray of what the callbacks were before

   saveCallbacks = cell(1,length(callbackList));
   for i=1:length(callbackList)
       if isstr(valueList{i})
           vstr = ['''' valueList{i} ''''];
       else
           vstr = num2str(valueList{i});
       end
       if 0,  % if problems with fig not being gcf, set this to 1
           figstr = ['hex2num(''' sprintf('%bx',h) ''')'];
       else
           figstr = 'gcf';
       end
       str = ['set(findall(' figstr ',' ...
              '''tag'',''' get(h,'tag') '''),''userdata'',' ...
              vstr ')'];
       saveCallbacks{i} = get(fig,callbackList{i});
       set(fig,callbackList{i},str)
   end

%  
function event = waitForNextEvent(h)
% waitForNextEvent

   set(h,'userdata',0)
   waitfor(h,'userdata')
   event = get(h,'userdata');

function bool = pinrect(pts,rect)
%PINRECT Determine if points lie in or on rectangle.
%  Inputs:
%    pts - n-by-2 array of [x,y] data
%    rect - 1-by-4 vector of [xlim ylim] for the rectangle
%  Outputs:
%    bool - length n binary vector 
 
% $Revision: 1.31 $

    [i,j] = find(isnan(pts));
    bool = (pts(:,1)<rect(1))|(pts(:,1)>rect(2))|...
           (pts(:,2)<rect(3))|(pts(:,2)>rect(4));
    bool = ~bool;
    bool(i) = 0;


function uicontrolModeBtnPress(axesHandle,ud,buttonNumber)
% Handler for uicontrol mode of operation

  if isstr(buttonNumber)
     for k=1:length(ud.uicontrolButtons)
        if strcmp(get(ud.uicontrolButtons(k),'tag'),buttonNumber)
           break 
        end
        if k==length(ud.uicontrolButtons)
           error(sprintf('sorry, can''t find button with ID == ''%s''.'),buttonNumber)
        end
     end
  else
     k = buttonNumber;
  end
     
  val = ud.state(k);  % current button value
  needCallback = 1;
  if strcmp(ud.exFlag,'yes')
     set(ud.uicontrolButtons([1:k-1 k+1:end]),'value',0)               
     set(ud.uicontrolButtons(k),'value',1)
     if val == 1
        needCallback = 0;  % don't want to call if button already pushed in
     end               
  elseif strcmp(get(ud.uicontrolButtons(k),'style'),'togglebutton')
     set(ud.uicontrolButtons(k),'value',1-val);  % toggle!
  end
  % save state before calling callbacks:
  newState = get(ud.uicontrolButtons,'value');
  ud.state = [newState{:}];
  set(axesHandle,'userdata',ud)

  if needCallback
     callbacks = ud.callbacks;
     if (size(callbacks,1) == 1)
       eval(callbacks);
     else
       eval(callbacks(k, :));
     end
  end
 