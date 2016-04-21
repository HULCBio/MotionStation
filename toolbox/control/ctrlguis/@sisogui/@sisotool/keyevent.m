function keyevent(sisodb)
%KEYEVENT  Processes keyboard entries.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 04:59:41 $

Key = get(sisodb.Figure,'CurrentKey');
if isempty(Key)
    return
end
IsOff = any(strcmp(get(sisodb.PlotEditors,'EditMode'),'off'));  % no data loaded yet

switch Key
case 'escape'
    % Exit global modes
    sisodb.GlobalMode = 'off';
    % Exit local modes (needed if GlobalMode=0ff to start with)
    set(sisodb.PlotEditors,'EditMode','idle');
case {'backspace','delete'}
    % Delete selected objects
    SelectedObj = sisodb.EventManager.SelectedObjects;
    if ~isempty(SelectedObj)
        % Start recording
        T = ctrluis.transaction(SelectedObj,'Name','Delete Selection',...
            'OperationStore','on','InverseOperationStore','on');
        delete(SelectedObj);
        sisodb.EventManager.record(T);
    end
end    
