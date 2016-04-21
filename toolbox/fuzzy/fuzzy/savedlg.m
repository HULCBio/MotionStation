function savedlg(action,figList)
%SAVEDLG Graphical user interface save warning dialog.
%   SAVEDLG(action,figList) calls the standard question dialog to ask the 
%   user if they wish to save the FIS before closing the final fuzzy window.

%   Ned Gulley, 9-15-94
%   N. Hickey,  3-03-01
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/14 22:19:19 $


fis = action{1};
oldName=fis.name;
% Call the standard question dialog box
ButtonPressed = questdlg(sprintf('Save changes to %s?',oldName),'FIS Editor');

switch ButtonPressed
    
case 'Yes'
    % Call writefis to give user option to save FIS to disk
    [newName,pathName,errorStr]=writefis(fis,oldName,'dialog');
    figNumber = watchon;
    if ~isempty(errorStr),
        statmsg(figNumber,errorStr);
        watchoff(figNumber);
    else
        if ~strcmp(oldName,newName),
            fisgui('#fisname',oldName,newName);
        end
        % Put the path name along with a time stamp into the menu items user data
        pathHndl=findobj(figNumber,'Type','uimenu','Tag','save');
        set(pathHndl,'UserData',pathName);
        timeHndl=findobj(figNumber,'Type','uimenu','Tag','saveas');
        set(timeHndl,'UserData',clock);
        watchoff(figNumber);
        delete(figList(ishandle(figList)));
    end

case 'No'
    % Closes all fuzzy windows and exits without saving changes to FIS
    delete(figList(ishandle(figList)));
   
case 'Cancel'
    % Do nothing questdlg box closes automatically
    
end
