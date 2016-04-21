function fisgui(action,oldName,newName)
%FISGUI Handle generic figure management tasks for fuzzy GUI.
%   This functions handles menu creation and the execution of the
%   "File" menu items like "Save", "Save As...", "Close", and so on.

%   Kelly Liu 5-3-96  Ned Gulley, 6-9-94, N. Hickey 17-03-01
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.38 $  $Date: 2002/04/14 22:20:44 $

% The arguments oldName and newName are used only for the renaming option

if strcmp(action,'#initialize')
% Create the main menubar items File Edit View common to every editor.
% Create the File main menu item, and its submenus, then call createmenu to create
% the Edit, View and Options mainmenu items.
    
    figNumber=gcf;
    oldfis=get(gcf,'UserData');
    fis=oldfis{1};
    tag=get(figNumber,'Tag');
    
    % Main menu bar item File -------------------------------------------------
    fileHndl=uimenu(figNumber,'Label','File','Accelerator','F');
    h = uimenu('Parent',fileHndl, ...
        'Label', 'New FIS...');
    uimenu('Parent',h, ...
        'Label', 'Mamdani', ...
        'Accelerator','N', ...
        'Tag', 'newmamdani',...
        'Callback','fisgui #newmamdani');
    uimenu('Parent', h, ...
        'Label', 'Sugeno', ...
        'Callback','fisgui #newsugeno');
    % File submenu item Import
    h = uimenu('Parent', fileHndl,'Label', 'Import', ...
        'Separator','on');
    uimenu('Parent',h,'Label', 'From Workspace...', ...
        'Tag', 'openfis',...
        'Callback','fisgui #ws2gui');
    uimenu('Parent',h,'Label', 'From Disk...', ...
        'Tag', 'openfis',...
        'Accelerator', 'O', ...
        'Callback','fisgui #openfis');
    % File submenu item Export
    h = uimenu('Parent', fileHndl,'Label', 'Export');
    uimenu('Parent',h,'Label', 'To Workspace...', ...
        'Accelerator', 'T', ...
        'Callback', 'fisgui #gui2ws');
    uimenu('Parent',h,'Label', 'To Disk...', ...
        'Tag', 'save',...
        'Accelerator', 'S', ...
        'Callback','fisgui #save');
    % File submenu item Print
    uimenu(fileHndl,'Label', 'Print', ...
        'Separator','on', ...
        'Accelerator', 'P', ...
        'Callback','printdlg');
    % File submenu item Close
    uimenu(fileHndl,'Label', 'Close', ...
        'Separator','on', ...
        'Accelerator', 'W', ...
        'Callback','fisgui #close');

    % Main menu bar item Edit---------------------------------------------------
    Handles.editHndl=uimenu('Parent', figNumber, 'Label', 'Edit', 'Tag','editmenu');

    % Main menu bar item View------------------------------------------------------
    Handles.viewHndl=uimenu('Parent', figNumber,'Label', 'View', 'Tag', 'viewmenu');

    % Populate the fuzzy editor specific submenu items
    createmenu(figNumber, tag, Handles);

    
elseif strcmp(action,'#findgui'),
    %===================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    CallBkHndl = gcbo;
    % Check to see if findgui was called from a btn down on a patch or via menu
    if strcmp(get(CallBkHndl, 'Type'), 'patch')
        name = '';
    else
        nameList=[ ...
            'FIS Editor                '
            'Membership Function Editor'
            'Rule Editor               '
            'Rule Viewer               '
            'Surface Viewer            '
            'Anfis Editor              '];
        currGui=get(CallBkHndl,'UserData');
        name=deblank(nameList(currGui,:));
    end
    
    if ~isempty(name)
        tag=get(CallBkHndl,'Tag');
        % Figure out what the current GUI type is based on the figure's tag
        fisName=fis.name;
        newFigNumber=findobj(0,'Name',[name ': ' fisName]);
        statmsg(figNumber,['Opening ' name]);
        if isempty(newFigNumber),
            eval([tag '(fis);']);
        elseif strcmp(get(newFigNumber,'Visible'),'off'),
            figure(newFigNumber)
            eval([tag ' #update']);
        else
            figure(newFigNumber);
        end
    end
    statmsg(figNumber,'Ready');
    watchoff(figNumber);
    

elseif strcmp(action,'#openfis'),
    %====================================
    figNumber=watchon;
    [fis,errorStr]=readfis;
    if isempty(fis),
        statmsg(figNumber,errorStr);
    else
        msgStr='Opening file';
        statmsg(figNumber,msgStr);
        fuzzy(fis);
        statmsg(figNumber,'Ready');
    end
    watchoff(figNumber);
    
elseif strcmp(action,'#save');
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    oldName=fis.name;
    
    [newName,pathName,errorStr]=writefis(fis,oldName,'dialog');
    if ~isempty(errorStr),
        statmsg(figNumber,errorStr)
    else
        if ~strcmp(oldName,newName),
            fisgui('#fisname',oldName,newName);
        end
        statmsg(figNumber,['Saved FIS "' newName '" to disk']);
    end
    watchoff(figNumber);

elseif strcmp(action,'#gui2ws');
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    statmsg(figNumber,'Saving FIS to workspace');
    
    fisName=fis.name;
    wsdlg(fis,fisName,'gui2ws',figNumber);
    watchoff(figNumber);
    
elseif strcmp(action,'#ws2gui');
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    statmsg(figNumber,'Opening FIS from workspace');
    
    fisName=fis.name;
    wsdlg(fis,fisName,'ws2gui', figNumber);
    watchoff(figNumber);
    
elseif strcmp(action,'#newmamdani');
    %====================================
    figNumber=watchon;
    newFis=newfis('Untitled','mamdani');
    newFis=addvar(newFis,'input','input1',[0 1],'init');
    newFis=addvar(newFis,'output','output1',[0 1],'init');
    
    statmsg(figNumber,'Opening FIS Editor for new Mamdani system');
    fuzzy(newFis);
    watchoff(figNumber);
    
elseif strcmp(action,'#newsugeno');
    %====================================
    figNumber=watchon;
    newFis=newfis('Untitled','sugeno');
    newFis=addvar(newFis,'input','input1',[0 1],'init');
    newFis=addvar(newFis,'output','output1',[0 1],'init');
    
    statmsg(figNumber,'Opening FIS Editor for new Sugeno system');
    fuzzy(newFis);
    watchoff(figNumber);
    
elseif strcmp(action,'#close');
    %====================================
    figNumber=gcf;
    allfis=get(figNumber,'UserData');
    fis=allfis{1};
    nameList=[ ...
            'FIS Editor                '
        'Membership Function Editor'
        'Rule Editor               '
        'Rule Viewer               '
        'Surface Viewer            '
        'Anfis Editor              '];
    
    fisName=fis.name;
    visFigList=[];
    invisFigList=[];
    % See who's left onscreen
    for count=1:size(nameList, 1),
        name=deblank(nameList(count,:));
        visFigList=[visFigList findobj(0, 'Type', 'figure',...
                'Name',[name ': ' fisName],'Visible','on')'];
        invisFigList=[invisFigList findobj(0, 'Type', 'figure', ...
                'Name',[name ': ' fisName],'Visible','off')'];
    end
    
    if length(visFigList)==1,
        % This is the last visible relative. Closing this will mean losing data.
        fistemp{1}=fis; %make a cell
        savedlg(fistemp,[visFigList invisFigList]);
    else
        set(figNumber,'Visible','off');
    end
    
elseif strcmp(action,'#fisname'),
    %====================================
    figNumber=watchon;
    
    newName=deblank(newName);
    newName=fliplr(deblank(fliplr(newName)));
    nameStr='FIS Editor';
    newFigNumber=findobj(0,'Name',[nameStr ': ' oldName]);
    if newFigNumber,
        newFigNumber=newFigNumber(1);
        oldfis=get(newFigNumber,'UserData');
        fis=oldfis{1};
        fis.name=newName;
        msgStr=['Renamed FIS to "' newName '"'];
        statmsg(newFigNumber,msgStr);
        set(newFigNumber, ...
            'Name',['FIS Editor: ' newName]);
        pushundo(newFigNumber, fis);
        txtHndl=findobj(newFigNumber,'Type','text','Tag','fisname');
        set(txtHndl,'String',newName);
        txtHndl=findobj(newFigNumber,'Type','uicontrol','Tag','fisname');
        set(txtHndl,'String',newName);
    end
    
    % Give the appropriate name to all other related GUI windows
    nameStrMatrix=[ ...
            'Membership Function Editor'
        'Rule Editor               '
        'Rule Viewer               '
        'Surface Viewer            '
        'Anfis Editor              '];
    for count=1:5,
        nameStr=deblank(nameStrMatrix(count,:));
        newFigNumber=findobj(0,'Name',[nameStr ': ' oldName]);
        if ~isempty(newFigNumber),
            newFigNumber=newFigNumber(1);
            oldfis=get(newFigNumber,'UserData');
            fis=oldfis{1};
            fis.name=newName;
            msgStr=['Renamed FIS to "' newName '"'];
            statmsg(newFigNumber,msgStr);
            set(newFigNumber, ...
                'Name',[nameStr ': ' newName]); 
            pushundo(newFigNumber, fis);
        end
    end
    watchoff(figNumber);
    
end
