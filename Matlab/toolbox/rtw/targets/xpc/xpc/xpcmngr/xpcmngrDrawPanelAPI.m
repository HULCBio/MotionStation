function xpcmngrUserData=xpcmngrDrawPanelAPI(xpcmngrUserData)
%XPCMNGRDRAWPANELAPI xpc Target Manager GUI
%   XPCMNGRDRAWPANELAPI Manages the Right side compomenets of the Manager
%   GUI

%   Copyright 1996-2004 TheathWorks, Inc.
%   $Revision: 1.1.6.11 $


xpcmngrUserData.drawPanelapi.commConfigNodes=@i_drawTargetCommConfigPanel;
xpcmngrUserData.drawPanelapi.tgAppConfigNodes=@i_drawTgAppConfigPanel;
xpcmngrUserData.drawPanelapi.tgxpcPTNode=@createblockptdlg;
xpcmngrUserData.drawPanelapi.hostConfigNode=@i_createHostConfigdlgPanel;
xpcmngrUserData.drawPanelapi.targetPC=@i_drawTargetPC;
xpcmngrUserData.drawPanelapi.scopeid=@i_drawScopeIdPanel;
xpcmngrUserData.drawPanelapi.menufcn=@updateMenus;
xpcmngrUserData.drawPanelapi.sigNode=@i_drawsignals;
xpcmngrUserData.drawPanelapi.root=@i_drawHostRoot;
xpcmngrUserData.drawPanelapi.scopeDir=@i_drawscopeDir;
xpcmngrUserData.drawPanelapi.scopeTypeDir=@i_drawscopeTypeDir;
xpcmngrUserData.drawPanelapi.mdlH=@i_drawMdlH;
xpcmngrUserData.drawPanelapi.dlmH=@i_drawDLMH;


function xpcmngrUserData=i_drawMdlH(xpcmngrUserData)
figH=xpcmngrUserData.figure;
fpos=get(xpcmngrUserData.figure,'Position');
viewPanelArea=i_calcPanelViewableArea(xpcmngrUserData.figure,xpcmngrUserData.treeCtrl);
left=viewPanelArea(1);
left=left+10;
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
tgName=xpcmngrUserData.treeCtrl.SelectedItem.Parent.Parent.Text;
set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgName,' Model Hierachy']);
listViewPos=[left 20 allowdWidth fpos(4)-50];
xpcmngrUserData.rtfCtrl=actxcontrol('MWXPCControls.richtextboxctrl',listViewPos,figH);
xpcmngrUserData.rtfCtrl.LoadFile([xpcroot,'\xpc\xpcmngr\Resources\mdlh.rtf']);
xpcmngrUserData.rtfCtrl.locked=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_drawDLMH(xpcmngrUserData)
figH=xpcmngrUserData.figure;
fpos=get(xpcmngrUserData.figure,'Position');
viewPanelArea=i_calcPanelViewableArea(xpcmngrUserData.figure,xpcmngrUserData.treeCtrl);
left=viewPanelArea(1);
left=left+10;
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
%tgName='Current Direcotry ;
set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',['DLM(s) ',pwd])
listViewPos=[left 20 allowdWidth fpos(4)-50];
xpcmngrUserData.rtfCtrl=actxcontrol('MWXPCControls.richtextboxctrl',listViewPos,figH);
xpcmngrUserData.rtfCtrl.LoadFile([xpcroot,'\xpc\xpcmngr\Resources\dlmH.rtf']);
xpcmngrUserData.rtfCtrl.locked=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_drawscopeDir(xpcmngrUserData)
figH=xpcmngrUserData.figure;
fpos=get(xpcmngrUserData.figure,'Position');
viewPanelArea=i_calcPanelViewableArea(xpcmngrUserData.figure,xpcmngrUserData.treeCtrl);
left=viewPanelArea(1);
left=left+10;
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);

tgName=xpcmngrUserData.treeCtrl.SelectedItem.Parent.Parent.Text;
set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgName,' xPC Scopes'])
%
% h=uicontrol(figH,'Style','Text',...
%     'String','Root',...
%     'FontWeight','Bold',...
%     'HorizontalAlignment','Left',...
%     'Position',[left+15,fpos(4)-50,fpos(3),25]);
% set(h,'Units','Normalized')
%
listViewPos=[left 20 allowdWidth fpos(4)-50];

xpcmngrUserData.rtfCtrl=actxcontrol('MWXPCControls.richtextboxctrl',listViewPos,figH);
xpcmngrUserData.rtfCtrl.LoadFile([xpcroot,'\xpc\xpcmngr\Resources\xPCScopes.rtf']);
xpcmngrUserData.rtfCtrl.locked=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_drawscopeTypeDir(xpcmngrUserData,scType)
figH=xpcmngrUserData.figure;
fpos=get(xpcmngrUserData.figure,'Position');
viewPanelArea=i_calcPanelViewableArea(xpcmngrUserData.figure,xpcmngrUserData.treeCtrl);
left=viewPanelArea(1);
left=left+10;
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
tgName=xpcmngrUserData.treeCtrl.SelectedItem.Parent.Parent.Parent.Text;
listViewPos=[left 20 allowdWidth fpos(4)-50];
xpcmngrUserData.rtfCtrl=actxcontrol('MWXPCControls.richtextboxctrl',listViewPos,figH);
if strcmp(scType,'hostSc')
    set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgName,' Host Scopes'])
    xpcmngrUserData.rtfCtrl.LoadFile([xpcroot,'\xpc\xpcmngr\Resources\HostScope.rtf']);
elseif strcmp(scType,'tgSc')
    set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgName,' Target Scopes'])
    xpcmngrUserData.rtfCtrl.LoadFile([xpcroot,'\xpc\xpcmngr\Resources\TgScope.rtf']);
elseif strcmp(scType,'fileSc')
    set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgName,' File Scopes'])
    xpcmngrUserData.rtfCtrl.LoadFile([xpcroot,'\xpc\xpcmngr\Resources\FileScope.rtf']);
end
xpcmngrUserData.rtfCtrl.locked=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_drawHostRoot(xpcmngrUserData)
figH=xpcmngrUserData.figure;
fpos=get(xpcmngrUserData.figure,'Position');
viewPanelArea=i_calcPanelViewableArea(xpcmngrUserData.figure,xpcmngrUserData.treeCtrl);
left=viewPanelArea(1);
left=left+10;
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text','(Host PC) Root ')
% h=uicontrol(figH,'Style','Text',...
%     'String','Root',...
%     'FontWeight','Bold',...
%     'HorizontalAlignment','Left',...
%     'Position',[left+15,fpos(4)-50,fpos(3),25]);
% set(h,'Units','Normalized')

listViewPos=[left 20 allowdWidth fpos(4)-50];

rootText=['The Simulink Root is the top most node '...
    'in the Simulink hierarchy. All loaded models'...
    'and libraries live under the Simulink Root. '...
    'Any global instances of Simulink data classes',...
    'such as: Parameter, Signal, and custom storage ',...
    'classes can be found here along with any valid '...
    'MATLAB base workspace variables.'];

% h=uicontrol(figH,'Style','Text',...
%     'String',rootText,...
%     'FontWeight','Bold',...
%     'BackGroundColor','w',...
%     'HorizontalAlignment','Left',...
%     'Position',listViewPos);

xpcmngrUserData.rtfCtrl=actxcontrol('MWXPCControls.richtextboxctrl',listViewPos,figH);
xpcmngrUserData.rtfCtrl.LoadFile([xpcroot,'\xpc\xpcmngr\Resources\HostPCRoot.rtf']);
xpcmngrUserData.rtfCtrl.Locked=1;
%xpcmngrUserData.rtfCtrl.BorderStyle='rtfNoBorder';
%ax.ScrollBars='rtfBoth';
%xpcmngrUserData.rtfCtrl.Locked=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_drawTargetPC(xpcmngrUserData)
fpos=get(xpcmngrUserData.figure,'Position');
viewPanelArea=i_calcPanelViewableArea(xpcmngrUserData.figure,xpcmngrUserData.treeCtrl);
left=viewPanelArea(1);
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
%tgName=tree.SelectedItem.Text;
set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',...
    [xpcmngrUserData.treeCtrl.SelectedItem.Text,...
    ' Target Status Display ' ])
%[fig_rect(3)/3 fig_rect(4)-45+20 fig_rect(3)-fig_rect(3)/3 25]
%fpos(4)-45-25-25-25  26MSCOMctlLib.listViewCtrl.2
listViewPos=[left+10 20 allowdWidth fpos(4)-50];
xpcmngrUserData.listCtrl=actxcontrol('MWXPCControls.listviewctrl',...
             listViewPos,xpcmngrUserData.figure);

%xpcmngrUserData.tg.pt.allH{end+1}=listviewCtrl;
tg=gettg(xpcmngrUserData.treeCtrl);
xpcmngrUserData.listCtrl.GridLines=0;
%xpcmngrUserData.listCtrl.LabelEdit='lvwManual';
%xpcmngrUserData.listCtrl.LabelEdit='lvwManual';
xpcmngrUserData.listCtrl.FullRowSelect=1;
%xpcmngrUserData.listCtrl.View='lvwReport';
xpcmngrUserData.listCtrl.View=3;
xpcmngrUserData.listCtrl.HideColumnHeaders=1;
xpcmngrUserData.listCtrl.ColumnHeaders.Add;
set(xpcmngrUserData.listCtrl.ColumnHeaders.Item(1),'Width',200);
xpcmngrUserData.listCtrl.ColumnHeaders.Add;
set(xpcmngrUserData.listCtrl.ColumnHeaders.Item(2),'Width',250);
%xpcmngrUserData.listCtrl.HideColumnHeaders=1;
list=xpcmngrUserData.listCtrl;
list.Font.Size=11;
list.labelEdit=1;
%list.Font.Bold=1;

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='Loaded App';%1
le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='Mode';%2
le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='Logging';%3
le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='StopTime';%4
le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='Sample Time';%5
le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='Average TET';%6
le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='Execution Time';%7
le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='Target Name:';%1
set(list.ListItems.Item(8).listsubItems.Item(1),'Text',xpcmngrUserData.treeCtrl.selectedItem.Text)

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='Connected:';%1




if ~isempty(tg)
    if strcmp(tg.application,'loader')
        set(list.ListItems.Item(1).listsubItems.Item(1),'Text','loader')
    else
        set(list.ListItems.Item(1).listsubItems.Item(1),'Text',tg.application)
        set(list.ListItems.Item(2).listsubItems.Item(1),'Text',tg.Mode)
        set(list.ListItems.Item(3).listsubItems.Item(1),'Text',getlogstatus(tg))
        set(list.ListItems.Item(4).listsubItems.Item(1),'Text',sprintf('%0.5f',tg.StopTime))
        set(list.ListItems.Item(5).listsubItems.Item(1),'Text',sprintf('%0.5f',tg.SampleTime))
        set(list.ListItems.Item(6).listsubItems.Item(1),'Text',sprintf('%0.7f',tg.AvgTeT))
        set(list.ListItems.Item(7).listsubItems.Item(1),'Text',sprintf('%0.5f',tg.ExecTime))
        set(list.ListItems.Item(9).listsubItems.Item(1),'Text','Yes')
    end
else
    set(list.ListItems.Item(9).listsubItems.Item(1),'Text','No')
end

% fpos=get(xpcmngrUserData.figure,'Position')
% set(xpcmngrUserData.figure,'Position',[fpos(1)+5 fpos(2) fpos(3)+0.1 fpos(4)+0.1])
% set(xpcmngrUserData.figure,'Position',[fpos(1)-5 fpos(2) fpos(3)+0.1 fpos(4)+0.1])
%drawnow
%xpcmngrGUI('ResizeGUI',xpcmngrUserData.figure)

%set(listviewCtrl.ColumnHeaders.Item(2),'Text','Block Type');
%xpcmngrUserData.listCtrl.ColumnHeaders.Add;
%set(listviewCtrl.ColumnHeaders.Item(3),'Text','Parameter Name');
%listviewCtrl.ColumnHeaders.Add;
%set(listviewCtrl.ColumnHeaders.Item(4).Text,'Dims');
%listviewCtrl.ColumnHeaders.Item(4).Width=400;
% listviewCtrl.ColumnHeaders.Add;
% listviewCtrl.ColumnHeaders.Item(5).Text='Cols';
% listviewCtrl.ColumnHeaders.Item(5).Width=400;
%drawnow





function xpcmngrUserData=i_drawTargetCommConfigPanel(xpcmngrUserData)
%feature('JavaFigures',1)
figH=xpcmngrUserData.figure;
fpos=get(figH,'Position');
tree=xpcmngrUserData.treeCtrl;
viewPanelArea=i_calcPanelViewableArea(figH,tree);
left=viewPanelArea(1);
left=left+5;
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
deltaX_ax=50;
deltaY_ax=40;
VertDelta=50;
xpos=left+deltaX_ax;

tgEnv=xpcGetTarget(xpcmngrUserData.treeCtrl);

defc={'tg' 'bio' 'pt'};
isf=[isfield(tgEnv,'tg') isfield(tgEnv,'bio') isfield(tgEnv,'pt')];
tgEnv=rmfield(tgEnv,defc(isf));

%tgEnv = tree.currentenv;
objpropcell=fieldnames(tgEnv);
objpropcell=objpropcell(7:end);

tgdlgparams=objpropcell;
tgparValues = struct2cell(tgEnv);
tgparValues = tgparValues(7:end);

AxDelta=(allowdHeight/length(tgdlgparams));


deltaptpair=0;
%xpcmngrUserData=i_createMngrSubTabCtrl(xpcmngrUserData)
%createCommPairParams:
compropcell=objpropcell(5:end-4);
%compropcellVal=cellstr(char(objstruct.actpropval(11:end-4)));
compropcellVal=tgparValues(5:end-4);

% if ~isempty(tree.SelectedItem)    
%    
% end
    
if findstr('TGconfigCOMM',tree.SelectedItem.Key)
    tgpcName=tree.selectedItem.parent.parent.Text;
    set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgpcName,' Communication Component '])
    tgdlgparams = compropcell;
    tgparValues = compropcellVal;
    %tgparValues
    if strcmp(tgparValues{1},'TcpIp')
        tgdlgparams = tgdlgparams([1 4:end]);
        tgparValues = tgparValues ([1 4:end]);

        if strcmp(tgparValues{7},'PCI')
            tgdlgparams=tgdlgparams(1:end-2);
            tgparValues = tgparValues ([1:end-2]);
        else%ISA
            tgdlgparams=tgdlgparams(1:end);
            tgparValues = tgparValues ([1:end]);
        end
    end
    if strcmpi(tgparValues{1},'RS232')
        tgdlgparams=tgdlgparams(1:3);
        tgparValues = tgparValues ([1:3]);
    end
end

if findstr('TGconfigSets',tree.SelectedItem.Key)
    tgpcName=tree.selectedItem.parent.parent.Text;
    set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgpcName,' Settings Component '])
    tgdlgparams=objpropcell(1:4);
    tgparValues=getxpcenv(tgdlgparams{:});
end


if findstr('TGconfigDisp',tree.SelectedItem.Key)
    tgpcName=tree.selectedItem.parent.parent.Text;
    set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgpcName,' Appearance Component '])
    tgdlgparams=objpropcell(17:18);
    tgparValues=getxpcenv(tgdlgparams{:});
end

if findstr('TGconfig',tree.SelectedItem.Key) & ...
   findstr('Configuration',tree.SelectedItem.Text)

    tgpcName=tree.selectedItem.parent.Text;
    set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgpcName,' Target Configuration '])

%     tgdlgparams=objpropcell(end-2:end-1);
%     tgparValues=getxpcenv(tgdlgparams{:});
    xpcmngrUserData=i_drawConfigTarget(xpcmngrUserData);
    set(xpcmngrUserData.figure,'UserData',xpcmngrUserData);
    return
end
%%%%%%%%%%%%[left+5,buttom+2,allowdWidth-10,allowdHeight+40]
 %fdeltaptpair=0;
%  yfpos1=(buttom+allowdHeight)-60;
%  for i=1:length(tgdlgparams)-1
%       fdeltaptpair=120;
%       yfpos1=yfpos1-fdeltaptpair;
%  end
%yfpos1=
%yframepos=allowdHeight-(length(tgdlgparams)*120+60);
%yframepos=buttom+(length(tgdlgparams)*120);
hframepos=length(tgdlgparams)*60;
%buttom+2+allowdHeight+length(tgdlgparams)*35;
% panelframeH=uicontrol('Style','Frame',...
%                        'Position',[left+5,yframepos,allowdWidth-10,hframepos],...
%                        'String','Parameters','Parent',figH,'Tag','Resize_tag');
%%%%%%%%%%%%%%%%%
deltaptpair=30;
fypos1=[];
fypos1=(buttom+allowdHeight-15);
for i=1:length(tgdlgparams)
    deltaptpair=60;
    fypos1=fypos1-deltaptpair;
end
deltaptpair=60;
%  panelframeH=uicontrol('Style','Frame',...
%                        'Position',[left+7,fypos1+20,allowdWidth-10,hframepos+20+25],...
%                        'ForeGroundColor','w',...
%                        'String','Parameters','Parent',figH,'Tag','Resize_UI_tag');
%%%%%%%%%%%%%%%%%


ypos1=[];
ypos1=(buttom+allowdHeight+30);
% compText=tree.SelectedItem.Text;
% h=uicontrol(figH,'Style','Text',...
%     'String',[compText,' Component:' ],...
%     'FontWeight','Bold',...
%     'HorizontalAlignment','Left',...
%     'Position',[left+15,fpos(4)-60,200,25]);

for i=1:length(tgdlgparams)    
    paramstr=getuiparamstr(tgdlgparams{i});    
    h=uicontrol(figH,'style','text','units','Pixels',...
                'string',paramstr,'HorizontalAlignment','Left',...
                'BackGroundColor', get(figH,'Color'),...
                'position',[left+15,ypos1,allowdWidth-40,15],'Tag','Resize_UI_tag');

    [style,stylestr,xpcval]=getuiStyle(tgdlgparams{i},tgEnv);

    h=uicontrol(figH,'Style',style,'units','Pixels','string',stylestr,...
                'HorizontalAlignment','Left','BackgroundColor',[1,1,1],...
                'position',[left+15,ypos1-(25),allowdWidth-40,20],...
                'Callback',{@applySettings,figH},...%{@keypress figH}
                'value',xpcval,'Tag',tgdlgparams{i});
    
    if strcmp(tgdlgparams{i},'HostTargetComm')
        set(h,'CallBack',{@hosttargetCommCallback figH});
    end
    if strcmp(tgdlgparams{i},'TcpIpTargetBusType')
        set(h,'CallBack',{@hosttargetCommCallback figH});
    end    
    deltaptpair=60;
    ypos1=ypos1-deltaptpair;
end
set(findobj(xpcmngrUserData.figure,'Type','Uicontrol'),'Units','Normalized');
% h=uicontrol(figH,'style','PushButton','units','Pixels',...
%                  'string','Apply','HorizontalAlignment','Center',...
%                  'enable','off',...
%                  'Callback',{@applySettings figH},...
%                  'position',[left+15+allowdWidth-100,buttom+10,60,20],'Tag','Resize_tag_Apply');
%
% h=uicontrol(figH,'style','PushButton','units','Pixels',...
%                  'string','Help','HorizontalAlignment','Center',...
%                  'Callback','',...
%                  'position',[left+15+allowdWidth-100-65,buttom+10,60,20],'Tag','Resize_Man_Help');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xpcmngrUserData=i_drawTgAppConfigPanel(xpcmngrUserData,tg)
%%%Create the tg app Configuration parameter dialgog properties:
fpos=get(xpcmngrUserData.figure,'Position');
figH=xpcmngrUserData.figure;
tree=xpcmngrUserData.treeCtrl;
viewPanelArea=i_calcPanelViewableArea(figH,tree);
left=viewPanelArea(1);
left=left+10;
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
%[fig_rect(3)/3 fig_rect(4)-45+20 fig_rect(3)-fig_rect(3)/3 25]
%fpos(4)-45-25-25-25  26MSCOMctlLib.listViewCtrl.2
%listViewPos=[left 20+fpos(4)/2 fpos(3)-(fpos(3)/3)-40+15-350
%fpos(4)-50-fpos(4)/2];
tgName=tree.SelectedItem.Parent.Text;
set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgName,' Target Application Properties'])

listViewPos=[left 20 ((fpos(3)-left)/2) fpos(4)-50];
xpcmngrUserData.tgapplistCtrl=actxcontrol('MWXPCControls.listviewctrl',...
             listViewPos,xpcmngrUserData.figure);
%xpcmngrUserData.tg.pt.allH{end+1}=listviewCtrl;
tg=gettg(xpcmngrUserData.treeCtrl);
xpcmngrUserData.tgapplistCtrl.GridLines=0;
%xpcmngrUserData.tgapplistCtrl.LabelEdit='lvwManual';
%xpcmngrUserData.listCtrl.LabelEdit='lvwManual';
xpcmngrUserData.tgapplistCtrl.FullRowSelect=1;
xpcmngrUserData.tgapplistCtrl.OLEDropMode=1;
%xpcmngrUserData.tgapplistCtrl.View='lvwReport';
xpcmngrUserData.tgapplistCtrl.View=3;
xpcmngrUserData.tgapplistCtrl.HideColumnHeaders=1;
xpcmngrUserData.tgapplistCtrl.ColumnHeaders.Add;
set(xpcmngrUserData.tgapplistCtrl.ColumnHeaders.Item(1),'Width',200);
xpcmngrUserData.tgapplistCtrl.ColumnHeaders.Add;
set(xpcmngrUserData.tgapplistCtrl.ColumnHeaders.Item(2),'Width',175);
%xpcmngrUserData.listCtrl.HideColumnHeaders=1;
list=xpcmngrUserData.tgapplistCtrl;
list.labelEdit=1;

list.Font.Size=11;
%list.Font.Bold=1;
le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='Application';%1
set(list.ListItems.Item(1).listsubItems.Item(1),'Text',tg.Application)

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='CPUOverload';%2
set(list.ListItems.Item(2).listsubItems.Item(1),'Text',tg.CPUOverload)

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='ExecTime';%3
set(list.ListItems.Item(3).listsubItems.Item(1),'Text',sprintf('%0.4f',tg.ExecTime))

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='MinTET';%4
set(list.ListItems.Item(4).listsubItems.Item(1),'Text',sprintf('%0.2f',tg.minTeT))

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='MaxLogSamples';%5
set(list.ListItems.Item(5).listsubItems.Item(1),'Text',sprintf('%d',tg.MaxLogSamples))

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='NumLogWraps';%6
set(list.ListItems.Item(6).listsubItems.Item(1),'Text',sprintf('%d',tg.NumLogWraps))

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='NumScopes';%7
set(list.ListItems.Item(7).listsubItems.Item(1),'Text',sprintf('%d',length(tg.Scopes)))


le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='NumSignals';%8
set(list.ListItems.Item(8).listsubItems.Item(1),'Text',sprintf('%d',tg.NumSignals))

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='NumParameters';%7
set(list.ListItems.Item(9).listsubItems.Item(1),'Text',sprintf('%d',tg.NumParameters))




deltaX_ax=50;
deltaY_ax=40;
VertDelta=50;
xpos=left+deltaX_ax;


tgappstruct=set(tg);
tgdlgparams=fieldnames(tgappstruct);
tgdlgparams=tgdlgparams(1:4);
tgparValues= get(tg,tgdlgparams);
AxDelta=(allowdHeight/length(tgdlgparams));
deltaptpair=0;
ypos1=(buttom+allowdHeight)-deltaptpair+30;
for i=1:length(tgdlgparams)
    deltaptpair=60;
    ypos1=ypos1-deltaptpair;
end
xpos=left + ((fpos(3)-left)/2) + 10;
ypos1=(buttom+allowdHeight)-deltaptpair+30;
width=fpos(3)-xpos-20;
panelframeH=uicontrol('Style','Frame',...
                      'Position',[xpos-5,22,width+25,fpos(4)-55],...
                      'BackGroundColor', get(figH,'Color'),...
                      'String','Parameters','Parent',figH,'Tag','uiFrame');
set(panelframeH,'Units','Normalized')

deltaptpair=0;
ypos1=(buttom+allowdHeight)-deltaptpair+30;
%ypos1=20+fpos(4)/2-40-deltaptpair;
%xpos=left + fpos(3)-(fpos(3)/3)-40+15-350 +10;
for i=1:length(tgdlgparams)
    paramstr=getuiparamstr(tgdlgparams{i});    
    h=uicontrol(figH,...
        'style','text',...
        'BackGroundColor', get(figH,'Color'),...
        'units','Pixels',...
        'string',paramstr,...
        'HorizontalAlignment','Left',...
        'position',[xpos,ypos1,width,15]);%left+15
    if strcmp('ViewMode',tgdlgparams{i})
       style='PopupMenu';
       string=[{'All'};cellstr(num2str(xpcgate(tg.port,'getscopes','target')'))];
    else
       style='Edit';
       string=tgparValues{i};
    end

    h=uicontrol(figH,...
        'style',style,...
        'units','Pixels',...
        'string',string,...
        'Tag',tgdlgparams{i},...
        'HorizontalAlignment','Left',...
        'Callback',{@apptgConfig tg},...
        'BackgroundColor',[1,1,1],...
        'position',[xpos,ypos1-(25),width,20]);

%     if strcmp('ViewMode',tgdlgparams{i})
%         cstr=[{'All'};cellstr(num2str(tg.scopes'))];
%         set(h,'Style','PopupMenu',...
%             'String',cstr);
%     end
    deltaptpair=60;
    ypos1=ypos1-deltaptpair;
end

set(findobj(xpcmngrUserData.figure,'Type','Uicontrol'),'Units','Normalized');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function viewPanelArea=i_calcPanelViewableArea(figH,tree)
%[x1(starting poing from left of tree),
% y1(starting point ftom buttom of fig),
% x2(width remaining in the figure of viewable area to draw in)
% y2)height of viewable area in the figure to draw in)
fH=handle(figH);
figHPos=fH.Position;
treePos=move(tree);
buttomYLen=25;
topYlen=80;
viewPanelArea=[treePos(3), buttomYLen,figHPos(3)-treePos(3), figHPos(4)-(buttomYLen+topYlen)];
%uicontrol('style','Listbox','position',[viewPanelArea(1)
%viewPanelArea(2)+50 200 100],'parent',figH)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [style,stylestr,xpcval]=getuiStyle(propType,tgEnv)
propStr=propType;
switch propStr,

case 'TargetRAMSizeMB'
    %style='popupMenu';
    %stylestr={'Auto';'Manual'};
    %xpcval=strmatch(getfield(tgEnv,propType),stylestr);
    style='edit';
    stylestr=getfield(tgEnv,propType);
    xpcval=[];
case 'MaxModelSize'
    style='popupMenu';
    stylestr={'1MB';'4MB';'16MB'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
case 'SystemFontSize'
    style='popupMenu';
    stylestr={'Small';'Large'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
case 'CANLibrary'
    style='popupMenu';
    stylestr={'None';'200 ISA';'527 ISA';'1000 PCI';'1000 MB PCI';'PC104'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
case 'HostTargetComm'
    style='popupMenu';
    stylestr={'TcpIp';'RS232'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
case 'RS232HostPort'
    style='popupMenu';
    stylestr={'COM1';'COM2'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
case 'RS232Baudrate'
    style='popupMenu';
    stylestr={'115200';'57600';'38400';'19200';'9600';'4800';'2400';'1200'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
case 'TcpIpTargetAddress'
    style='edit';
    stylestr=getfield(tgEnv,propType);
    xpcval=[];
case 'TcpIpTargetPort'
    style='edit';
    stylestr=getfield(tgEnv,propType);
    xpcval=[];
case 'TcpIpSubNetMask'
    style='edit';
    stylestr=getfield(tgEnv,propType);
    xpcval=[];
case 'TcpIpGateway'
    style='edit';
    stylestr=getfield(tgEnv,propType);
    xpcval=[];
case 'TcpIpTargetDriver'
    style='popupMenu';
    stylestr={'NE2000';'SMC91C9X';'I82559';'RTLANCE'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
case 'TcpIpTargetBusType'
    style='popupMenu';
    stylestr={'ISA';'PCI'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
case 'TcpIpTargetISAMemPort'
    style='edit';
    stylestr=getfield(tgEnv,propType);
    xpcval=[];
case 'TcpIpTargetISAIRQ'
    style='popupMenu';
    stylestr={'5';'6';'7';'8';'9';'10';'11';'12';'13';'14'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
case 'TargetScope'
    style='popupMenu';
    stylestr={'Disabled';'Enabled'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
case 'TargetMouse'
    style='popupMenu';
    stylestr={'None';'PS2';'RS232 COM1';'RS232 COM2'};
    xpcval=strmatch(getfield(tgEnv,propType),stylestr);
otherwise,
    error('Invalid Property');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_HidePanelChildObj(figH)
%children=get(xpcmngrUserData.figure,'Children');
children=findobj(figH,'Type','uicontrol');
if ~isempty(children)
    delete(children)
end
xpcmngrUserData=get(figH,'Userdata');
if isa(xpcmngrUserData.listCtrl,'COM.MSCOMctlLib_listViewCtrl_2')
    delete(xpcmngrUserData.listCtrl)
    xpcmngrUserData.listCtrl=[];
end
if isa(xpcmngrUserData.tgapplistCtrl,'COM.MWXPCControls_listviewctrl')
    delete(xpcmngrUserData.tgapplistCtrl)
    xpcmngrUserData.tgapplistCtrl=[];
end

if isa(xpcmngrUserData.scidlistCtrl,'COM.MWXPCControls_listviewctrl')
    delete(xpcmngrUserData.scidlistCtrl)
    xpcmngrUserData.scidlistCtrl=[];
end
set(figH,'UserData',xpcmngrUserData)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function apptgConfig(src,evt,tg)
%tg=gettg(tree);
uiStyle=get(src,'Style');
tgpropfield=get(src,'Tag');

switch tgpropfield,

    case 'StopTime'
        currValstr=get(src,'String');
        try
           newval=eval(currValstr);
        catch
           errordlg('Stop Time must be a scalar Number','xPC Target Error')
           set(src,'String',num2str(tg.Stoptime))
           return
        end
        oldval=tg.Stoptime;
        if ~(oldval==newval)
            tg.Stoptime=newval;
            if (tg.stoptime==inf)
               set(src,'String','Inf')
            end
        end

    case 'SampleTime'
        currValstr=get(src,'String');
        try
           newval=eval(currValstr);
        catch
           errordlg('Sample Time must be a scalar Number','xPC Target Error')
           set(src,'String',num2str(tg.SampleTime))
           return
        end
        oldval=tg.SampleTime;
        if ~(oldval==newval)
            try
                tg.SampleTime=newval;
            catch
                errordlg(lasterr,'xPC Target Error')
            end
        end


    case 'ViewMode'
        cstr=get(src,'String');
        uiVal=get(src,'Value');
        selStr=cstr{uiVal};
        oldval=tg.ViewMode;
        if strcmp(selStr,'All')
            newval='All';
        else
            newval=eval(selStr);
        end
        tg.ViewMode=newval;
    case 'LogMode'

    otherwise

end

if strcmp(uiStyle,'edit')
    tgvalnowstr=get(src,'String');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function applySettings(src,evt,figH)
allChildrenObj=findobj(figH,'Type','uicontrol');
statTxtH=findobj(allChildrenObj,'Style','text');
pbH=findobj(allChildrenObj,'Style','pushButton');
comH=setdiff(allChildrenObj,[statTxtH;pbH]);
%oldstr=get(comH,'String');
%oldVal=get(comH,'Value');
xpcmngrUserData=get(figH,'Userdata');
tree=xpcmngrUserData.treeCtrl;
targetpcMap=tree.TargetPCMap;
tgEnv = xpcGetTarget(tree);
%tgEnv=tree.currentenv;

targetNameStr = tree.lastSelectedTarget;
targetpcMap=tree.TargetPCMap;
idxfound=strmatch(targetNameStr,targetpcMap(:,2),'exact');
treetgpcstr=targetpcMap{idxfound,1};

for i=1:length(comH)
    comFieldTag=get(comH(i),'Tag');
    comFieldVal=get(comH(i),'Value');
    comFieldString=get(comH(i),'String');
    if ~isempty(comFieldVal)%parameter is a popmenufield
        comFieldString=get(comH(i),'String');
        oldpar=eval(['tgEnv.',comFieldTag]);
        newpar=comFieldString{comFieldVal};
    else
        oldpar=eval(['tgEnv.',comFieldTag]);
        newpar=comFieldString;
    end

    if ~strcmp(oldpar,newpar)%changes made apply them
         evalstr=['tree.Targets.',treetgpcstr,'.',comFieldTag,' = newpar;'];
         eval(evalstr);
        % set(src,'enable','off')
    end
end
%tgEnv=xpcmngrUserData.treeCtrl.currentenv;
tgEnv=xpcGetTarget(xpcmngrUserData.treeCtrl);
savexpceplrEnv(tgEnv)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hosttargetCommCallback(src,evt,figH)
%get(src,'String')
applySettings(src,[],figH);
i_HidePanelChildObj(figH);
i_drawTargetCommConfigPanel(get(figH,'Userdata'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function createblockptdlg(xpcblockptinfo,blkName,xpcmngrUserData,tg);
% xpcblockptinfo fields:
%     type
%     blockname
%     paramname
%     class
%     nrows
%     ncols
%     subsource

figH=xpcmngrUserData.figure;
fpos=get(figH,'Position');
tree=xpcmngrUserData.treeCtrl;
viewPanelArea=i_calcPanelViewableArea(figH,tree);
left=viewPanelArea(1);
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);

deltaX_ax=50;
deltaY_ax=40;
VertDelta=50;
xpos=left+deltaX_ax;
%xpcblockptinfo
% tgdlgparams=fieldnames(tgappstruct);
% tgdlgparams=tgdlgparams(1:4);
% tgparValues= get(tg,tgdlgparams);

deltaptpair=30;
fypos1=[];
fypos1=(buttom+allowdHeight);
for i=1:length(xpcblockptinfo)
    deltaptpair=60;
    fypos1=fypos1-deltaptpair;
end
deltaptpair=60;
ypos1=[];
ypos1=(buttom+allowdHeight);

AxDelta=(allowdHeight/length(xpcblockptinfo));
% panelframeH=uicontrol('Style','Frame',...
%                       'Position',[left+5,buttom+2,allowdWidth-10,allowdHeight+40],...
%                       'String','Parameters','Parent',figH);

deltaptpair=0;
ypos1=(buttom+allowdHeight)-deltaptpair+30;
pteditusrdata.ptdlg=figH;
pteditusrdata.pteditui=[];
str1=['Block Parameters: ',tree.SelectedItem.Text];
str2=['BlockPath: ', tree.SelectedItem.tag];
str= [str1,sprintf('\n'),str2];
%blockPath=tree.SelectedItem.Text;
blockPath=tree.SelectedItem.tag;
set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',...
    ['Block Parameters: ',tree.SelectedItem.key(findstr(':SlBlock:',tree.SelectedItem.key)+10:end)])
% h=uicontrol(figH,'Style','Text',...
%     'String',str,...
%     'FontWeight','Bold',...
%     'HorizontalAlignment','Left',...
%     'Position',[left+15,fpos(4)-50,fpos(3),25]);
% set(h,'Units','Normalized')


%---------create parameter dialog------------------
for i=1:length(xpcblockptinfo)
    paramname=xpcblockptinfo(i).paramname;
    paridx=tg.getparamid(blkName,paramname);
    parval=tg.getparam(paridx);
    parvalstr=mat2str(parval);
    %parvalstr=deblank(sprintf('%d  ',parval));

    h=uicontrol(figH,...
                'style','text','units','Pixels',...
                'BackGroundColor', get(figH,'Color'),...
                'position',[left+15,ypos1,allowdWidth-70,15],...
                'string',[paramname,':'],'HorizontalAlignment','Left');

    h=uicontrol(figH,'style','edit','units','Pixels',...
                'position',[left+15,ypos1-(25),allowdWidth-70,20],...
                'string',parvalstr,'HorizontalAlignment','Left',...
                'BackgroundColor',[1,1,1]);
%     hAviewer=uicontrol(figH,'style','pushbutton','units','Pixels',...
%                 'Position',[left+15+allowdWidth-70+10,ypos1-(25),25,20],...
%                 'string','...');


    if(feature('Javafigures'))
       set(h,'KeyPress',{@pteditcallback figH});
    end
    deltaptpair=60;
    ypos1=ypos1-deltaptpair;
%     x=ones(3,3)
%     openvar('x')
   % pteditusrdata.pteditui(i)=h;
    usrdata.blockName=blkName;
    usrdata.paramname=paramname;
    set(h,'Userdata',usrdata);
    set(h,'callback',{@setxpcparam,usrdata,tg});
    %refpointpos=[3.8,refpointpos(2)-4,72.4,2];
end
set(findobj(xpcmngrUserData.figure,'Type','Uicontrol'),'Units','Normalized');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function setxpcparam(h,evt,usrdata,tg)
%tg=gettg(tg)
ptdlgusrData=get(h,'userdata');
%ptdlgfigH=ptdlgusrData.ptdlg;
%pteditsh=ptdlgusrData.pteditui;
%numofParams=length(ptdlgusrData.pteditui);

        %pth=pteditsh(i);
        blkName = usrdata.blockName;
        ptName  = usrdata.paramname;
        ptstrVal = get(h,'String');

        ptidx=tg.getparamid(blkName,ptName);
        xpcptVal = tg.getparam(ptidx);

        try
            ptVal = eval(ptstrVal);
        catch
            errordlg('Parameter can not be evaluated','xPC Target Error')
            set(h,'String',mat2str(xpcptVal));
            return
        end

%         if ~(ptVal == xpcptVal)
%             tg.setparam(ptidx,ptVal);
%         end

        if (find(~(ptVal == xpcptVal)))
            tg.setparam(ptidx,ptVal);
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pteditcallback(h,evt,figh)
applyBH=findobj(figh,'Type','UIControl','Tag','PressApply');
set(applyBH,'Enable','on')


function keypress(src,evt,figH)
appB=findobj(figH,'Type','UIControl','Style','Pushbutton','String','Apply');
set(appB,'Enable','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_createHostConfigdlgPanel(xpcmngrUserData);
tree=xpcmngrUserData.treeCtrl;
if ~findstr('Compiler',tree.SelectedItem.Text)
    return
end
figH=xpcmngrUserData.figure;
viewPanelArea=i_calcPanelViewableArea(figH,tree);
left=viewPanelArea(1);
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
deltaX_ax=50;
deltaY_ax=40;
VertDelta=50;
xpos=left+deltaX_ax;

ypos1=(buttom+allowdHeight+30);

set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text','(Host PC) Compiler Configuration')
h=uicontrol('parent',figH,...
    'Style','Text',...
    'String','Select C compiler:',...
    'BackGroundColor', get(figH,'Color'),...
    'Tag','Resize_UI_tag',...
    'HorizontalAlignment','Left',...
    'Position',[left+15,ypos1,allowdWidth-40,15]);

CCcomStr={'VisualC','Watcom'};
%ccPath=getxpcenv('CompilerPath');
h=uicontrol('parent',figH,...
    'Style','PopupMenu',...
    'String',{'VisualC','Watcom'},...
    'Tag','CCompiler',...
    'Value',strmatch(getxpcenv('CCompiler'),CCcomStr),...
    'callback',@sethostcallback,...
    'HorizontalAlignment','Left',...
    'BackgroundColor',[1,1,1],...
    'Position',[left+15,ypos1-25,allowdWidth-40,15]);

h=uicontrol('parent',figH,...
    'Style','Text',...
    'String','Compiler Path:',...
    'Tag','CCompiler',...
    'BackGroundColor', get(figH,'Color'),...
    'HorizontalAlignment','Left',...
    'Position',[left+15,ypos1-60,allowdWidth-40,15]);

h1=uicontrol('parent',figH,...
    'Style','Edit',...
    'Tag','CompilerPath',...
    'String',getxpcenv('CompilerPath'),...
    'callback',@sethostcallback,...
    'HorizontalAlignment','Left',...
    'BackgroundColor',[1,1,1],...
    'Position',[left+15,ypos1-85,allowdWidth-100,20]);

h=uicontrol('parent',figH,...
    'Style','PushButton',...
    'Tag','Resize_UI_tag',...
    'String','Browse...',...
    'callback',{@setccbrowser,h1},...
    'Position',[left+15 + allowdWidth-100 + 5,ypos1-85,50,20]);

set(findobj(xpcmngrUserData.figure,'Type','Uicontrol'),'Units','Normalized');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setccbrowser(src,evt,ccEditH)
dirName=uigetdir(pwd,'Locate your compiler root directory');
if (dirName==0)
   return
end
set(ccEditH,'String',dirName)
setxpcenv('Compilerpath',dirName)
updatexpcenv(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sethostcallback(src,evt,figH)
type=get(src,'Tag');
if strcmp(type,'CompilerPath')
    dirName=get(src,'String');
    setxpcenv('Compilerpath',char(dirName))
    updatexpcenv(1);
end

if strcmp(type,'CCompiler')
   strcell=get(src,'string');
   val=get(src,'Value');
   cc=strcell{val};
   setxpcenv('CCompiler',cc)
   updatexpcenv(1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_drawConfigTarget(xpcmngrUserData)
tree=xpcmngrUserData.treeCtrl;
figH=xpcmngrUserData.figure;
fpos=get(figH,'Position');
viewPanelArea=i_calcPanelViewableArea(figH,tree);
left=viewPanelArea(1);
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
deltaX_ax=50;
deltaY_ax=40;
VertDelta=50;
%xpos=left+deltaX_ax;

ypos1=(buttom+allowdHeight);

xpos=left + ((fpos(3)-left)/2) + 10;
%ypos1=(buttom+allowdHeight)-deltaptpair+30;
width=fpos(3)-xpos-20;

strtext=['The Configuration is a set of Configuration Components that',...
    ' individually define specific settings for a paritcular xPC target system.'...
    ' After configuring your xPC Target Component,select from the target boot option',...
    ' and create the bootdisk for the xPC Target system'];

% ax=axes('Visible','off','Parent',figH);
%     %'Position',[left+10,75+200-60,allowdWidth-40,25]);
% set(ax,'Units','Normalized')
%
% h=text('parent',ax,...
%     'Interpreter','tex',...
%     'position',[0.4 1],...
%     'BackGroundColor','w',...
%     'String',strtext);
listViewPos=[left+10 23 (fpos(3)-left)/2 fpos(4)-50];
panelframeH=uicontrol('Style','Frame',...
                      'Position',listViewPos,...
                      'BackGroundColor', get(figH,'Color'),...
                      'String','Parameters','Parent',figH,'Tag','uiFrame1');
set(panelframeH,'units','normalized')

h=uicontrol('parent',figH,...
    'Style','Text',...
    'String',strtext,...
    'BackGroundColor','w',...
    'Tag','Edit1',...
    'HorizontalAlignment','Left',...
    'Position',[listViewPos(1)+5 listViewPos(2)+5 listViewPos(3)-10 listViewPos(4)-10]);
set(h,'units','Normalized');
% %
% xpcmngrUserData.rtfCtrl=actxcontrol('RichText.richtextCtrl.1',[left+10,75+200,allowdWidth-40,allowdHeight-200],figH);
% xpcmngrUserData.rtfCtrl.LoadFile([xpcroot,'\xpc\xpcmngr\Resources\tgconfig.rtf']);
% xpcmngrUserData.rtfCtrl.BorderStyle='rtfNoBorder';
%ax.ScrollBars='rtfBoth';
%xpcmngrUserData.rtfCtrl.Locked=1;

deltaptpair=0;
ypos1=(buttom+allowdHeight)-deltaptpair+ 20;

%[xpos-5,22,width+25,fpos(4)-55]

pframeH=uicontrol('Style','Frame',...
                  'Position',[xpos+5,23,width+10,fpos(4)-50],...
                  'BackGroundColor', get(figH,'Color'),...
                  'String','Parameters','Parent',figH,'Tag','uiFrame2');
set(pframeH,'units','normalized')


h=uicontrol('parent',figH,...
    'Style','Text',...
    'String','TargetBoot:',...
    'BackGroundColor', get(figH,'Color'),...
    'Tag','Resize_UI_tag',...
    'HorizontalAlignment','Left',...
    'Position',[xpos+20,ypos1,width-50,25]);


cellstr={'BootFloppy' 'DOSLoader' 'StandAlone'};
tgEnv=xpcGetTarget(tree);
%tgEnv = tree.currentenv;
tgbootidx=strmatch(tgEnv.TargetBoot,cellstr);

h=uicontrol('parent',figH,...
    'Style','PopUp',...
    'String',{'BootFloppy' 'DOSLoader' 'StandAlone'},...
    'BackGroundColor','w',...
    'Value',tgbootidx,...
    'callback',{@applytgboot,tree},...
    'Tag','Resize_UI_tag',...
    'HorizontalAlignment','Left',...
    'Position',[xpos+20,ypos1-25,width-20,25]);
if tgbootidx==3
    enablestr='off';
else
    enablestr='on';
end
h=uicontrol(figH,'style','PushButton',...
    'units','Pixels',...
    'string','Create BootDisk',...
    'HorizontalAlignment','Center',...
    'BackGroundColor', get(figH,'Color'),...
    'Callback',{@createbootdisk,tree},...
    'enable',enablestr,...
    'position',[xpos+10+width-120,ypos1-70,100,20],'Tag','Resize_tag_Apply');
set(findobj(xpcmngrUserData.figure,'Type','Uicontrol'),'Units','Normalized');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function applytgboot(src,evt,tree)
targetpcMap=tree.TargetPCMap;
tgName=tree.SelectedItem.Parent.text;
idxfound=strmatch(tgName,targetpcMap(:,2),'exact');
if isempty(idxfound)    
    errordlg('Error 122')
end
tgpcstr=targetpcMap{idxfound,1};
oldbootstr=eval(['tree.targets.',tgpcstr,'.TargetBoot;']);
tgbootcellstr=get(src,'String');
uiVal=get(src,'Value');
tgbootselstr=tgbootcellstr{uiVal};

evalstr=['tree.targets.',tgpcstr,'.TargetBoot=','''',tgbootselstr,''';'];
eval(evalstr);
uibootdisk=findobj(tree.figHandle,'Type','UIControl','Tag','Resize_tag_Apply');
tgEnv=xpcGetTarget(tree);
%tgEnv = tree.currentenv;
%tgEnv=rmfield(tgEnv,{'tg','bio','pt'});
savexpceplrEnv(tgEnv)

if strcmp(tgbootselstr,'StandAlone')
  set(uibootdisk,'enable','off')
  maxmdlsize=eval(['tree.targets.',tgpcstr,'.MaxModelSize']);
  if strcmp(maxmdlsize,'16MB')
      errordlg(['Creation of 16MB StandAlone applications not upported'],'xPC Target Error');
      return
  end
  tgEnv=xpcGetTarget(tree);
  %tgEnv = tree.currentenv;
  %tgEnv=rmfield(tgEnv,{'tg','bio','pt'});
  savexpceplrEnv(tgEnv)
else
  %setappdata(0,'xpcTargetexplrEnv',[])
  set(uibootdisk,'enable','on')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function savexpceplrEnv(tgEnv)
fldcell={'tg','bio','pt'};
idx=[isfield(tgEnv,'tg') isfield(tgEnv,'bio') isfield(tgEnv,'pt')];
fields=fldcell(idx);
tgEnv=rmfield(tgEnv,fields);
setappdata(0,'xpcTargetexplrEnv',tgEnv);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function createbootdisk(src,evt,tree)
figH=tree.figHandle;
xpcmngrUserData=get(figH,'UserData');
timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;  
stop(xpcmngrUserData.timerObj)
%tgEnv=tree.currentenv;
tgEnv=xpcGetTarget(tree);
actpropval=struct2cell(tgEnv);
actpropval=actpropval(1:25);
xpcbootdisk(1,0,actpropval);
timerreset(timerStatus,xpcmngrUserData.timerObj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_drawScopeIdPanel(xpcmngrUserData,sc)
figH=xpcmngrUserData.figure;
fpos=get(figH,'Position');
tree=xpcmngrUserData.treeCtrl;
viewPanelArea=i_calcPanelViewableArea(figH,tree);
left=viewPanelArea(1);
left=left+10;
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
deltaX_ax=50;
deltaY_ax=40;
VertDelta=50;
xpos=left+deltaX_ax;
if ~isempty(xpcmngrUserData.treeCtrl.SelectedItem)
    tgName=xpcmngrUserData.treeCtrl.SelectedItem.Parent.Parent.Parent.parent.Text;
    set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',[tgName,' Scope: ',num2str(sc.scopeid)])
    xpcmngrUserData.treeCtrl.scopeIdNodeIdx = xpcmngrUserData.treeCtrl.SelectedItem.Index;
end


listViewPos=[left 20 (fpos(3)-left)/2 fpos(4)-50];
xpcmngrUserData.scidlistCtrl=actxcontrol('MWXPCControls.listviewctrl',...
              listViewPos,xpcmngrUserData.figure);
xpcmngrUserData.scidlistCtrl.GridLines=0;
%xpcmngrUserData.tgapplistCtrl.LabelEdit='lvwManual';
%xpcmngrUserData.listCtrl.LabelEdit='lvwManual';
xpcmngrUserData.scidlistCtrl.FullRowSelect=1;
xpcmngrUserData.scidlistCtrl.OLEDropMode=1;
%xpcmngrUserData.tgapplistCtrl.View='lvwReport';
xpcmngrUserData.scidlistCtrl.View=3;
xpcmngrUserData.scidlistCtrl.HideColumnHeaders=1;
xpcmngrUserData.scidlistCtrl.ColumnHeaders.Add;
set(xpcmngrUserData.scidlistCtrl.ColumnHeaders.Item(1),'Width',100);
xpcmngrUserData.scidlistCtrl.ColumnHeaders.Add;
set(xpcmngrUserData.scidlistCtrl.ColumnHeaders.Item(2),'Width',150);
%xpcmngrUserData.listCtrl.HideColumnHeaders=1;
list=xpcmngrUserData.scidlistCtrl;
list.Font.Size=11;
list.labelEdit=1;
le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='ScopeID';%1
set(list.ListItems.Item(1).listsubItems.Item(1),'Text',sprintf('%d',sc.scopeid))

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='ScopeType';%2
set(list.ListItems.Item(2).listsubItems.Item(1),'Text',sc.Type)

le=list.ListItems.Add;
le.listsubItems.Add;
le.Text='Status';%3
set(list.ListItems.Item(3).listsubItems.Item(1),'Text',sc.Status)
deltaptpair=60;

ypos1=[];
ypos1=(buttom+allowdHeight);

scStruct=set(sc);
scStruct=rmfield(scStruct,'Signals');
scStruct=rmfield(scStruct,'TriggerSignal');
% if strcmp(sc.Type,'Host')
%     scProps=scProps([ ])
% end
% if strcmp(sc.Type,'Target')
%     scProps=scProps([ ])
% end
% if strcmp(sc.Type,'File')
%     scProps=scProps([ ])
% end
if strcmp(sc.TriggerMode,'FreeRun') | strcmpi(sc.TriggerMode,'Software')
    %scStruct=rmfield(scStruct,'TriggerSignal');
    scStruct=rmfield(scStruct,'TriggerSlope');
    scStruct=rmfield(scStruct,'TriggerLevel');
    scStruct=rmfield(scStruct,'TriggerScope');
    scStruct=rmfield(scStruct,'TriggerSample');
end

 if strcmp(sc.TriggerMode,'Signal')
    scStruct=rmfield(scStruct,'TriggerScope');
    scStruct=rmfield(scStruct,'TriggerSample');
 end

if strcmpi(sc.TriggerMode,'Scope')
    %scStruct=rmfield(scStruct,'TriggerSignal');
    scStruct=rmfield(scStruct,'TriggerSlope');
    scStruct=rmfield(scStruct,'TriggerLevel');
end


scProps=fieldnames(scStruct);

AxDelta=(allowdHeight/length(scProps));
%deltaptpair=0;




ypos1=(buttom+allowdHeight)-deltaptpair+30;
for i=1:length(scProps)
    deltaptpair=60;
    ypos1=ypos1-deltaptpair;
end
xpos=left + ((fpos(3)-left)/2) + 10;
ypos1=(buttom+allowdHeight)-deltaptpair+30;
width=fpos(3)-xpos-20;
panelframeH=uicontrol('Style','Frame',...
                      'Position',[xpos-5,22,width+25,fpos(4)-55],...
                      'BackGroundColor', get(figH,'Color'),...
                      'String','Parameters','Parent',figH,'Tag','uiFrame');
set(panelframeH,'Units','Normalized')

deltaptpair=0;
ypos1=(buttom+allowdHeight)-deltaptpair+30;

for i=1:length(scProps)
    cstr=eval(['set(sc,','''',scProps{i},''');']);
    if isempty(cstr)
        style='edit';
        val=eval(['sc.',scProps{i},';']);
        string=num2str(val);
        val=0;
        if strcmp(scProps{i},'Grid') | strcmp(scProps{i},'AutoRestart')
           style='checkbox';
           valstr=eval(['sc.',scProps{i},';']);
           if strcmp(valstr,'on')
               val=1;
           else
               val=0;
           end
           string=cstr;
        end
%         if strcmp(scProps{i},'TriggerSignal')
%             %sigids=sc.Signals;
%
%         end

    else
        style='PopupMenu';
        valstr=eval(['sc.',scProps{i},';']);
        val=strmatch(valstr,cstr);
        string=cstr;
    end
    paramstr=getuiparamstr(scProps{i});
    htext=uicontrol(figH,'style','text','units','Pixels',...
                    'BackGroundColor', get(figH,'Color'),...
                    'string',paramstr,'HorizontalAlignment','Left',...
                    'position',[xpos,ypos1,width,15],'Tag','Resize_UI_tag');

    h=uicontrol(figH,'Style',style,'units','Pixels','string',string,...
                'HorizontalAlignment','Left','BackgroundColor',[1,1,1],...
                'position',[xpos,ypos1-(25),width,20],...
                'KeyPressFcn',{@keypress figH},...
                'Callback',{@applyscprops,sc},...%{@keypress figH}
                'value',val,'Tag',scProps{i});
     if strcmp(scProps{i},'Grid')
        set(h,'position',[xpos,ypos1,10,15],...
            'BackGroundColor', get(figH,'Color'));
            ypos1=ypos1+30;
            set(htext,'Position',[xpos+30,ypos1-30,20,15])
            %ypos1=ypos1+30;
     end
     if strcmp(scProps{i},'TriggerSignal')
           set(h,'enable','off')
     end
     if strcmp(scProps{i},'YLimit')
           set(h,'String',['[',string,']']);
     end
     if strcmp(scProps{i},'AutoRestart')
        set(h,'position',[xpos,ypos1,10,15],'BackgroundColor',...
            get(0,'DefaultUicontrolBackgroundColor'));
         ypos1=ypos1+30;
        set(htext,'Position',[xpos+30,ypos1-30,80,15]);
            ypos1=ypos1+30;
            
     end

%     if strcmp(tgdlgparams{i},'Mode')
%         set(h,'CallBack',{@hosttargetCommCallback figH});
%     end
    deltaptpair=60;
    ypos1=ypos1-deltaptpair;
end
set(findobj(xpcmngrUserData.figure,'Type','Uicontrol'),'Units','Normalized');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function applyscprops(src,evt,sc)
uiStyle=get(src,'Style');
scpropfield=get(src,'Tag');

switch scpropfield,

    case 'NumSamples'
        currValstr=get(src,'String');
        try
        newval=eval(currValstr);
        catch
           errordlg('NumSamples must be a scalar Number','xPC Target Error')
           set(src,'String',num2str(sc.NumSamples))
           return
        end
        oldval=sc.NumSamples;
        if ~(oldval==newval)
                try
                    sc.NumSamples=newval;
                catch
                    errordlg(lasterr,'xPC Target Error')
                end
        end

    case 'Decimation'
        currValstr=get(src,'String');
        try
        newval=eval(currValstr);
        catch
           errordlg('Decimation must be a scalar Number','xPC Target Error')
           set(src,'String',num2str(sc.Decimation))
           return
        end
        oldval=sc.Decimation;
        if ~(oldval==newval)
            sc.Decimation=newval;
        end

    case 'TriggerMode'
        cstr=get(src,'String');
        uiVal=get(src,'Value');
        selStr=cstr{uiVal};
        oldval=sc.TriggerMode;
        sc.TriggerMode=selStr;
        figH=get(src,'Parent');
        i_HidePanelChildObj(figH)
        xpcmngrUserData=get(figH,'userdata');
        tree=xpcmngrUserData.treeCtrl;
        scidtreeIdx=tree.scopeIdNodeIdx;
        scidNode=tree.Nodes.Item(scidtreeIdx);        
        check=scidNode.Child;
        defCol=2147483656;
        trigCol=2111111;
        if strcmp(selStr,'FreeRun') | strcmp(selStr,'Software') | strcmp(selStr,'Scope')
            while ~isempty(check)
                check.ForeColor=defCol;
                check=check.Next;
            end
        elseif strcmp(selStr,'Signal')
            sigId=sc.triggerSignal;
            if (sigId > 0)
                sigName=xpcgate(sc.Port,'getsignalname',sigId);
                while ~isempty(check)
                    if strcmpi(check.Text,sigName)
                        check.ForeColor=trigCol;
                    else
                        check.ForeColor=defCol;
                    end
                    check=check.Next;
                end
            end
        end

        xpcmngrUserData=i_drawScopeIdPanel(xpcmngrUserData,sc);
        set(figH,'userdata',xpcmngrUserData)


    case 'TriggerSignal'

    case 'TriggerLevel'
        currValstr=get(src,'String');
        try
            newval=eval(currValstr);
        catch
           errordlg('TriggerLevel must be a scalar Number','xPC Target Error')
           set(src,'String',num2str(sc.TriggerLevel))
           return
        end
        oldval=sc.TriggerLevel;
        try
            if ~(oldval==newval)
                sc.TriggerLevel=newval;
            end
        catch
            errordlg(lasterr)
        end


    case 'TriggerSlope'
        cstr=get(src,'String');
        uiVal=get(src,'Value');
        selStr=cstr{uiVal};
        oldval=sc.TriggerSlope;
        sc.TriggerSlope=selStr;

    case 'TriggerScope'
        currValstr=get(src,'String');
        try
            newval=eval(currValstr);
        catch
           errordlg('TriggerScope must be a scalar Number','xPC Target Error')
           set(src,'String',num2str(sc.TriggerScope))
           return
        end
        oldval=sc.TriggerScope;
        try
            if ~(oldval==newval)
                sc.TriggerScope=newval;
            end
        catch
            errordlg(lasterr)
        end


    case 'TriggerSample'
        currValstr=get(src,'String');
        try
            newval=eval(currValstr);
        catch
           errordlg('TriggerSample must be a scalar Number','xPC Target Error')
           set(src,'String',num2str(sc.TriggerSample))
           return
        end
        oldval=sc.TriggerSample;
        try
            if ~(oldval==newval)
                sc.TriggerSample=newval;
            end
        catch
            errordlg(lasterr)
        end


    case 'NumPrePostSamples'
        currValstr=get(src,'String');
        try
            newval=eval(currValstr);
        catch
           errordlg('NumPrePostSamples must be a scalar Number','xPC Target Error')
           set(src,'String',num2str(sc.NumPrePostSamples))
           return
        end
        oldval=sc.NumPrePostSamples;
        try
            if ~(oldval==newval)
                sc.NumPrePostSamples=newval;
            end
        catch
            errordlg(lasterr)
        end


    case 'Mode'
        cstr=get(src,'String');
        uiVal=get(src,'Value');
        selStr=cstr{uiVal};
        oldval=sc.Mode;
        sc.Mode=selStr;

    case 'YLimit'
        currValstr=get(src,'String');
        try
           newval=eval(currValstr);
           oldval=sc.Ylimit;
           sc.YLimit=newval;
        catch
            errordlg(lasterr,'xPC Target Error')
            set(src,'String',['[',num2str(sc.YLimit),']'])
            return
        end


    case 'Grid'
        val=get(src,'Value');
        if (val == 1)
            sc.grid='On';
        else
            sc.grid='Off';
        end

    case 'Filename'
        currValstr=get(src,'String');
        oldval=sc.filename;
        try
            if ~(strcmp(oldval,currValstr))
                sc.filename=currValstr;
            end
        catch
            errordlg(lasterr)
        end


    case 'AutoRestart'
        val=get(src,'Value');
        if (val == 1)
            sc.AutoRestart='On';
        else
            sc.AutoRestart='Off';
        end
    case 'WriteSize'
        currValstr=get(src,'String');
        try
            newval=eval(currValstr);
        catch
           errordlg('WriteSize must be a scalar Number','xPC Target Error')
           set(src,'String',num2str(sc.WriteSize))
           return
        end
        oldval=sc.WriteSize;
        try
            if ~(oldval==newval)
                sc.WriteSize=newval;
            end
        catch
            errordlg(lasterr)
        end

    otherwise

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateMenus(figH,menuItem,state)
menuH=findobj(figH,'Type','UIMenu','Label',menuItem);
if ~isempty(menuH)
    set(menuH,'enable',state);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_drawsignals(xpcmngrUserData,tg,sigInfo)
figH=xpcmngrUserData.figure;
fpos=get(figH,'Position');
tree=xpcmngrUserData.treeCtrl;
viewPanelArea=i_calcPanelViewableArea(figH,tree);
left=viewPanelArea(1);
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);
deltaX_ax=50;
deltaY_ax=40;
VertDelta=50;
xpos=left+deltaX_ax;
sigViewPos=[left+10 20 allowdWidth fpos(4)-50];

dims=sigInfo.dim;
rows=dims(1);
cols=dims(2);
sigWidth=sigInfo.sigWidth;
% sigAx.FixedRows=0;
% sigAx.FixedCols=0;

sigName=sigInfo.blkName;


str1=['Signal Values: ',tree.SelectedItem.Text];
str2=['Signal Dim ', sprintf('[%d x %d]',dims(1),dims(2))];
str= [str1,sprintf('\n'),str2];

blockPath=tree.SelectedItem.tag;
set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',...
    ['Signal name: ',tree.SelectedItem.key(findstr(':SlBlock:',tree.SelectedItem.key)+10:end),...
     '   ',sprintf('[%d x %d]',dims(1),dims(2))]);




if (sigInfo.sigWidth == 1)
    sigid=tg.getsignalid(sigName);
    sigVals=tg.getsignal(sigid);
else
    for i=1:sigInfo.sigWidth
        sigid=tg.getsignalid([sigName,'/s',sprintf('%d',i)]);
        sigVals(i)=tg.getsignal(sigid);
    end
end
sigVals=reshape(sigVals,rows,cols);
[m,n]=size(sigVals);

%%%%
xpcmngrUserData.sigViewer=actxcontrol('MWXPCControls.mshflexgridCtrl',...
              sigViewPos,xpcmngrUserData.figure);

xpcmngrUserData.sigViewer.Clear;          
sigAx=xpcmngrUserData.sigViewer;
sigAx.FixedRows=1;
sigAx.FixedCols=1;
sigAx.AllowUserResizing='flexResizeBoth';
sigAx.BorderStyle='flexBorderSingle';
sigAx.Rows=rows+1;
sigAx.Cols=cols+1;
%%%%




sigAx.col=0;
for ii=1:rows
    sigAx.row=ii;
    sigAx.Text=sprintf('%d',ii);
end

sigAx.row=0;
for jj=1:cols
    sigAx.col=jj;
    sigAx.Text=sprintf('%d',jj);
end


for r=1:m
    sigAx.row=r;
    for c=1:n
        sigAx.col=c;
        sigAx.Text=sprintf('%0.2f',sigVals(r,c));
    %    sigAx.CellFontWidth =3;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function logstrst=getlogstatus(tg)
status=xpcgate(tg.port,'getlogstatus');
logstatusstr={'Off','Acquiring'};
if status(1) %if logging is turned on
    logtimecellstr={'','t '};logstatecellstr={'','x '};
    logopcellstr={'','y '};logtetcellstr={'','tet'};
    logstrst=[logtimecellstr{status(2)+1},logstatecellstr{status(3)+1}, ...
              logopcellstr{status(4)+1}, logtetcellstr{status(5)+1}];
else
logstrst = 'Off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=getuiparamstr(param)
xpcProps={'HostTargetComm','Host target communication:'; ...
       'RS232HostPort','RS-232 host port:';...
       'TargetScope','Target scope:';...  
       'Decimation','Decimation:';...
       'TargetMouse','Target mouse:';...
       'WriteSize','Write size:';...
       'Filename','File name:';...
       'AutoRestart','Auto restart:';...
       'RS232Baudrate','RS-232 baude rate:';...
       'MaxModelSize','Maximum model size:';...
       'CANLibrary','CAN library:';...
       'Mode','Mode:';...
       'StartTime','Start time:';...
       'Grid','Grid:';... 
       'YLimit','Y limits ([ymin,ymax]):';...
       'NumPrePostSamples','Number of  pre/post samples:';...
       'TriggerSignal','Trigger signal';...
       'TriggerSample','Trigger sample';...
       'TriggerLevel','Trigger level:';...
       'TriggerScope','Trigger scope:';...       
       'TriggerSlope','Trigger slope:';...
       'SystemFontSize','System font size:';...
       'TargetRAMSizeMB','Target RAM size (MB):';...
       'TcpIpTargetAddress','TcpIp target address:';...
       'TcpIpTargetPort','TcpIp target port:';...
       'TcpIpSubNetMask','TcpIp subnet mask address:';...
       'TcpIpGateway','TcpIp gateway address:';...
       'TcpIpTargetDriver','TcpIp target driver:';...
       'TcpIpTargetBusType','TcpIp target bus type:';...
       'TcpIpTargetISAMemPort' 'TcpIp target ISA memory port:';...
       'TcpIpTargetISAIRQ'     'TcpIp target ISA IRQ number:';...
       'TargetBoot'       'Target boot mode:';...
       'NumSamples'       'Number of samples:';...
       'TriggerMode'       'Trigger mode:';...
       'StopTime'       'Stop time:';...
       'SampleTime'       'Sample time:';...
       'ViewMode'       'View mode:';...
       'LogMode'       'Log mode:'};

idx=strmatch(param,xpcProps(:,1),'exact');
str=xpcProps{idx,2};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
function timerreset(chksum,timerObj)
if chksum==1
   start(timerObj)
else
   stop(timerObj)
end            
        
