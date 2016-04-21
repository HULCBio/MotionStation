function popundo(figNumber)
%POPUNDO Pop the last FIS change off the undo stack.
%   POPUNDO(figNumber) pops the old FIS matrix off of the UserData
%   for the Undo uimenu. The function also broadcasts changes in the FIS
%   matrix to all the other related GUI tools.

%   Ned Gulley, 8-31-94
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/14 22:19:31 $

if nargin<1,
    figNumber=get(0,'CurrentFigure');
end

undoHndl=findobj(figNumber,'Type','uimenu','Tag','undo');
fis=get(figNumber,'UserData');
if length(fis)>1, 
    statmsg(figNumber,'Undoing last change');

    % Pop the old FIS matrix off the stack
    for i=1:length(fis)-1
      fis{i}=fis{i+1};
    end
    fis(length(fis))=[];
    % Now we have to update everybody
    % The figure tag contains the function name that created it (i.e. fuzzy)
    guiList=1:6;
    tag=get(figNumber,'Tag');
    set(figNumber, 'Userdata', fis);
    updtfis(figNumber,fis{1},guiList);
    if length(fis)>1
       set(undoHndl,'Enable','on');
    else
       set(undoHndl,'Enable','off');
    end
else
    set(undoHndl,'Enable','off');
end


