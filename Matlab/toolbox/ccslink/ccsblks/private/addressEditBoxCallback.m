function addressEditBoxCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:44:52 $


blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');

selectedArgNum = get(handles.argChooserListboxTag,'value');
if selectedArgNum > UDATA.numArgs,
    error('This callback should not be reached for Return Value');
end
stringVal = get(hObject,'string');

% Parse string.
% The first item in the edit box must be an address, either decimal or hex.
% Strtok is used to extract only the address itself, with any spaces or
% commas removed.
[addrString, remains1] = strtok(stringVal,' ,');
if length(addrString) > 1 && strcmp(addrString(1:2),'0x'),
    val = hex2dec(addrString(3:end));
else
    [val success] = str2num(addrString); 
    if ~success,
        uiwait(errordlg(['Address parameter must be a literal expression, ' ...
                'e.g. "0x8000fe43" or "2346234534".  The page can be ' ...
                'optionally specified after a comma, e.g. "0x8000fe43, 0".'], ...
            'Error in HIL Function Call Block','modal'));
        return;
    end
end
% Page:
pageString = strrep(remains1,',','');  % Get rid of comma
pageString = strrep(pageString,' ','');  % Get rid of spaces
if length(pageString) > 1 && strcmp(addrString(1:2),'0x'),
    pageVal = hex2dec(pageString(3:end));
else
    [pageVal success] = str2num(pageString); 
    if ~success,
        pageVal = 0;
    end
end


% Save in block
UDATA.args(selectedArgNum).address = [val pageVal];
set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');
