function pushundo(figNumber,newFis)
%PUSHUNDO Push the current FIS onto the undo stack.
%   PUSHUNDO(figNumber,newFIS) pushes the old FIS matrix into the UserData
%   for the Undo uimenu. The function also broadcasts changes in the FIS
%   matrix to all the other related GUI tools, since it gets called every
%   time the FIS matrix gets updated.

%   Kelly Liu 5-6-1996 addopt from Ned Gulley
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/14 22:22:06 $

undoLimit=3;

undoHndl=findobj(figNumber,'Type','uimenu','Tag','undo');
oldFis=get(figNumber,'UserData');
% If a change has been made, then store the old FIS matrix
% in the undo cubbyhole for later use. In other words, newFis is passed
% in just to make a comparison and potentially save time.
if ~isequal(oldFis{1}, newFis), %%% no matter what
    
    % Push the new FIS structure onto the stack
    if length(oldFis)<undoLimit
     endindex=length(oldFis)+1;
    else
     endindex=undoLimit;
    end
    for i=endindex:-1:2
      Fis{i}=oldFis{i-1};
    end
    Fis{1}=newFis;
    set(figNumber, 'UserData', Fis);
    set(undoHndl, 'Enable','on');
end

