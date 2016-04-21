function evalmcw(editHndl)
%EVALMCW Evaluates a list of functions in a editable text uicontrol.
%   EVALMCW stands for "Evaluate MATLAB command window".
%   EVALMCW(editHandle) evaluates the MATLAB code inside the editable
%   text uicontrol object referred to by the handle editHandle.
%   If an error is detected in the code, it will display the error
%   in the edit field and then reset the text to the last legal
%   statement executed.

%   Ned Gulley, 6-21-93
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/10 23:24:36 $

% Force text in MiniCommand Window to be displayed immediately
figNumber=watchon;
drawnow;

str=get(editHndl,'String');
errorFlag=0;
numRows=size(str,1);
for count=1:numRows,
    try
      eval(str(count,:));
    catch
      errorFlag=1;
    end
    % Exit the loop as soon as there is an error
    if errorFlag, break; end;
end;

% If an error has occurred, display the error and reset the field.
% Otherwise, store the legal code in the object's UserData.
if errorFlag,
    set(editHndl,'ForegroundColor',[1 0 0]);
    % Pad "lasterr" with spaces for consistency
    lasterrStr=[32 lasterr];
    lasterrStr=strrep(lasterrStr,10,[13 10 32]);
    errorStr=str2mat(' Error Detected:',lasterrStr,' Resetting Input');
    set(editHndl,'String',errorStr);
    pause(3);
    oldStr=get(editHndl,'UserData');
    set(editHndl,'String',oldStr);
    set(editHndl,'ForegroundColor',[0 0 0]);
else
    set(editHndl,'UserData',str);
end;

watchoff(figNumber);
