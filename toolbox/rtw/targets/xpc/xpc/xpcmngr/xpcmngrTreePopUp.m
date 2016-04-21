function xpcmngrTreePopUp(varargin)
%XPCMNGRTREEPOPUP xPC Target GUI
%   XPCMNGRTREEPOPUP manages the PopUp menu items of the tree Nodes
%   in the xPC Target Manager GUI.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $

Action=varargin{1};
args=varargin(2:end);

switch Action,
    
case 'NodePopUp'
    tree=args{1};
    evt=args{2};
    popUpNodeMenu(tree,evt) 
    return
case 'TreePopUp'
    tree=args{1};
    evt=args{2};  
    popUpTreeMenu(tree,evt) 
    return
otherwise    
    error('Invalid Action')
end


function popUpTreeMenu(tree,evt)
xpcmngrUserData=get(tree.FigHandle,'Userdata');
objpos = move(tree);
conpos = [double(evt.x)+objpos(1),  double(evt.y)+objpos(2)];
popUp=xpcmngrUserData.uipopUp;
delete(get(popUp,'Children'));
uiMenu=uimenu(popUp,'label','Add Target',...
    'Tag','AddTargetfromHost',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
% uiMenu=uimenu(popUp,'label','Add ',...
%     'Tag','AddTargetfromHost',...
%     'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});

set(popUp, 'position', conpos, 'visible', 'on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function popUpNodeMenu(tree,evt)
xpcmngrUserData=get(tree.FigHandle,'Userdata');
objpos = move(tree);
conpos = [double(evt.x)+objpos(1),  double(evt.y)+objpos(2)];
popUp=xpcmngrUserData.uipopUp;
delete(get(popUp,'Children'));
% popUp = actxcontrol('Internet.PopupMenu',...
%     [0 0 0 0],xpcmngrUserData.figure,...
%     {'click','xpcmngrTreePopup'});

% popUp.addproperty('xpcmngrUserData');
% popUp.xpcmngrUserData=xpcmngrUserData;
% popUp.addproperty('NodeClicked');
% popUp.addproperty('NodeAction');
%popUp.NodeClicked=tree.selectedItem;
%%%
%tg=get_targetxpc;
%%%
%%%%%%Node Menu for:----------
%--Host PC---------------
if strcmp(tree.SelectedItem.Text,'Host PC Root')
   p_HostPC_Node_Menu(tree,popUp)
end
%--TargetPC---------------
if findstr('TGPC',tree.SelectedItem.Key)
   p_TargetPC_Node_Menu(tree,popUp)
end    

if findstr('.dlm',tree.SelectedItem.Key)
   p_Dlm_Node_Menu(tree,popUp)
end
if findstr('tgAppNode',tree.SelectedItem.Key)
   p_TgApp_Node_Menu(tree,popUp)
end
if findstr('HostSc',tree.SelectedItem.Key)
   p_Host_Scs_Node_Menu(tree,popUp)
end
if findstr('TgSc',tree.SelectedItem.Key)
   p_Target_Scs_Node_Menu(tree,popUp)
end
if findstr('FileSc',tree.SelectedItem.Key)
   p_File_Scs_Node_Menu(tree,popUp)
end
%---Host Scope(s)
if findstr('HScid',tree.SelectedItem.Key)
   p_HostScId_Node_Menu(tree,popUp)
end
%---Target Scope(s)
if findstr('TScid',tree.SelectedItem.Key)
   p_TargetScId_Node_Menu(tree,popUp)
end
%---File Scope(s)
if findstr('FScid',tree.SelectedItem.Key)
   p_FileScId_Node_Menu(tree,popUp)
end
%---Signal node(Mdl Heirachy)
if findstr('xPCSIG',tree.SelectedItem.Key)
   p_SigAdd_Node_Menu(tree,popUp) 
   %i_AddSig2ScNodeMenuItem(xpcmngrUserData)
end
%---Signal on Scope: id
if findstr('xPCSigScope',tree.SelectedItem.Key)
    p_ScId_Sig_Node_Menu(tree,popUp) 
    %i_AddSigofScopeIdNodeMenuItem(xpcmngrUserData)    
end
%---block parameter node
if findstr('xPCPT',tree.SelectedItem.Key)
    p_xPCpt_Node_Menu(tree,popUp)
end


set(popUp, 'position', conpos, 'visible', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p_HostPC_Node_Menu(tree,popUp)
uiMenu=uimenu(popUp,'label','Add Target',...
    'Tag','AddTargetfromHost',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function p_TargetPC_Node_Menu(tree,popUp)
uiMenu=uimenu(popUp,'label', 'Connect',...
    'Tag','ConnectTargetPC',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
tg=gettg(tree);
if ~isempty(tg)
    uiMenu=uimenu(popUp,'label', 'Disconnect',...
        'Tag','DisConnectTargetPC',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
end
uiMenu=uimenu(popUp,'label', 'Remove',...
    'Tag','RemTargetPC',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});                                   
uiMenu=uimenu(popUp,'label', 'Rename',...
    'Tag','RenTargetPC',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function p_Dlm_Node_Menu(tree,popUp)
allTargetIdx=strmatch('TGPC',tree.GetAllKeys);
allNames=tree.GetAllNames;
alltgNames=allNames(allTargetIdx);
numOftgConnxpcNodes=length(alltgNames);
for i=1:numOftgConnxpcNodes
    %tg=get_TargetxPC(tree,alltgNames{i});
    tg=gettg(tree,alltgNames{i});
    if ~isempty(tg)
        %if strcmp((xpctargetping(tg),'success')
        lblstr=['Download to Target ',alltgNames{i}];
        uiMenu=uimenu(popUp,'label',lblstr,...
            'Tag','Downloaddlm',...
            'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function p_TgApp_Node_Menu(tree,popUp)
%tg=get_TargetxPC(tree);
tg=gettg(tree);
uiMenu=uimenu(popUp,'label', 'Go To Simulink model',...
        'Tag','Go2SLmdl',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});                    
if strcmp(tg.Status,'running')
    uiMenu=uimenu(popUp,'label', 'Stop',...
        'Tag','TgStop',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});                    
else
    uiMenu=uimenu(popUp,'label', 'Start',...
        'Tag','TgStart',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});          
end
uiMenu=uimenu(popUp,'label', 'Unload',...
    'Tag','TgUnload',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')}); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function p_Host_Scs_Node_Menu(tree,popUp)
uiMenu=uimenu(popUp,'label', 'Add host scope',...
    'Tag','AddHostScope',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});

uiMenu=uimenu(popUp,'label', 'Scope viewer',...
    'Tag','HostScopeView',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
if (tree.selectedItem.Children == 0)
    set(uiMenu,'Enable','off')
end

if (tree.SelectedItem.Children)
    uiMenu=uimenu(popUp,'label', 'Delete all',...
        'Tag','DelScopes',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
    
end
%tg=get_TargetxPC(tree);
%if strcmp(tg.Status,'Running')
%    popUp.AddItem('Start all');
%else
%    popUp.AddItem('Stop all');
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function p_Target_Scs_Node_Menu(tree,popUp)
uiMenu=uimenu(popUp,'label', 'Add target scope',...
    'Tag','AddTargetScope',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
if (tree.SelectedItem.Children)
    uiMenu=uimenu(popUp,'label', 'Delete all',...
        'Tag','DelScopes',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function p_File_Scs_Node_Menu(tree,popUp)
uiMenu=uimenu(popUp,'label', 'Add file scope',...
    'Tag','AddTargetScope',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
if (tree.SelectedItem.Children)
    uiMenu=uimenu(popUp,'label', 'Delete all',...
        'Tag','DelScopes',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%HostScIdNodeMenu
function p_HostScId_Node_Menu(tree,popUp)
%%popUp.NodeAction='HScid';
%tg=xpcGetTG(tree);
tg = gettg(tree);
scIdx=eval(tree.SelectedItem.Text(7:end));
sc=tg.getscope(scIdx);

if strcmp(sc.status,'Interrupted') 
    uiMenu=uimenu(popUp,'label', 'Start',...
        'Tag','StartSc',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});    
end

if (strcmp(sc.status,'Acquiring') | strcmp(sc.status,'Finished') | ...
   strcmp(sc.Status,'Pre-Acquiring') | strcmp(sc.status,'Ready for being Triggered'))
   uiMenu=uimenu(popUp,'label', 'Stop',...
       'Tag','StopSc',...
       'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});        
end
if strcmp(sc.TriggerMode,'Software') 
    if strcmp(sc.status,'Ready for being Triggered')
        uiMenu=uimenu(popUp,'label', 'Trigger',...
            'Tag','softTtiggerSc',...
            'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});    
    end
end

uiMenu=uimenu(popUp,'label', 'Delete',...
        'Tag','RemSc',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
function p_TargetScId_Node_Menu(tree,popUp)
%popUp.NodeAction='TScid';
tg=gettg(tree);
scIdx=eval(tree.SelectedItem.Text(7:end));
sc=tg.getscope(scIdx);


if strcmp(sc.status,'Interrupted') 
    uiMenu=uimenu(popUp,'label', 'Start',...
        'Tag','StartSc',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});    
end    

if (strcmp(sc.status,'Acquiring') | strcmp(sc.status,'Finished') | ...
   strcmp(sc.Status,'Pre-Acquiring') | strcmp(sc.status,'Ready for being Triggered'))
   uiMenu=uimenu(popUp,'label', 'Stop',...
       'Tag','StopSc',...
       'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});        
end          
if strcmp(sc.TriggerMode,'Software') 
    if strcmp(sc.status,'Ready for being Triggered')
        uiMenu=uimenu(popUp,'label', 'Trigger',...
            'Tag','softTtiggerSc',...
            'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});    
    end
end
uiMenu=uimenu(popUp,'label', 'Delete',...
    'Tag','RemSc',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p_FileScId_Node_Menu(tree,popUp)
tg=xpcGetTG(tree);
scIdx=eval(tree.SelectedItem.Text(7:end));
sc=tg.getscope(scIdx);

if strcmp(sc.status,'Interrupted') 
    uiMenu=uimenu(popUp,'label', 'Start',...
        'Tag','StartSc',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});    
end          

if (strcmp(sc.status,'Acquiring') | strcmp(sc.status,'Finished') | ...
   strcmp(sc.Status,'Pre-Acquiring') | strcmp(sc.status,'Ready for being Triggered'))
   uiMenu=uimenu(popUp,'label', 'Stop',...
       'Tag','StopSc',...
       'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});        
end          
if strcmp(sc.TriggerMode,'Software') 
    if strcmp(sc.status,'Ready for being Triggered')
        uiMenu=uimenu(popUp,'label', 'Trigger',...
            'Tag','softTtiggerSc',...
            'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});    
    end
end
uiMenu=uimenu(popUp,'label', 'Delete',...
    'Tag','RemSc',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  p_SigAdd_Node_Menu(tree,popUp) 
tree=tree;
tg=gettg(tree);
sc=tg.getscope;

uimAddSch=uimenu(popUp,...
    'label','Add to Scopes...',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});
% allkeys=tree.GetAllKeys;
% tgpcs=strmatch('TGPC',tree.GetAllKeys);
% 
% for ii=1:length(tgpcs)
%     if tree.Nodes.Item(tgpcs(ii)).Bold==1
%         tgindex=tgpcs(ii);
%         break
%     end
% end

 allNames=tree.GetAllNames;
% allNames=allNames(tgindex:end);

scNodeIdx=strmatch('Scope:',allNames);
if ~isempty(scNodeIdx)
    scNames=allNames(scNodeIdx);    
    scType=get(sc,'Type');
    if (length(sc) == 1)
        scType={scType};
    end
    for i=1:length(sc)
        scid=sprintf('%d',sc(i).scopeid);%[scNames{i},' (',sc(scid).Type,')']
        uimh=uimenu(uimAddSch,'label', ['Scope: ',scid,' (',sc(i).Type,')'],...
            'Tag','AddScopeMenu',...
            'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});             
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p_ScId_Sig_Node_Menu(tree,popUp)
tree=tree;
tg=gettg(tree);
%sc=tg.getscope;
scIdx=eval(tree.SelectedItem.Parent.Text(7:end));
sc=tg.getscope(scIdx);
h=uimenu(popUp,...
  'label','Remove',...
  'Tag', 'RemSigFromScId',...
  'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});


if strcmp(sc.TriggerMode,'Signal')
    uiMenu=uimenu(popUp,'label', 'Set as trigger',...
        'Tag','TriggerSc',...
        'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  p_xPCpt_Node_Menu(tree,popUp)
h=uimenu(popUp,...
    'label','Go to Simulink Block',...
    'Tag', 'GoToSLBlk',...
    'Callback',{@xpcmngrPopUpCallback, get(tree.figHandle,'Userdata')});






