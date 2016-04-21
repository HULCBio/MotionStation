function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:03 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%The model loop is not context dependent and does
%not need a refresh function.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

c.x.btnType={'Current' 'All' 'Custom'};
c.x.btnTypeTTS={'Loop on the current model only'
   'Loop on all open models'
   'Loop on a custom list of models'};
for i=1:length(c.x.btnType)
   c.x.LoopType(i)=uicontrol(c.x.all,...
      'Style','togglebutton',...
      'Value',0,...
      'String',c.x.btnType{i},...
      'ToolTipString',c.x.btnTypeTTS{i},...
      'Callback',[c.x.getobj,'''ChangeLoopType'',' num2str(i) ');']);
end
typeIndex=strcmp(c.x.btnType,c.att.LoopType);
set(c.x.LoopType(typeIndex),'Value',1);

buttonNames={'MoveUp'
   'MoveDown'
   'DeleteMdl'
   'NewMdl'};
btnToolTips={'Move model up'
   'Move model down'
   'Remove model from list'
   'Insert new model in list'};
cdata=getcdata(c.rptcomponent);
ud=struct('ok',{cdata.moveup cdata.movedn cdata.remok []},...
   'no',{cdata.moveupno cdata.movednno cdata.remno []});

%get CDATA with white background
%cdata=getcdata(c.rptcomponent,'',[1 1 1]);
%c.x.check=struct('on',flipdim(cdata.checkon,1),...
%   'off',flipdim(cdata.checkoff,1));

clear cdata


for i=1:length(buttonNames)
   c.x=setfield(c.x,buttonNames{i},uicontrol(c.x.all,...
      'Style','pushbutton',...
      'String','',...
      'CData',ud(i).ok,...
      'UserData',ud(i),...
      'ToolTipString',btnToolTips{i},...
      'Callback',[c.x.getobj,'''NavBtn'',''',buttonNames{i},''');']));
end

set(c.x.NewMdl,'String','New');

btnCData=getslcdata(c);

c.x.HeaderModel=uicontrol(c.x.all,...
   'style','text',...
   'HorizontalAlignment','left',...
   'FontWeight','bold',...
   'String','Model to Report');
c.x.HeaderSystem=uicontrol(c.x.all,...
   'style','text',...
   'HorizontalAlignment','left',...
   'FontWeight','bold',...
   'String','Systems to Report');
c.x.HeaderMask=uicontrol(c.x.all,...
   'style','pushbutton',...
   'Callback',[c.x.getobj,'''HeaderBtn'',''Mask'');'],...
   'ToolTipString','Look under masks',...
   'CData',btnCData.mask);
c.x.HeaderLibrary=uicontrol(c.x.all,...
   'style','pushbutton',...
   'Callback',[c.x.getobj,'''HeaderBtn'',''Library'');'],...
   'ToolTipString','Follow library links',...
   'CData',btnCData.library);

c.x.ColWid=[1 2 3 4 5];
c.x.ModelList=axes('Parent',c.x.all.Parent,...
   'Tag',c.x.all.Tag,...
   'HandleVisibility',c.x.all.HandleVisibility,...
   'Units',c.x.all.Units,...
   'Color',[1 1 1],...
   'Box','on',...
   'UserData',1,... %UserData reflects the currently selected model
   'XTickLabelMode','manual',...
   'YTickLabelMode','manual',...
   'XTick',[],...
   'YTick',[],...
   'XTickLabel',[],...
   'YTickLabel',[]);

c.x.ListScroll=uicontrol(c.x.all,...
   'Style','slider',...
   'SliderStep',[.05 .1],...
   'Callback',[c.x.getobj,'''LocResizeListEntries'');']);

loopBtnInfo=struct('UserData',{'$all'
   '$currentBelow'
   '$current'
   '$currentAbove'},...
   'ToolTipString',{'All systems in model'
   'Current system and below'
   'Current system only'
   'Current system and above'},...
   'CData',{btnCData.loopAll
   btnCData.loopCurrentBelow
   btnCData.loopCurrent
   btnCData.loopCurrentAbove});

for i=length(loopBtnInfo):-1:1
   c.x.LoopBtn(i)=uicontrol(c.x.all,...
      loopBtnInfo(i),...
      'style','togglebutton',...
      'Value',0,...
      'Callback',[c.x.getobj,'''LoopBtn'',',num2str(i),',''btnpress'');']);
end

c.x.sysLoopValues={'$all'
   '$currentBelow'
   '$current'
   '$currentAbove'};
c.x.sysLoopIcons={flipdim(btnCData.loopAllSmall,1)
   flipdim(btnCData.loopCurrentBelowSmall,1)
   flipdim(btnCData.loopCurrentSmall,1)
   flipdim(btnCData.loopCurrentAboveSmall,1)};

c.x.ListH=struct('isActive',{},...
      'MdlName',{},...
      'MdlCurrSys',{},...
      'SysLoopType',{},...
      'isMask',{},...
      'isLibrary',{});
   c.x.SelectFrame=[];
   
%-----------context menu --------------

c.x.ListContext.Parent=uicontextmenu('Parent',c.x.all.Parent,...
   'tag','csl_mdl_loop context menu',...
   'Callback',[c.x.getobj,'''PrepContextMenu'');']);

lName={'MdlName'
   'SysLoopType'
   'MdlCurrSys'
   'isMask'
   'isLibrary'};
lLabel={'Browse models...'
   'Set loop type'
   'Select current system(s)'
   'Look under masks'
   'Follow library links'};

for i=1:length(lLabel)
   c.x.ListContext=setfield(c.x.ListContext,lName{i},...
      uimenu('Parent',c.x.ListContext.Parent,...
      'tag','csl_mdl_loop context menu item',...
      'Label',lLabel{i}));
end

ltLabel={'All systems in model'
   'Current system and below'
   'Current system only'
   'Current system and above'};

for i=1:length(ltLabel)
   c.x.ContextLoopType(i)=uimenu('Parent',c.x.ListContext.SysLoopType,...
      'tag','csl_mdl_loop context menu LOOPTYPE item',...
      'UserData',c.x.sysLoopValues{i},...
      'Label',ltLabel{i},...
      'Callback',[c.x.getobj,'''LoopBtn'',' num2str(i) ',''btnpress'');']);
end

maskType={
   'none'
   'graphical'
   'functional'
   'all'
};

for i=1:length(maskType)
   cbString=[c.x.getobj,...
         '''ToggleFilter'',[],''isMask'',''',...
         maskType{i},''');'];
  
   c.x.ContextMask(i)=uimenu(...
      'Parent',c.x.ListContext.isMask,...
      'tag','csl_mdl_loop context menu ISMASK item',...
      'Label',['&' upper(maskType{i}(1)) maskType{i}(2:end)],...
      'UserData',maskType{i},...
      'Callback',cbString);
end

libLabel={
   '&No'
   '&Yes'
   '&Unique'
};

libType={
   'off'
   'on'
   'unique'
};


for i=1:length(libType)
   cbString=[c.x.getobj,...
         '''ToggleFilter'',[],''isLibrary'',''',...
         libType{i},''');'];
  
   c.x.ContextLibrary(i)=uimenu(...
      'Parent',c.x.ListContext.isLibrary,...
      'tag','csl_mdl_loop context menu ISLIBRARY item',...
      'Label',libLabel{i},...
      'UserData',libType{i},...
      'Callback',cbString);
end

%--------------------------------------
   
c=RedrawList(c);

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

set(c.x.ModelList,'Units','Pixels');
listPixelPosition=get(c.x.ModelList,'Position');
set(c.x.ModelList,'Units','Points');
listPointPosition=get(c.x.ModelList,'Position');
pixels2points=listPointPosition(3)/listPixelPosition(3);

iconWid=25; %pixels
listPad=5; %pixels

objList=[c.x.LoopType c.x.MoveUp c.x.MoveDown c.x.DeleteMdl ...
      c.x.NewMdl c.x.HeaderModel c.x.HeaderSystem c.x.HeaderMask ...
      c.x.HeaderLibrary c.x.ModelList c.x.ListScroll c.x.LoopBtn];

pad=5;
btnHt=25;
btnWid=min((c.x.xext-c.x.xzero-5*pad-btnHt)/3,100);
loopBtnWid=min((c.x.xext-c.x.xzero-6*pad-btnHt)/4,100);
loopBtnHt=btnHt*1.5;

textExtent=get(c.x.HeaderModel,'Extent');
headerTextHt=textExtent(4);

scrollWid=12;

listLeftLim=c.x.xzero+2*pad+btnHt;
listRightLim=c.x.xext-pad;
listWid=listRightLim-listLeftLim;

btnLowLim=c.x.ylim-pad-btnHt;
listTopLim=btnLowLim-pad-iconWid*pixels2points;

listLowLim=c.x.yzero+2*pad+loopBtnHt;
allNavBtnHt=4*btnHt+5*pad;
listHt=max(listTopLim-listLowLim,allNavBtnHt-2*btnHt-2*pad);
navBtnLowLim=listLowLim+(listHt-allNavBtnHt)/2;


textWid=((listWid-scrollWid)/pixels2points-2*listPad-3*iconWid)/2;
colWid=[listPad textWid iconWid textWid iconWid iconWid];
c.x.ColWid=cumsum(colWid);

colWid=[listPad textWid iconWid textWid iconWid iconWid]*pixels2points;
iconWid=iconWid*pixels2points;

objPos={[listLeftLim btnLowLim btnWid btnHt] %looptype1
   [(listRightLim+listLeftLim-btnWid)/2 btnLowLim btnWid btnHt] %looptype2
   [listRightLim-btnWid btnLowLim btnWid btnHt] %looptype3
   [c.x.xzero+pad navBtnLowLim+3*(pad+btnHt)+2*pad btnHt btnHt] %moveup
   [c.x.xzero+pad navBtnLowLim+2*(pad+btnHt)+2*pad btnHt btnHt] %movedown
   [c.x.xzero+pad navBtnLowLim+1*(pad+btnHt) btnHt btnHt] %deletemdl
   [c.x.xzero+pad navBtnLowLim+0*(pad+btnHt) btnHt btnHt] %newmdl
   [listLeftLim+sum(colWid(1:1)) listTopLim colWid(2) headerTextHt] %modelheader
   [listLeftLim+sum(colWid(1:2)) listTopLim sum(colWid(3:4)) headerTextHt] %modelheader
   [listLeftLim+sum(colWid(1:4)) listTopLim colWid(5) iconWid] %modelheader
   [listLeftLim+sum(colWid(1:5)) listTopLim colWid(6) iconWid] %modelheader
   [listLeftLim listLowLim listWid-scrollWid listHt] %modellist
   [listRightLim-scrollWid listLowLim scrollWid listHt] %listscroll
   [listLeftLim c.x.yzero+pad loopBtnWid loopBtnHt] %loopbtn1
   [listLeftLim+listWid*3/8-loopBtnWid/2 c.x.yzero+pad loopBtnWid loopBtnHt] %loopbtn2
   [listLeftLim+listWid*5/8-loopBtnWid/2 c.x.yzero+pad loopBtnWid loopBtnHt] %loopbtn3
   [listRightLim-loopBtnWid c.x.yzero+pad loopBtnWid loopBtnHt]}; %loopbtn4

set(objList,{'Position'},objPos);

c=LocResizeListEntries(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocResizeListEntries(c)

listH=c.x.ListH;

%textHt=get(listH(1).MdlCurrSys,'Extent');
%textHt=textHt(4);

set(c.x.ModelList,'Units','Pixels');
listPosition=get(c.x.ModelList,'Position');
set(c.x.ModelList,'Units','Points');
listHt=listPosition(4);
listWid=listPosition(3);

colWid=c.x.ColWid;

entryPad=5;
iconSide=15;
iconCenter=(colWid(3)-colWid(2)-iconSide)/2;
entryHt=iconSide+2*entryPad;

set(c.x.ModelList,'Xlim',[0 listWid],...
   'Ylim',[0 listHt]);

textWid=(listWid-3*entryHt-2*entryPad)/2;

mListLength=length(c.x.ListH);
if mListLength>1
   set(c.x.ListScroll,...
      'Max',-1,...
      'Min',-mListLength,...
      'Enable','on');
else
   set(c.x.ListScroll,...
      'Max',-1,...
      'Min',-1.1,...
      'Enable','off');
end

listTop=get(c.x.ListScroll,'Value');

posY=listHt-(listTop+2)*entryHt;
for i=1:length(listH)
   frameLow=posY-entryPad;
   set(c.x.SelectFrame(i),...
      'Xdata',[entryPad/2 listWid-entryPad/2 listWid-entryPad/2 entryPad/2],...
      'Ydata',[frameLow frameLow frameLow+entryHt frameLow+entryHt],...
      'UIContextMenu',c.x.ListContext.Parent);
   
   %textH=[listH(i).isActive,... %EMPTY!
   %      listH(i).MdlName,...
   %      listH(i).MdlCurrSys];
   
   %textPos={[colWid(1) posY]
   %   [colWid(3) posY]};
   
   textH=[listH(i).isActive,... %EMPTY!
         listH(i).MdlName,...
         listH(i).MdlCurrSys,...
         listH(i).isMask,...
         listH(i).isLibrary];
   
   textPos={[colWid(1) posY]
      [colWid(3) posY]
      [colWid(4)+iconSide/2+iconCenter posY]
      [colWid(5)+iconSide/2+iconCenter posY]};
   
   set(textH,{'Position'},textPos);
   
   %iconH=[listH(i).SysLoopType,...
   %      listH(i).isMask,...
   %      listH(i).isLibrary];
   %iconXdata={[colWid(2)+iconCenter colWid(2)+iconCenter+iconSide]
   %   [colWid(4)+iconCenter colWid(4)+iconCenter+iconSide]
   %   [colWid(5)+iconCenter colWid(5)+iconCenter+iconSide]};
   iconH=listH(i).SysLoopType;
   iconXdata={[colWid(2)+iconCenter colWid(2)+iconCenter+iconSide]};
   iconYdata=[posY posY+iconSide];
   
   set(iconH,...
      {'Xdata'},iconXdata,...
      'Ydata',iconYdata);
       
   posY=posY-entryHt;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=NavBtn(c,whichBtn)


currSelect=get(c.x.ModelList,'UserData');
newSelect=currSelect;

switch whichBtn
case 'MoveUp'
   c.att.CustomModels=c.att.CustomModels([1:currSelect-2, ...
         currSelect, ...
         currSelect-1, ...
         currSelect+1:end]);
   newSelect=currSelect-1;   
   statbar(c,'');
case 'MoveDown'
   c.att.CustomModels=c.att.CustomModels([1:currSelect-1, ...
         currSelect+1, ...
         currSelect, ...
         currSelect+2:end]);   
   newSelect=currSelect+1;
   statbar(c,'');   
case 'DeleteMdl'
   currModel=c.att.CustomModels(currSelect).MdlName;
   c.att.CustomModels=c.att.CustomModels([1:currSelect-1,currSelect+1:end]);
   if length(c.att.CustomModels)<currSelect
      newSelect=currSelect-1;
   end
   removeModelFromMemory(c,currModel);
case 'NewMdl'
   %add a new entry to the list
   newEntry=struct('isActive',logical(1),...
      'MdlName','',...
      'MdlCurrSys',{{'$top'}},...
      'SysLoopType','$all',...
      'isMask',logical(0),...
      'isLibrary',logical(0));
   c.att.CustomModels=[c.att.CustomModels(1:currSelect),...
         newEntry,...
         c.att.CustomModels(currSelect+1:end)];
   newSelect=newSelect+1;
   statbar(c,'Enter the name of a Simulink model in the "Model to Report" column');
end

c=RedrawList(c);
c=ListSelect(c,newSelect,0);

%if strcmp(whichBtn,'NewMdl')
%   c=EditMdlName(c,newSelect);   
%end


c=EnableNavBtn(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removeModelFromMemory(c,currModel)

hiddenModels=find_system(0,...
   'SearchDepth',0,...
   'Name',currModel,...
   'open','off',...
   'dirty','off');
if ~isempty(hiddenModels)
   try
      bdclose(hiddenModels);
   end
end
statbar(c,sprintf('Model "%s" removed',currModel));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ChangeLoopType(c,whichType)

set(c.x.LoopType,'value',0);
set(c.x.LoopType(whichType),'value',1);
c.att.LoopType=c.x.btnType{whichType};

statbar(c,c.x.btnTypeTTS{whichType},logical(0));

c=RedrawList(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=RedrawList(c)

delete([c.x.ListH(:).isActive,...
      c.x.ListH(:).MdlName, ...
      c.x.ListH(:).MdlCurrSys , ...
      c.x.ListH(:).SysLoopType , ...
      c.x.ListH(:).isMask , ...
      c.x.ListH(:).isLibrary]);

set(c.x.ListScroll,'Value',-1);

c.x.ListH=struct('isActive',{},...
      'MdlName',{},...
      'MdlCurrSys',{},...
      'SysLoopType',{},...
      'isMask',{},...
      'isLibrary',{});
   

switch c.att.LoopType
case 'Current'
   lStruct=c.att.CurrentModels;
   mdlNameFcn='';
   mdlNameColor=LocLightGrey;
case 'All'
   lStruct=c.att.AllModels;
   mdlNameFcn='';
   mdlNameColor=LocLightGrey;
case 'Custom'
   lStruct=c.att.CustomModels;
   mdlNameFcn=[c.x.getobj,'''EditMdlName'',$i);'];
   %mdlNameColor=[0 0 0];  we now use blue to show that the %<varname> syntax is allowed
   mdlNameColor = [0 0 1];
end

allProp.Parent=c.x.ModelList;
allProp.Tag=c.x.all.Tag;
allProp.Clipping='on';
allProp.Interruptible='off';
allProp.BusyAction='cancel';

delete(c.x.SelectFrame);

c.x.SelectFrame=[];

selectIndex=1;
set(c.x.ModelList,'UserData',selectIndex);

for i=length(lStruct):-1:1   
   if i==selectIndex
      fColor=LocLightGrey;
   else
      fColor='none';
   end
   
   c.x.SelectFrame(i)=patch(allProp,...
      'ButtonDownFcn',[c.x.getobj,...
         '''ListSelect'',',num2str(i),',logical(1));'],...
   'EdgeColor',fColor,...
   'FaceColor','none');   
   
   c.x.ListH(i).isActive=[];
      
   switch(lStruct(i).MdlName)
   case '$current'
      mString='Current Model';
   case '$all'
      mString='All Models';
   otherwise
      mString=lStruct(i).MdlName;
   end
      
   c.x.ListH(i).MdlName=text(allProp,...
      'String',mString,...
      'Units','data',...
      'Color',mdlNameColor,...
      'Interpreter','none',...
      'ButtonDownFcn',strrep(mdlNameFcn,'$i',num2str(i)),...
      'VerticalAlignment','Bottom');
      
   c.x.ListH(i).MdlCurrSys=text(allProp,...
      LocCurrSysDisplay(lStruct(i),c.x.getobj,i),...
      'Interpreter','none',...
      'Units','data',...
      'FontAngle','italic',...
      'VerticalAlignment','Bottom',...
      'HorizontalAlignment','left');
   
   sysLoopIndex=strcmp(c.x.sysLoopValues,lStruct(i).SysLoopType);   
   c.x.ListH(i).SysLoopType=image(allProp,...
      'CData',c.x.sysLoopIcons{sysLoopIndex},...
      'ButtonDownFcn',[c.x.getobj,...
         '''LoopBtn'',',num2str(i),',''toggle'');']);
   
   %maskProps and libProps are a structure containing 
   % String, Color, and ButtonDownFcn values
   maskProps=LocMaskDisplay(lStruct(i),c.x.getobj,i);
   c.x.ListH(i).isMask=text(allProp,...
      maskProps,...
      'Units','data',...
      'HorizontalAlignment','Center',...
      'VerticalAlignment','Bottom');
   
   libProps=LocLibraryDisplay(lStruct(i),c.x.getobj,i);
   c.x.ListH(i).isLibrary=text(allProp,...
      libProps,...
      'Units','data',...
      'HorizontalAlignment','Center',...
      'VerticalAlignment','Bottom');
   
end

c=LocResizeListEntries(c);

c=LoopBtn(c,[],'update');

c=EnableNavBtn(c);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=EnableNavBtn(c)

btnHandles=[c.x.MoveUp c.x.MoveDown ...
      c.x.DeleteMdl c.x.NewMdl];

hEnable=[0 0 0 0];
if strcmp(c.att.LoopType,'Custom')
   hEnable=[1 1 1 1];
   currSelect=get(c.x.ModelList,'UserData');
   
   hEnable=[(currSelect>1),...
         (currSelect<length(c.att.CustomModels)),...
         (length(c.att.CustomModels)>1),...
         ~any(cellfun('isempty',{c.att.CustomModels.MdlName}))];
   
end

for i=1:length(hEnable)
   ud=get(btnHandles(i),'UserData');
   if hEnable(i)
      cd=ud.ok;
      en='on';
   else
      en='off';
      cd=ud.no;
   end
   set(btnHandles(i),'Enable',en,...
      'CData',cd);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ListSelect(c,whichEntry,isEditOK)

%isEditOK==2: force an edit
%==1: editing allowed
%==0: editing not allowed

isSelectOk=any(strcmp({'normal' 'open'},...
   get(c.x.all.Parent,'SelectionType')));

oldCurr=get(c.x.ModelList,'UserData');
if (isSelectOk & oldCurr==whichEntry) | isEditOK==2
   if isEditOK
      %we're selecting something we have already selected
      if strcmp(c.att.LoopType,'Custom')
         c=EditMdlName(c,whichEntry);
      end
   end
else
   %we're selecting a new list item
   set(c.x.ModelList,'UserData',whichEntry);
   set(c.x.SelectFrame,'EdgeColor','none');
   set(c.x.SelectFrame(whichEntry),'EdgeColor',LocLightGrey);
   c=LoopBtn(c,whichEntry,'update');
   c=EnableNavBtn(c);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=EditMdlName(c,whichEntry)

c=ListSelect(c,whichEntry,logical(0));

[entry,handles]=GetCurrEntry(c,whichEntry);

set(handles.MdlName,'editing','on');
waitfor(handles.MdlName,'editing');
if ishandle(handles.MdlName)
   %if the text object still exists
   
   newName=deblank(...
      singlelinetext(c,...
      get(handles.MdlName,'String'),sprintf('\n')));
   slashLoc=findstr(newName,'/');
   if ~isempty(slashLoc)
      origName=newName;
      newName=newName(1:slashLoc(1)-1);
      setSystemFlag=logical(1);
   else
      origName='';
      setSystemFlag=logical(0);
   end
   
   
   statusMessage='';
   statusError=logical(0);
   if ~isempty(newName) & ~(strncmp(newName,'%<',2) & newName(end)=='>')
      
      goodIndex=find((newName>=abs('0') & newName<=abs('9')) | ...
         newName==abs('_') | ...
         (newName>=abs('a') & newName<=abs('z')) | ...
         (newName>=abs('A') & newName<=abs('Z')));
      
      if length(goodIndex)<length(newName)
         newName=newName(goodIndex);
         newName=newName(:)';
         
         statusMessage='Text must be a valid model name or %<expression>';
         statusError=logical(1);
         setSystemFlag=logical(0);
      end
   end
   
   if ~strcmp(newName,entry.MdlName)
      removeModelFromMemory(c,entry.MdlName);
   end
   
   set(handles.MdlName,'String',newName);
   if ~strcmp(entry.MdlName,newName) | setSystemFlag
      %if the model name has not changed OR 
      entry.MdlName=newName;
      
      currSys={'$top'};
      foundSys='';
      if setSystemFlag
         %A full path name to a system may have been entered
         openedModel=openmodel(c.zslmethods,newName,logical(0));
         if ~isempty(openedModel)
            try
               foundSys=find_system(origName,'SearchDepth',0,'blocktype','SubSystem');
            end
            
            if ~isempty(foundSys)
               currSys=foundSys(1);
               statusMessage='Setting input system to "current"';
               entry.SysLoopType='$current';
            else
               statusError=logical(1);
               statusMessage=sprintf('Not a valid system in model "%s".', ...
                     newName);
            end
         end
      end
      
      entry.MdlCurrSys=currSys;
      
      
      set(handles.MdlCurrSys,...
         LocCurrSysDisplay(entry,c.x.getobj,whichEntry));   
      
      c=SetCurrEntry(c,entry,whichEntry);   
      
      c=EnableNavBtn(c);
      
      if ~isempty(foundSys)
         c=LoopBtn(c,whichEntry,'update');
      end
      
      
   end
   if isempty(statusMessage) & ...
	  ~(strncmp(newName,'%<',2) & newName(end)=='>') & ...
       exist(newName)~=4
   
      statusMessage=sprintf(...
	        'Warning - model "%s" not found on MATLAB path',newName);
      statusError=logical(1);
   end
   statbar(c,statusMessage,statusError);

else
   c=[];
end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=BrowseMdlName(c,whichEntry)

[entry,handles]=GetCurrEntry(c,whichEntry);

eDir=which(entry.MdlName);
if isempty(eDir)
   eDir=pwd;
elseif iscell(eDir)
   [eDir,eFile,eExt,eVer]=fileparts(eDir{1});
else
   [eDir,eFile,eExt,eVer]=fileparts(eDir);
end

%filterSpec={'*.mdl','Models (*.mdl)';'*.*','All files (*.*)'};
[eFile, ePath] = uigetfile(fullfile(eDir,'*.mdl'),...
   'Select a Simulink block diagram file');


if ~isnumeric(eFile)
   [eDir,eFile,eExt,eVer]=fileparts(fullfile(ePath,eFile));
   if ~strcmp(eFile,entry.MdlName)
      entry.MdlName=eFile;
      set(handles.MdlName,'String',eFile);
      
      entry.MdlCurrSys={'$top'};
      set(handles.MdlCurrSys,...
         LocCurrSysDisplay(entry,c.x.getobj,whichEntry));   

      c=SetCurrEntry(c,entry,whichEntry);

      
      c=EnableNavBtn(c);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=EditMdlCurrSys(c,whichEntry,action)

c=ListSelect(c,whichEntry,logical(0));

[entry,handles]=GetCurrEntry(c,whichEntry);

switch action
case 'toggle'
   switch(entry.MdlCurrSys{1})
   case '$current'
      newVal='$top';
   case '$top'
      newVal='$current';
   end
   entry.MdlCurrSys={newVal};
case 'selectdlg'
	if strncmp(entry.MdlName,'%<',2)
	   statbar(c,'Can not select current system for variable-defined model names');
       return;
    else
 	   entry=systembrowse(c,entry);
	end
end
set(handles.MdlCurrSys,...
   LocCurrSysDisplay(entry,c.x.getobj,whichEntry));

c=SetCurrEntry(c,entry,whichEntry);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LoopBtn(c,i,action)


%if isToggle, we are clicking on model "i" and want
%to toggle the looping value.  If not isToggle, we
%are clicking on the actual button

btnNames={'$all'
   '$currentBelow'
   '$current'
   '$currentAbove'};


isUpdate=logical(0);
switch action
case 'toggle'
   mdlIndex=i;
   c=ListSelect(c,mdlIndex,logical(0));
   [entry,handles]=GetCurrEntry(c,mdlIndex);

   %we need to get the current value and change it
   btnIndex=find(strcmp(btnNames,entry.SysLoopType));
   if btnIndex==length(btnNames)
      btnIndex=1;
   else
      btnIndex=btnIndex+1;
   end   
case 'btnpress'
   %just treat them like radiobuttons and update
   [entry,handles,mdlIndex]=GetCurrEntry(c,[]);
   btnIndex=i;
case 'update'
   mdlIndex=i;
   [entry,handles]=GetCurrEntry(c,mdlIndex);
   btnIndex=find(strcmp(btnNames,entry.SysLoopType));
   isUpdate=logical(1);
end

set(c.x.LoopBtn,'Value',0);
set(c.x.LoopBtn(btnIndex),'Value',1);

if ~isUpdate
   entry.SysLoopType=btnNames{btnIndex};
   maskProps=LocMaskDisplay(entry,c.x.getobj,mdlIndex);
   set(handles.isMask,maskProps);
   libProps=LocLibraryDisplay(entry,c.x.getobj,mdlIndex);
   set(handles.isLibrary,libProps);
   set(handles.MdlCurrSys,...
      LocCurrSysDisplay(entry,c.x.getobj,mdlIndex));   
   c=SetCurrEntry(c,entry,mdlIndex);
   
   statusString=get(c.x.LoopBtn(btnIndex),'ToolTipString');
   statusString=sprintf('Loop on %s%s', lower(statusString(1)), statusString(2:end));
   statbar(c,statusString,0);
   
end

set(handles.SysLoopType,'CData',c.x.sysLoopIcons{btnIndex});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ToggleFilter(c,whichEntry,whichFilter,filterType)


if ~isempty(whichEntry)
   c=ListSelect(c,whichEntry,logical(0));
end
[entry,handles,whichEntry]=GetCurrEntry(c,whichEntry);

switch whichFilter
case 'isMask'
   if nargin>3
      entry.isMask=filterType;
   else
      switch entry.isMask
      case 'none'
         entry.isMask='graphical';
      case {'graphical' 'off' logical(0)}
         entry.isMask='functional';
      case 'functional'
         entry.isMask='all';
      case {'all' 'on' logical(1)}
         entry.isMask='none';
      otherwise
         entry.isMask='functional';
      end
   end
   
   [maskProps,statusMessage]=LocMaskDisplay(entry,...
      c.x.getobj,whichEntry);
   set(handles.isMask,maskProps);
case 'isLibrary'
   if nargin>3
      entry.isLibrary=filterType;
   else
      switch entry.isLibrary
      case {'off' logical(0)}
         entry.isLibrary='on';
      case {'on' logical(1)}
         entry.isLibrary='unique';
      case 'unique'
         entry.isLibrary='off';
      otherwise
         entry.isLibrary='on';
      end
   end
   
   [libProps,statusMessage]=LocLibraryDisplay(entry,...
      c.x.getobj,whichEntry);
   set(handles.isLibrary,libProps);
otherwise
   statusMessage='';
end

statbar(c,statusMessage,logical(0));
c=SetCurrEntry(c,entry,whichEntry);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [entry,handles,mdlIndex]=GetCurrEntry(c,mdlIndex);

switch c.att.LoopType
case 'Current'
   mdlIndex=1;
   entry=c.att.CurrentModels;
   handles=c.x.ListH(1);
case 'All'
   mdlIndex=1;
   entry=c.att.AllModels;
   handles=c.x.ListH(1);
case 'Custom'
   if nargin<2 | isempty(mdlIndex)
      mdlIndex=get(c.x.ModelList,'UserData');
   end
   
   entry=c.att.CustomModels(mdlIndex);
   handles=c.x.ListH(mdlIndex);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=SetCurrEntry(c,entry,mdlIndex);

switch c.att.LoopType
case 'Current'
   c.att.CurrentModels=entry;
case 'All'
   c.att.AllModels=entry;
case 'Custom'
   if nargin<3 | isempty(mdlIndex)
      mdlIndex=get(c.x.ModelList,'UserData');
   end
   c.att.CustomModels(mdlIndex)=entry;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=PrepContextMenu(c)

whichMdl=get(c.x.ModelList,'UserData');
[entry,handles]=GetCurrEntry(c,whichMdl);

LocPlaceChecks(c.x.ContextLoopType,entry.SysLoopType);

if any(strcmp({'$all','$currentBelow'},entry.SysLoopType))
   searchdownEnable='on';
   LocPlaceChecks(c.x.ContextMask,entry.isMask);
   LocPlaceChecks(c.x.ContextLibrary,entry.isLibrary);
else
   searchdownEnable='off';
end

set([c.x.ListContext.isMask,c.x.ListContext.isLibrary],...
   'Enable',searchdownEnable);

mCbk={'';''};

switch c.att.LoopType
case 'All'
   mEnable={'off';'off'};
   mStr='Change current system';
case 'Custom'
   mEnable={'on';'on'};
   mCbk{1}=[c.x.getobj,...
         '''BrowseMdlName'',',num2str(whichMdl),');'];
   mCbk{2}=[c.x.getobj,...
         '''EditMdlCurrSys'',' num2str(whichMdl) ',''selectdlg'');'];   
   mStr='Select current system(s)...';
case 'Current'
   mEnable={'off';'on'};
   mCbk{2}=[c.x.getobj ...
         '''EditMdlCurrSys'',' num2str(whichMdl) ',''toggle'');'];
   mStr='Toggle current/top system';
end

if strcmp('$all',entry.SysLoopType)
   mEnable{2}='off';
end

set(c.x.ListContext.MdlCurrSys,'Label',mStr);

set([c.x.ListContext.MdlName c.x.ListContext.MdlCurrSys],...
   {'Enable'},mEnable,...
   {'Callback'},mCbk);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocPlaceChecks(handles,matchValue)

set(handles,'Checked','off');

menuType=get(handles,'UserData');
whichChecked=find(strcmp(menuType,matchValue));
set(handles(whichChecked),'Checked','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=HeaderBtn(c,whichBtn)

switch whichBtn
case 'Mask'
   title='Look Under Masks';
   loopOpt={'   N (None) - do not look under any masked systems'
      '   G (Graphical) - look under masks with no workspace and no dialog'
      '   F (Functional) - look under masks with no dialog'
      '   A (All) - look under all masks'};
case 'Library'
   title='Follow Library Links';
   loopOpt={'   N (No) - do not follow library links'
      '   Y (Yes) - follow library links'
      '   U (Unique) - follow unique library links'
      ''};
otherwise
   title='Look Under Masks/Follow Library Links';
   loopOpt={'';'';'';''};
end

helpStr={title
   ''
   xlate('  The model loop constructs a list of systems to include in the') 
   xlate('  report.  If "all systems" or "current system and below" are selected,')
   xlate('  the checkboxes in this column tell the component whether or not to')
   sprintf('  %s   when constructing this list.  Options are:',lower(title))
   ''
   loopOpt{1}
   loopOpt{2}
   loopOpt{3}
   loopOpt{4}
   ''
   sprintf('  The %s value can be set individually for each row',lower(title) )
   xlate('  in the model loop list.  Click on the character to cycle through')
   xlate('  the available values.')};

helpwin({'Model Loop' helpStr},...
   'Model Loop');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sProps=LocCurrSysDisplay(entry,getobj,listIndex)

if length(entry.MdlCurrSys)==1
   switch entry.MdlCurrSys{1}
   case '$top'
      sString='Top System';
   case '$current'
      sString='Current System';
   otherwise
      sString=strrep(entry.MdlCurrSys{1},sprintf('\n'),' ');  
      if length(sString)>20
         sString=sString(end-20:end);
      end
   end
else
   sString='Multiple';
end

switch entry.MdlName
case '$all'
   dotString='';
   sColor=LocLightGrey;
   sFcn='';
case '$current'
   dotString='';
   if strcmp(entry.SysLoopType,'$all')
      sColor=LocLightGrey;
      sFcn='';
   else
      sColor=[0 0 0];
      sFcn=sprintf('%s''EditMdlCurrSys'',%d,''toggle'');',...
         getobj,listIndex);
   end
   
otherwise
   dotString='...';
   if isempty(entry.MdlName) | strcmp(entry.SysLoopType,'$all')
      sColor=LocLightGrey;
      sFcn='';
   else
      sColor=[0 0 0];
      sFcn=sprintf('%s''EditMdlCurrSys'',%d,''selectdlg'');',...
         getobj,listIndex);
   end
end

sProps.String=['(' sString dotString ')'];
sProps.Color=sColor;
sProps.ButtonDownFcn=sFcn;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mProps,msgString]=LocMaskDisplay(mdlStruct,getobj,listIndex)
% String, Color, and ButtonDownFcn values

switch mdlStruct.isMask
case 'none'
   mDisplay='N';
   msgString='N (None) - do not look under any masked systems';
case {'graphical' 'off' logical(0)}
   mDisplay='G';
   msgString='G (Graphical) - look under masks with no workspace and no dialog';
case 'functional'
   mDisplay='F';
   msgString='F (Functional) - look under masks with no dialog';
case {'all' 'on' logical(1)}
   mDisplay='A';
   msgString='A (All) - look under all masks';
otherwise
   mDisplay='G';
   msgString='G (Graphical) - look under masks with no workspace and no dialog';
end

if any(strcmp({'$all','$currentBelow'},mdlStruct.SysLoopType))
   mColor=[0 0 0];
   mFcn=sprintf('%s''ToggleFilter'',%d,''isMask'');',...
      getobj,listIndex);
else
   %for current and current&above, make control inactive
   mColor=[.5 .5 .5];
   mFcn='';
   msgString='';
end

mProps=struct('String',mDisplay,...
   'Color',mColor,...
   'ButtonDownFcn',mFcn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lProps,msgString]=LocLibraryDisplay(mdlStruct,getobj,listIndex)

switch mdlStruct.isLibrary
case {'off' logical(0)}
   lDisplay='N';
   msgString='N (No) - do not follow library links';
case {'on' logical(1)}
   lDisplay='Y';
   msgString='Y (Yes) - follow library links';
case 'unique'
   lDisplay='U';
   msgString='U (Unique) - follow unique library links';
otherwise
   lDisplay='N';
   msgString='N (No) - do not follow library links';
end

if any(strcmp({'$all','$currentBelow'},mdlStruct.SysLoopType))
   lColor=[0 0 0];
   lFcn=sprintf('%s''ToggleFilter'',%d,''isLibrary'');',...
      getobj,listIndex);
else
   %for current and current&above, make control inactive
   lColor=[.5 .5 .5];
   lFcn='';
   msgString='';
end

lProps=struct('String',lDisplay,...
   'Color',lColor,...
   'ButtonDownFcn',lFcn);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function greyColor=LocLightGrey;

greyColor=[.5 .5 .5];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strVal=LocOnOff(logVal)

if logVal
   strVal='on';
else
   strVal='off';
end
