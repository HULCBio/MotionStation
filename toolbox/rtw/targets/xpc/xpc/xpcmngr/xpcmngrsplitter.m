function xpcmngrsplitter(varargin)

% Copyright 2003-2004 The MathWorks, Inc.

sp=varargin{1};
varargin{end};
figH=sp.figH;
xpcmngrUserData=get(figH,'UserData');
if strcmp('MouseMove',varargin{end})
    if (sp.mouseDownOn==1)
        spH=findobj(figH,'Type','UIControl','Style','Frame','Tag','Splitter');
        if ~isempty(spH)
            spH;
            pos=xpcmngrUserData.Splitter.spFrPos;
            pos(1)=pos(1)+varargin{5};
            set(spH,'Position',pos);
            drawnow;
            x=varargin{5};
        end
        %disp('Moving')
        %treePos=move(xpcmngrUserData.treeCtrl);
        %treeWidth=treePos(3);
        %treeWidth=treePos(3)+varargin{5};
        %treePos(3)=treeWidth;
        %NtrPos=[treePos(1) treePos(2)
        % move(xpcmngrUserData.treeCtrl,treePos);
    end
    sp.MousePointer='ccSizeEW';
    get(sp.figh,'CurrentPoint');
    x=varargin{5};
    y=varargin{6};
    varargin;
    %     spH=findobj(figH,'Type','UIControl','Style','Frame','Tag','Splitter')
    %     ;
    %     if ~isempty(spH)
    %         pos=get(spH,'Position');
    %
    %         set(spH,'Position',[pos
end

if strcmp('MouseDown',varargin{end})
    sp.mouseDownOn=1;
    % sp.MousePointer='ccSizeEW';
    i_creatmotionSpiltter(xpcmngrUserData)
    % disp('mouseDown');
end
%splitPos=[(fig_rect(3)/3)-5 25 6 fig_rect(4)];
if strcmpi('MouseUp',varargin{end})    
    varX=varargin{5};
    try
        renderGUI(sp,xpcmngrUserData,varX)
    catch
        errordlg(lasterr)
        return
    end
end


function i_creatmotionSpiltter(xpcmngrUserData)
col=[0.6470588235294118, 0.6666666666666666,0.7450980392156863];
fig_rect=get(xpcmngrUserData.figure,'Position');
splitPos=move(xpcmngrUserData.Splitter);
%splitPos=[(fig_rect(3)/3)-5 25 6 fig_rect(4)];
xpcmngrUserData.Splitter.spFrame=uicontrol('Style','Frame',...
    'enable','on',...
    'Tag','Splitter',...
    'BackGroundColor',col,...
    'Foregroundcolor',col,...
    'Position',splitPos,'Parent',xpcmngrUserData.figure);
xpcmngrUserData.Splitter.spFrPos=splitPos;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function renderGUI(sp,xpcmngrUserData,varX)
figH=xpcmngrUserData.figure;
tree=xpcmngrUserData.treeCtrl;
fpos=get(figH,'Position');
sp.mouseDownOn=0;
sp.mouseDownUp=1;
treePos=move(tree);
splitPos=move(xpcmngrUserData.Splitter);
trbarPos=move(xpcmngrUserData.mdlHierachCtl);
subbarCtrlPos=move(xpcmngrUserData.subbarCtrl);
%treeWidth=treePos(3);
treeWidth=treePos(3)+varX;
treePos(3)=treeWidth;
splitPos(1)=treePos(3);
trbarPos(3)=treeWidth;
subbarCtrlPos(1)=splitPos(1)+5;
subbarCtrlPos(3)=fpos(3)-treeWidth-5;
%NtrPos=[treePos(1) treePos(2)
move(tree,treePos);
move(xpcmngrUserData.Splitter,splitPos);
move(xpcmngrUserData.mdlHierachCtl,trbarPos);
move(xpcmngrUserData.subbarCtrl,subbarCtrlPos);
spH=findobj(figH,'Type','UIControl','Style','Frame','Tag','Splitter');
delete(spH);
chUI=findobj(figH,'Type','UIControl');
set(chUI,'Units','Pixels');
oldchUIpos=get(chUI,'Position');
tempPos=cell2mat(oldchUIpos);

viewPanelArea=i_calcPanelViewableArea(figH,tree);
left=viewPanelArea(1);
left=left+10;
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);    


if findstr(tree.selecteditem.key,'HostPC')
   move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
   return
end

if ~isempty(findstr(tree.selecteditem.key,'pwdDLM')) | findstr(tree.selecteditem.key,'.dlm')
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end

if findstr(tree.selecteditem.key,'MDLH')
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end

if findstr(tree.selecteditem.key,'xPCSIG')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.sigViewer,[left 20 allowdWidth fpos(4)-50]);
    return
end
if findstr(tree.selectedItem.Tag,'xPCScopesNode')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end
if findstr(tree.selectedItem.key,'HostSc')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end

if findstr(tree.selectedItem.key,'FileSc')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end

if findstr(tree.selectedItem.key,'TgSc')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end

if findstr(tree.selectedItem.key,'TGPC')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.listCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end


if ~isempty(chUI)
    tempPos(:,1)=left;
    tempPos(:,3)=allowdWidth-40;    
    
    newchUIpos=mat2cell(tempPos,ones(size(tempPos,1),1),4);
    
   % set(chUI,'Visible','off')
    %xpos=left + ((fpos(3)-left)/2) + 10;
    if (~isempty(findstr(tree.selecteditem.key,'tgAppNode')) | ...
        ~isempty(findstr(tree.selecteditem.key,'HScid')) | ...
        ~isempty(findstr(tree.selecteditem.key,'TScid')) | ...
        ~isempty(findstr(tree.selecteditem.key,'FScid')))
         if isempty(xpcmngrUserData.scidlistCtrl)
             xpcmngrUserData.scidlistCtrl=handle(5);
         end
         if isempty(xpcmngrUserData.scidlistCtrl)
             xpcmngrUserData.tgapplistCtrl=handle(5);
         end         
        
        tempax=[xpcmngrUserData.scidlistCtrl xpcmngrUserData.tgapplistCtrl];
        ax=tempax([isa(tempax(1),'COM.MWXPCControls_listviewctrl') ...
                    isa(tempax(2),'COM.MWXPCControls_listviewctrl')]);
        
        x=move(ax,[left 20 (fpos(3)-left)/2 fpos(4)-50]);        
        left2=left+ x(3);
        tempPos(:,1)=left2 + 10;
        framidx=find(chUI==findobj(chUI,'style','Frame'));
        tempPos(framidx,1)=left2 + 5;
        
        if ~isempty(findobj(chUI,'string','Grid:'))
             grIdx=find(chUI==findobj(chUI,'string','Grid:'));
             tempPos(grIdx,1)=left2+30;
             tempPos(grIdx,3)=20;
        end
        if ~isempty(findobj(chUI,'string','Auto restart:'))
            auIdx=find(chUI==findobj(chUI,'string','Auto restart:'));        
            tempPos(auIdx,1)=left2+30;
            tempPos(auIdx,3)=80;
        end
        
        if ~isempty(findobj(chUI,'style','checkbox'))
            cbidx=find(chUI==findobj(chUI,'style','checkbox'));
            tempPos(cbidx,3)=10;
        end
        
        
        %newchUIpos=mat2cell(tempPos,ones(length(tempPos),1),4);
    end
    
    if findstr(tree.SelectedItem.key,'HostConf')
        bridx=find(chUI==findobj(chUI,'style','PushButton'));
        tempPos(bridx,1)=left+15 + allowdWidth-100 + 5;
        tempPos(bridx,3)= oldchUIpos{bridx}(3);
        ccidx=find(chUI==findobj(chUI,'Style','Edit','Tag','CompilerPath'));
        tempPos(ccidx,3)= tempPos(ccidx,3)-40;
    end
    
    if  ~isempty(findstr(tree.selectedItem.key,'TGconfig'))
        if ~isempty(findstr(tree.selectedItem.text,'Configuration'))
            fridx1=find(chUI==findobj(chUI,'style','Frame','Tag','uiFrame1'));
            fridx2=find(chUI==findobj(chUI,'style','Frame','Tag','uiFrame2'));        
            fr1pos=[left+10 23 (fpos(3)-left)/2 fpos(4)-50];
            tempPos(:,1)=fr1pos(1)+fr1pos(3)+20;  
            tempPos(:,3)= fpos(3) - (fr1pos(1)+fr1pos(3)+20);
            tempPos(fridx1,:)=fr1pos;
            edidx1=find(chUI==findobj(chUI,'style','text','Tag','Edit1'));
            %w=fpos(3) - (fr1pos(1)+fr1pos(3)+10);
            tempPos(edidx1,:) = [fr1pos(1)+5 fr1pos(2)+5 fr1pos(3)-10 fr1pos(4)-10];%w
            tempPos(fridx2,1)=fr1pos(1)+fr1pos(3)+10;        
            tempPos(fridx2,3)= fpos(3) - (fr1pos(1)+fr1pos(3)+10);
            cbdidx=find(chUI==findobj(chUI,'style','pushbutton'));
            tempPos(cbdidx,1)= fr1pos(1)+fr1pos(3)+20+ fr1pos(3)-120;
            tempPos(cbdidx,3)= (fpos(3)-(tempPos(cbdidx,1)));
        end
       % fpos(3) - (fr1pos(1)+fr1pos(3)+10);
        %fr1pos(1)+fr1pos(3)+(fpos(3) - (fr1pos(1)+fr1pos(3)+20))-120;
        
        
    end

    newchUIpos=mat2cell(tempPos,ones(size(tempPos,1),1),4);
    set(chUI,{'Position'},newchUIpos)
    set(chUI,'Units','Normalized')
end






function i_HidePanelChildObj(figH)
%children=get(xpcmngrUserData.figure,'Children');
children=findobj(figH,'Type','uicontrol');
if ~isempty(children)
    delete(children)
end
xpcmngrUserData=get(figH,'Userdata');
if isa(xpcmngrUserData.listCtrl,'COM.MWXPCControls_listviewctrl')
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

if isa(xpcmngrUserData.sigViewer,'COM.MWXPCControls_mshflexgridCtrl')
    delete(xpcmngrUserData.sigViewer)
    xpcmngrUserData.scidlistCtrl=[];
end

if isa(xpcmngrUserData.rtfCtrl,'COM.MWXPCControls_richtextboxctrl')
    delete(xpcmngrUserData.rtfCtrl)
    xpcmngrUserData.sigViewer=[];
end

if isa(xpcmngrUserData.scTypertfCtrl,'COM.MWXPCControls_richtextboxctrl')
    delete(xpcmngrUserData.scTypertfCtrl)
    xpcmngrUserData.scTypertfCtrl=[];
end
set(figH,'UserData',xpcmngrUserData)

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