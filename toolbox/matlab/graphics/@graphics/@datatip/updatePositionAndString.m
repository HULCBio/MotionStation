function updatePositionAndString(hThis,hNewDataCursor)

% Update datatip position and string based on data cursor
%   Copyright 1984-2004 The MathWorks, Inc. 

if nargin>1
  pos = hNewDataCursor.Position;

  % Update position and string
  hThis.DataCursorHandle = hNewDataCursor;
  hThis.Position = pos;
end

pos = hThis.Position;
if isempty(pos)
    return;
end

updatestring(hThis);

% Datatip is visible only if inside axes limits
inBounds = localDoClip(hThis,pos);

% ToDo: The code below is replicated in movetofront
if strcmp(get(hThis,'Visible'),'on') 
      hMarker = hThis.MarkerHandle;
      hTextBox = hThis.TextBoxHandle;
      if (ishandle(hMarker) && ishandle(hTextBox))
           if inBounds
               set(hMarker,'Visible','on');
               if strcmp(get(hThis,'ViewStyle'),'datatip')
                  set(hTextBox,'Visible','on');
               end
           else
               set(hMarker,'Visible','off');
               set(hTextBox,'Visible','off');               
           end
      end

end

%------------------------------------------------------------%
function inBounds = localDoClip(hThis,pos)

% See if the cursor position is empty or outside the 
% axis limits
hAxes = get(hThis,'HostAxes');
inBounds = false;
xlm = get(hAxes,'xlim'); ylm = get(hAxes,'ylim'); zlm = get(hAxes,'zlim');
if ~isempty(pos) && ...
    pos(1) >= min(xlm) && pos(1) <= max(xlm) && ...
    pos(2) >= min(ylm) && pos(2) <= max(ylm)
    if length(pos) > 2 
        if pos(3) >= min(zlm) && pos(3) <= max(zlm)
           inBounds = true;
        end
    else
         inBounds = true;
    end
end

