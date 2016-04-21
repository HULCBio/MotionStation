function c=attribute(r,c,action,varargin)
%ATTRIBUTE launches the setup file editor options page
%   C=ATTRIBUTE(RPTPROPTABLE,C,'Action',varargin)
%   Acts as a standard ATTRIBUTE page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:25 $

c=feval(action,c,varargin{:});

%--------1--------2--------3--------4--------5--------6--------7--------8

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

info=getinfo(c);

c.x.mag=1;

c.x.currcell=[];
c.x.editing=logical(0);

[mpath mfile mext]=fileparts(mfilename('fullpath'));
buttonCData=getcdata(c.rptcomponent,...
   [mpath filesep 'proptablecdata.mat']);

figureBackgroundColor=c.x.all.BackgroundColor;
c.x.all.BackgroundColor=get(0,'defaultuicontrolbackgroundcolor');


%-----------add property controls---------

filterList=tableref(c,'GetFilterList');
if size(filterList.list,2)>1
   filterNames=filterList.list(:,2);
   filterValues=filterList.list(:,1);
else
   filterNames=filterList.list;
   filterValues=filterList.list;
end

c.x.propfilter=uicontrol(c.x.all,...
   'style','popupmenu',...
   'string',filterNames,...
   'UserData',filterValues,...
   'Value',filterList.index,...
   'Callback',[c.x.getobj,'''ChangeFilter'');'],...
   'BackgroundColor',[1 1 1],...
   'HorizontalAlignment','left');

c.x.proplist=uicontrol(c.x.all,...
   'style','listbox',...
   'string',tableref(c,'GetPropList',filterValues{filterList.index}),...
   'BackgroundColor',[1 1 1],...
   'Callback',[c.x.getobj,'''PropListSelect'');'],...   
   'HorizontalAlignment','left');

c.x.propaddbtn=uicontrol(c.x.all,...
   'style','pushbutton',...
   'string','<< Add',...
   'ToolTipString','Add property reference to current cell',...
   'Callback',[c.x.getobj,'''AddProp'');'],...
   'HorizontalAlignment','left');

%---------mode control---------------------------

c.x.SingleValueMode=uicontrol(c.x.all,...
   'style','checkbox',...
   'Value',c.att.SingleValueMode,...
   'Max',logical(1),'Min',logical(0),...
   'BackgroundColor',figureBackgroundColor,...
   'String','Split property/value cells',...
   'ToolTipString','Names and values appear in different cells',...
   'Callback',[c.x.getobj,'''ChangeMode'');'],...
   'HorizontalAlignment','left');

%---------cell formatting controls---------------

%aligntext={'L'
%   'C'
%   'R'};
aligntips={'Align text left'
   'Align text center'
   'Align text right'
   'Align double justified'};
alignud={'l'
   'c'
   'r'
   'j'};
aligncdata={buttonCData.alignleft
   buttonCData.aligncenter
   buttonCData.alignright
   buttonCData.alignjust};

for i=1:length(alignud)
   c.x.alignbtn(i)=uicontrol(c.x.all,...
      'style','togglebutton',... %     'string',aligntext(i),...
      'ToolTipString',aligntips{i},...  
      'Cdata',aligncdata{i},...
      'Value',0,...
      'UserData',alignud{i},...
      'Callback',[c.x.getobj,'''UpdateAlign'',''',alignud{i},''');'],...
      'HorizontalAlignment','center');
end   

propRenderStrings={
   'Value'
   'Property Value'
   'PROPERTY Value'
   'Property: Value'
   'PROPERTY: Value'
   'Property - Value'
   'PROPERTY - Value'
};
propRenderCode = {'v'
   'p v'
   'P v'
   'p:v'
   'P:v'
   'p-v'
   'P-v'};

c.x.proprender=uicontrol(c.x.all,...
   'Style','popupmenu',...
   'BackgroundColor',[1 1 1],...
   'String',propRenderStrings,...
   'UserData',propRenderCode,...
   'Callback',[c.x.getobj,'''UpdateRender'');'],...
   'ToolTipString','Display property as',...
   'HorizontalAlignment','left');

%-----------Preset Table Controls-----------------
%c.x.presettext=uicontrol(c.x.all,...
%   'style','text',...
%   'String','Preset tables',...
%   'HorizontalAlignment','left',...
%   'String','Apply a preset table');

allPresets=tableref(c,'GetPresetList');
c.x.presetpop=uicontrol(c.x.all,...
   'style','popupmenu',...
   'BackgroundColor',[1 1 1],...
   'string',{'Select a preset table' allPresets{:}},...
   'Callback',[c.x.getobj,'''SelectPreset'');'],...
   'Value',1,...
   'HorizontalAlignment','left');
c.x.presetaddbtn=uicontrol(c.x.all,...
   'style','pushbutton',...
   'enable','off',...
   'string','Reset',...
   'Callback',[c.x.getobj,'''ApplyPreset'');'],...
   'ToolTipString','Warning! Applying a preset table will erase the current table',...
   'HorizontalAlignment','left');

%-----------Main Drawing Window-----------------

for i=2:-1:1
   c.x.slider(i)=uicontrol(c.x.all,...
      'Callback',[c.x.getobj,'''NewView'');'],...
      'Min',0,...
      'Max',1,...
      'Value',.5,...
      'style','slider');
end

numRows=size(c.att.TableContent,1);
set(c.x.slider(2),...
   'Min',0,...
   'Max',numRows,...
   'value',numRows/2);

zoomtxt={'+' '-'};
zoomnum={1,-1};
zoomtip={'Zoom in'
   'Zoom out'};

for i=1:length(zoomtxt)
   c.x.zoom(i)=uicontrol(c.x.all,...
      'String',zoomtxt{i},...
      'ToolTipString',zoomtip{i},...
      'Callback',[c.x.getobj,'''ZoomClick'',',num2str(zoomnum{i}),');'],...
      'style','pushbutton');
end

lCData=struct('ok',{buttonCData.addcol buttonCData.delcol ...
      buttonCData.addrow buttonCData.delrow},...
   'no',{buttonCData.addcolno buttonCData.delcolno ...
      buttonCData.addrowno buttonCData.delrowno});
layoutTip={
    'Add column to left of current cell'
    'Delete current column'
    'Add row above current cell'
    'Delete current row'
    'Add dolumn to right of current cell'
    'Add row below current cell'
};

for i=1:4
   c.x.layoutbtn(i)=uicontrol(c.x.all,...
      'Style','pushbutton',...
      'UserData',lCData(i),...
      'ToolTipString',layoutTip{i},...
      'Callback',[c.x.getobj,'''LayoutClick'',',num2str(i),');'],...
      'HorizontalAlignment','center');
end

c.x.window=axes('Parent',c.x.all.Parent,...
   'Tag',c.x.all.Tag,...
   'HandleVisibility',c.x.all.HandleVisibility,...
   'Units',c.x.all.Units,...
   'Color',[.7 .7 .7],...
   'Box','on',...
   'XTickLabelMode','manual',...
   'YTickLabelMode','manual',...
   'XTickLabel',[],...
   'YTickLabel',[]);

%------------Axes Context Menu ---------------------

c.x.contextmenu=uicontextmenu('Parent',c.x.all.Parent,...
   'Callback',[c.x.getobj,'''InitializeContextMenu'',''main'');']);

set(c.x.window,'UIContextMenu',c.x.contextmenu)

mainName={
   'mainJust'
   'mainBorder'
   'mainFrame'
   'mainRender'
   'mainLayout'
};
mainString={
   xlate('Cell justification')
   xlate('Cell borders')
   xlate('Table frame')
   xlate('Cell rendering')
   xlate('Columns and rows')
};
mainCallback={
   ''
   ''
   [c.x.getobj,'''ToggleBorder'',''frame'');']
   ''
   ''
};

cmi.all=[];
for i=1:length(mainName)
   h=uimenu(...
      'Parent',c.x.contextmenu,...
      'Callback',mainCallback{i},...
      'UserData',mainName{i},...
      'Label',mainString{i},...
      'Checked','off');
   cmi=setfield(cmi,mainName{i},h);
   cmi.all=[cmi.all,h];
end

alignName={
   'jleft'
   'jcenter'
   'jright'
   'jdouble'
};
alignString={
   xlate('Left')
   xlate('Center')
   xlate('Right')
   xlate('Double justify')
};
alignCallback={
   [c.x.getobj,'''UpdateAlign'',''l'');']
   [c.x.getobj,'''UpdateAlign'',''c'');']
   [c.x.getobj,'''UpdateAlign'',''r'');']
   [c.x.getobj,'''UpdateAlign'',''j'');']
};
for i=1:length(alignName)
   h=uimenu(...
      'Parent',cmi.mainJust,...
      'Callback',alignCallback{i},...
      'UserData',alignName{i},...
      'Label',alignString{i},...
      'Checked','on');
   cmi=setfield(cmi,alignName{i},h);
   cmi.all=[cmi.all,h];
end

borderName={
   'btop'
   'bbottom'
   'bright'
   'bleft'
};
borderString={
   xlate('Top')
   xlate('Bottom')
   xlate('Right')
   xlate('Left')
};
borderCallback={
   [c.x.getobj,'''ToggleBorder'',''top'');']
   [c.x.getobj,'''ToggleBorder'',''bottom'');']
   [c.x.getobj,'''ToggleBorder'',''right'');']
   [c.x.getobj,'''ToggleBorder'',''left'');']
};
for i=1:length(borderName)
   h=uimenu(...
      'Parent',cmi.mainBorder,...
      'Callback',borderCallback{i},...
      'UserData',borderName{i},...
      'Label',borderString{i},...
      'Checked','off');
   cmi=setfield(cmi,borderName{i},h);
   cmi.all=[cmi.all,h];
end

for i=1:length(propRenderStrings)
   h=uimenu('Parent',cmi.mainRender,...
      'Callback',...
      [c.x.getobj,'''UpdateRender'',''' propRenderCode{i} ''');'],...
      'Label',xlate(propRenderStrings{i}),...
      'Checked','off');
   cmi.render(i)=h;
   cmi.all=[cmi.all,h];
end

cmi.layout=[];
tipOrder=[1 5 2 3 6 4];
for i=1:length(layoutTip)
    idx=tipOrder(i);
   h=uimenu('Parent',cmi.mainLayout,...
       'UserData',idx,...
       'Label',xlate(layoutTip{idx}),...
       'Callback',[c.x.getobj,'''LayoutClick'',',num2str(idx),');']);
  cmi.layout(end+1)=h;
  cmi.all(end+1)=h;
end
set(cmi.layout(4),'separator','on');

c.x.contextmenuItems=cmi;

%-------------Post-Draw Setup---------------
c=Redraw(c);
c=resize(c);

c.x.currcell=sign(size(c.att.TableContent));

c=CellSelect(c,c.x.currcell(1),c.x.currcell(2),'normal');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

tabwidth=c.x.xext-c.x.xzero;
if tabwidth<180
   c.x.allInvisible=logical(1);
   return;
end

barht=layoutbarht(c);
pad=10;
padTabWidth=tabwidth-2*pad;


%-------presets------------
%textwidth=get(c.x.presettext,'Extent');
%textwidth=min(padTabWidth*.4,textwidth(3)+pad);
%pos=[c.x.xzero+pad c.x.ylim-barht textwidth barht];

%set(c.x.presettext,'Position',pos);
%pos(1)=pos(1)+pos(3);

popWid=min(padTabWidth*.4,110);
btnWid=get(c.x.presetaddbtn,'Extent');
btnWid=min(padTabWidth*.1,btnWid(3)+pad);

checkWid=get(c.x.SingleValueMode,'Extent');
checkWid=min(padTabWidth-popWid-btnWid-pad,checkWid(3)+20+pad);


pos=[c.x.xzero+pad c.x.ylim-barht popWid barht];
rsPos={pos};
rsH=c.x.presetpop;

pos(1)=pos(1)+pos(3);
pos(3)=btnWid;
rsPos{end+1,1}=pos;
rsH(end+1)=c.x.presetaddbtn;

pos(1)=pos(1)+pos(3)+pad;
pos(3)=checkWid;
rsPos{end+1}=pos;
rsH(end+1)=c.x.SingleValueMode;

set(rsH,{'Position'},rsPos);

windowTop=pos(2)-pad;

%-----layout buttons, formatting, add prop buttons ------


pos=[c.x.xzero+pad c.x.yorig+pad/2 barht barht];
set(c.x.layoutbtn(1),'position',pos)
pos(1)=pos(1)+pos(3);
set(c.x.layoutbtn(2),'position',pos)
pos(1)=pos(1)+pos(3);
set(c.x.layoutbtn(3),'position',pos)
pos(1)=pos(1)+pos(3);
set(c.x.layoutbtn(4),'position',pos)

pos(1)=pos(1)+pos(3)+pad;
for i=1:length(c.x.alignbtn)
   set(c.x.alignbtn(i),'position',pos)
   pos(1)=pos(1)+pos(3);
end

leftover=c.x.xext-pos(1);

pnamecheckwid=min(leftover*.6,90);
pos=[pos(1)+pad/2 pos(2) pnamecheckwid  barht];
set(c.x.proprender,'position',pos)

%------zoom buttons & lower scroll bar ------
listWidth=min(tabwidth*.20,120)-pad;
windowWidth=tabwidth-listWidth-2.5*pad;

scrollht=barht*.75;
pos=[c.x.xzero+pad pos(2)+pos(4)+pad/2 scrollht scrollht];
set(c.x.zoom(1),'position',pos)
pos=[pos(1)+pos(3) pos(2) pos(3) pos(4)];
set(c.x.zoom(2),'position',pos)

pos=[pos(1)+pos(3) pos(2) windowWidth-3*scrollht scrollht];
set(c.x.slider(1),'position',pos)
%pos=[pos(1)+pos(3) pos(2) scrollht scrollht];
%set(c.x.borderbtn,'position',pos)
windowBottom=pos(2)+scrollht;

%-------window and add list ------------
windowHt=windowTop-windowBottom;

pos=[c.x.xzero+pad pos(2)+scrollht windowWidth-scrollht windowHt];
set(c.x.window,'position',pos)

pos=[pos(1)+pos(3) pos(2) scrollht pos(4)];
set(c.x.slider(2),'position',pos)

addXzero=c.x.xext-pad-listWidth;
pos=[addXzero windowTop-barht listWidth barht];
set(c.x.propfilter,'position',pos)

addYzero=windowBottom-scrollht;
set(c.x.propaddbtn,'position',...
   [addXzero addYzero listWidth barht])

set(c.x.proplist,'position',...
   [addXzero addYzero+barht+pad/2 listWidth windowHt-2*barht+scrollht-pad/2])

c=NewView(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=NewView(c)

pos=get(c.x.window,'Position');
ydisplay=13*pos(4)/(pos(3)*c.x.mag);
%15 is the default height of a cell in points

xdisplay=1.05/c.x.mag;

xcenter=get(c.x.slider(1),'value');
ycenter=get(c.x.slider(2),'value');

set(c.x.window,...
   'Xlim',[xcenter-xdisplay/2 xcenter+xdisplay/2],...
   'Ylim',[ycenter-ydisplay/2 ycenter+ydisplay/2]);

%[numRows,numCols]=size(c.att.TableContent);

fsize=c.x.mag*pos(3)/40;
lText=c.x.leftText;
rText=c.x.rightText;
set([lText{:,:},rText{:,:},c.x.titleHandles.leftText],...
   'FontSize',fsize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Redraw(c);
%redraws the figure

delete(allchild(c.x.window));

[numRows,numCols]=size(c.att.TableContent);

%create "paper"
c.x.paper=patch('Parent',c.x.window,...
   'Tag',c.x.all.Tag,...
   'FaceColor','white',...
   'EdgeColor','black',...
   'Xdata',[-.1 1.1 1.1 -.1],...
   'UIContextMenu',c.x.contextmenu,...
   'Ydata',[-1 -1 numRows+1 numRows+1]);


if c.att.isBorder
   borderColor=[0 0 0];
else
   borderColor=ltGrey;
end

c.x.mainBorder=patch('Parent',c.x.window,...
   'Tag',c.x.all.Tag,...
   'FaceColor','none',...
   'EdgeColor',borderColor,...
   'Xdata',[0 1 1 0],...
   'UIContextMenu',c.x.contextmenu,...
   'Ydata',[0 0 numRows numRows]);

[cWid,c]=validatecolumns(c);
if c.att.SingleValueMode
   allXzero=[0 cumsum(cWid/sum(cWid))];
   allXwid=cWid/sum(cWid);
   
   lColXzero=[allXzero(1:2:end-1) 1];
   rColXzero=allXzero(2:2:end);
   lColXwid=allXwid(1:2:end-1);
   rColXwid=allXwid(2:2:end);
else
   lColXzero=[0 cumsum(cWid/sum(cWid))];
   rColXzero=[];
   lColXwid=cWid/sum(cWid);
   rColXwid=[];
end

c.x.cellHandles=struct('leftCell',{},...
         'leftText',{},...
         'rightCell',{},...
         'rightText',{},...
         'codeText',{},...
         'middleLine',{},...
         'rightLine',{},...
         'bottomLine',{});

c.x.leftCell={};
c.x.rightCell={};  

c.x.leftText={};   
c.x.rightText={};   
c.x.codeText={};

c.x.middleLine={};  
c.x.rightLine={};   
c.x.bottomLine={};   



for i=numRows:-1:1
   for j=numCols:-1:1
      
      leftX=[lColXzero(j) lColXzero(j)+lColXwid(j),...
            lColXzero(j)+lColXwid(j) lColXzero(j)];
      
      cellSelectFcn=[c.x.getobj ...
            '''CellSelect'',' num2str(i) ...
            ',' num2str(j) ');'];
      
      leftCell=patch('Parent',c.x.window,...
         'Tag',c.x.all.Tag,...
         'FaceColor','none',...
         'EdgeColor','none',...
         'Interruptible','off',... %         'BusyAction','cancel',...
         'Xdata',leftX,...
         'UIContextMenu',c.x.contextmenu,...
         'Ydata',[numRows-i numRows-i numRows-i+1 numRows-i+1],...
         'ButtonDownFcn',cellSelectFcn);
      
      leftText=text('Parent',c.x.window,...
         'Tag',c.x.all.Tag,...
         'color','black',...
         'FontUnits','Points',...
         'VerticalAlignment','Middle',...
         'UIContextMenu',c.x.contextmenu,...
         'ButtonDownFcn',cellSelectFcn,...
         'Interruptible','off',... %'BusyAction','cancel',...
         'Interpreter','tex',...
         'Clipping','on',...
         'Units','data');
      
      codeText=text('Parent',c.x.window,...
         'Tag',c.x.all.Tag,...
         'color','black',...
         'String',c.att.TableContent(i,j).text,...
         'FontUnits','Points',...
         'HorizontalAlignment','Center',...
         'VerticalAlignment','Middle',...
         'Position',[-1000 -1000],...
         'Interruptible','off',...
         'BusyAction','cancel',...
         'Interpreter','none',...
         'Clipping','on',...
         'Units','data');
      
      bottomLine=line('Parent',c.x.window,...
         'Tag',c.x.all.Tag,...
         'Xdata',lColXzero(j:j+1),...
         'Ydata',[numRows-i numRows-i]);
      
      rightLine=line('Parent',c.x.window,...
         'Tag',c.x.all.Tag,...
         'Xdata',[lColXzero(j+1) lColXzero(j+1)],...
         'Ydata',[numRows-i numRows-i+1]);
      
      if c.att.SingleValueMode
         rightX=[rColXzero(j) rColXzero(j)+rColXwid(j),...
               rColXzero(j)+rColXwid(j) rColXzero(j)];

         rightCell=patch('Parent',c.x.window,...
            'Tag',c.x.all.Tag,...
            'FaceColor','none',...
            'EdgeColor','none',...
            'Interruptible','off',... %         'BusyAction','cancel',...
            'Xdata',rightX,...
            'UIContextMenu',c.x.contextmenu,...
            'Ydata',[numRows-i numRows-i numRows-i+1 numRows-i+1],...
            'ButtonDownFcn',cellSelectFcn);
         
         rightText=text('Parent',c.x.window,...
            'Tag',c.x.all.Tag,...
            'color','black',...
            'FontUnits','Points',...
            'VerticalAlignment','Middle',...
            'UIContextMenu',c.x.contextmenu,...
            'ButtonDownFcn',cellSelectFcn,...
            'Interruptible','off',... %'BusyAction','cancel',...
            'Interpreter','tex',...
            'Clipping','on',...
            'Units','data');
         
         middleLine=line('Parent',c.x.window,...
            'Tag',c.x.all.Tag,...
            'Xdata',[rColXzero(j) rColXzero(j)],...
            'Ydata',[numRows-i numRows-i+1]);
         
      else
         rightCell=[];
         rightText=[];
         middleLine=[];
      end
            
      
      c.x.cellHandles(i,j)=struct('leftCell',leftCell,...
         'leftText',leftText,...
         'rightCell',rightCell,...
         'rightText',rightText,...
         'codeText',codeText,...
         'middleLine',middleLine,...
         'rightLine',rightLine,...
         'bottomLine',bottomLine);
      
      c.x.leftCell{i,j}  = leftCell;
      c.x.rightCell{i,j} = rightCell;
      c.x.leftText{i,j}  = leftText;
      c.x.rightText{i,j} = rightText;
      c.x.codeText{i,j} = codeText;
      c.x.middleLine{i,j}= middleLine;
      c.x.rightLine{i,j} = rightLine;
      c.x.bottomLine{i,j} = bottomLine;
      
      RenderCell(c.att.TableContent(i,j),c.x.cellHandles(i,j));
      
   end
end

%-------- Column Splitters ----------------

allXzero=[0 cumsum(cWid/sum(cWid))];

set(c.x.window,...
   'Xtick',allXzero,...
   'Ytick',(0:numRows));

c.x.colLine=[];

if ~isempty(cWid)
   columnX=cumsum(cWid(1:end-1)/sum(cWid));
   for j=length(columnX):-1:1
      c.x.colLine(j)=line('Parent',c.x.window,...
         'Tag',c.x.all.Tag,...
         'ButtonDownFcn',...
         [c.x.getobj,'''ColumnSelect'',',num2str(j),');'],... 
         'Color','black',...
         'LineStyle',':',...
         'Xdata',[columnX(j) columnX(j)],...
         'Ydata',[-.25 numRows+.25]);
   end
end

%-----------Title Controls-------------------

titleCell=patch('Parent',c.x.window,...
   'Tag',c.x.all.Tag,...
   'FaceColor','none',...
   'EdgeColor','none',...
   'Xdata',[0 1 1 0],...
   'UIContextMenu',c.x.contextmenu,...
   'Ydata',[numRows numRows numRows+1 numRows+1],...
   'ButtonDownFcn',[c.x.getobj ...
      '''CellSelect'',0,0);']);

titleText=text('Parent',c.x.window,...
   'FontUnits','Points',...
   'HorizontalAlignment','center',...
   'VerticalAlignment','Middle',...
   'UIContextMenu',c.x.contextmenu,...
   'ButtonDownFcn',[c.x.getobj,...
      '''CellSelect'',0,0);'],...
   'Interpreter','tex',...
   'Clipping','on',...
   'Units','data',...
   'Position',[.5 numRows+.5]);

titleCode=text('Parent',c.x.window,...
   'String',c.att.TableTitle,...
   'FontUnits','Points',...
   'HorizontalAlignment','center',...
   'VerticalAlignment','Middle',...
   'Interpreter','none',...
   'Clipping','on',...
   'Units','data',...
   'Position',[-1000 -1000]);

c.x.titleHandles=struct('leftCell',titleCell,...
   'leftText',titleText,...
   'rightCell',[],...
   'rightText',[],...
   'codeText',titleCode,...
   'middleLine',[],...
   'rightLine',[],...
   'bottomLine',[]);


RenderCell(LocTitleEntry(c),c.x.titleHandles);


c=NewView(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=UpdateButtons(c,row,col)

if nargin<3
   row=c.x.currcell(1);
   col=c.x.currcell(2); 
end

if row<1 | col<1
   layoutEnable=logical([0 0 0 0]);
   alignEnable='off';
   entry=struct('align','c',...
      'text','',...
      'render',c.att.TitleRender);
else
   alignEnable='on';
   layoutEnable=logical([1 1 1 1]);
   %if only 1 column, disable the delete column button
   layoutEnable(4)=(size(c.att.TableContent,1)>1);
   %if only 1 row, disable the delete row button
   layoutEnable(2)=(size(c.att.TableContent,2)>1);
   entry=c.att.TableContent(row,col);
end

%-------------------------update layout buttons--------------
for i=1:length(layoutEnable)
   lUD=get(c.x.layoutbtn(i),'UserData');
   if layoutEnable(i)
      okField='ok';
      okEnable='on';
   else
      okField='no';
      okEnable='off';
   end
   
   set(c.x.layoutbtn(i),'CData',getfield(lUD,okField),...
      'Enable',okEnable)
end

%-------------update alignment buttons-----------------------
desiredbutton=entry.align;
for i=1:length(c.x.alignbtn)
   currbutton=lower(get(c.x.alignbtn(i),'UserData'));   
   if currbutton(1)==desiredbutton(1)
      set(c.x.alignbtn(i),'Value',1,'enable',alignEnable)
   else
      set(c.x.alignbtn(i),'Value',0,'enable',alignEnable)
   end
end

%------------update property rendering popup menu---------------
renderCodes=get(c.x.proprender,'UserData');
if isnumeric(entry.render)
   renderIndex=min(max(entry.render,1),length(renderCodes));
   cellRenderCode=renderCodes{renderIndex};
   if row<1 | col<1
      c.att.TitleRender=cellRenderCode;
   else
      c.att.TableContent(row,col).render=cellRenderCode;
   end   
else
   renderIndex=find(strcmp(renderCodes,entry.render));
   if length(renderIndex)>0
      renderIndex=renderIndex(1);
   else
      renderIndex=1;
      cellRenderCode=renderCodes{renderIndex};
      if row<1 | col<1
         c.att.TitleRender=cellRenderCode;
      else
         c.att.TableContent(row,col).render=cellRenderCode;
      end   
   end
end
set(c.x.proprender,'Value',renderIndex);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ChangeFilter(c)

filterList=get(c.x.propfilter,'UserData');
filterIndex=get(c.x.propfilter,'Value');

set(c.x.proplist,'String',...
   tableref(c,'GetPropList',filterList{filterIndex}),...
   'Value',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=UpdateAlign(c,align)

row=c.x.currcell(1);
col=c.x.currcell(2);

if row>0 & col>0
   c.att.TableContent(row,col).align=align;
   
   RenderCell(c.att.TableContent(row,col),...
      c.x.cellHandles(row,col));

   
   c=UpdateButtons(c,row,col);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=UpdateRender(c,newRender)

renderCodes=get(c.x.proprender,'UserData');

if nargin<2
   renderIndex=get(c.x.proprender,'Value');
   newRender=renderCodes{renderIndex};
else
   renderIndex=find(strcmp(renderCodes,newRender));
   if length(renderIndex)>0
      renderIndex=renderIndex(1);
   else
      renderIndex=1;
   end
   set(c.x.proprender,'Value',renderIndex);
end

row=c.x.currcell(1);
col=c.x.currcell(2);

if row<1 | col<1
   c.att.TitleRender=newRender;
   entry=LocTitleEntry(c);
   handles=c.x.titleHandles;
else
   c.att.TableContent(row,col).render=newRender;
   entry=c.att.TableContent(row,col);
   handles=c.x.cellHandles(row,col);
end

RenderCell(entry,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=CellSelect(c,row,col,selectionType)
%called when a cell is selected in the draw window

if nargin<4
   selectionType=get(c.x.all.Parent,'SelectionType');
   if nargin<3
      row=c.x.currcell(1);
      col=c.x.currcell(2);
   end
end

if strcmp(selectionType,'alt')
   return
end

set(c.x.contextmenu,'visible','off');

lCell=c.x.leftCell;
rCell=c.x.rightCell;
allCells=[lCell{:,:},rCell{:,:},c.x.titleHandles.leftCell];
if all(ishandle(allCells))
   set(allCells,'selected','off');
else
   %Some cell handles are not valid - this happens 
   %most of the time if a cell is selected while another cell
   %is in "edit" mode
   return;
end

c.x.currcell=[row col];

if row<1 | col<1
   handles=c.x.titleHandles;
else
   handles=c.x.cellHandles(row,col);
end

set([handles.leftCell,handles.rightCell],'selected','on');

c=UpdateButtons(c);

switch selectionType
case 'open'
   xPos=get(handles.leftCell,'Xdata');
   yPos=get(handles.leftCell,'Ydata');
   
   fontSize=get(handles.leftText,'fontsize');
   
   if isempty(handles.rightCell)
      %non-split mode.  Position is determined from left cell
      editPos=[mean(xPos) mean(yPos)];
      textMove=[handles.leftText];
      nontextMove=[handles.leftCell,c.x.colLine];
   else
      %split mode.  Position is determined as average of left 
      %and right cells
      editPos=[max(xPos) mean(yPos)];
      
      textMove=[handles.leftText,handles.rightText];
      nontextMove=[handles.leftCell,handles.rightCell,...
            handles.middleLine,c.x.colLine];
   end
   
   if length(textMove)>1
      posName={'Position'};
   else
      posName='Position';
   end
   if length(nontextMove)>1
      xdName={'Xdata'};
      ydName={'Ydata'};
   else
      xdName='Xdata';
      ydName='Ydata';
   end
   
   textPosition=get(textMove,'Position');
   set(textMove,'Position',[-1000 1000]);
   nontextXdata=get(nontextMove,'Xdata');
   nontextYdata=get(nontextMove,'Ydata');
   set(nontextMove,'Xdata',[-1001 -1000 -1000 -1001],...
      'Ydata',[1000 1001 1001 1000]);
   
   set(handles.codeText,...
      'FontSize',fontSize,...
      'Position',editPos,...
      'editing','on');
   waitfor(handles.codeText,'editing','off');
   if ishandle(handles.codeText)
      
      cellText=singlelinetext(c,get(handles.codeText,'String'),' ');
      set(handles.codeText,'Position',[-1000 -1000],...
         'String',cellText);
      
      set(textMove,posName,textPosition);
      set(nontextMove,xdName,nontextXdata,...
         ydName,nontextYdata);
      
      %Certain callbacks may have been made during
      %editing which we would like to honor.  Make
      %sure that the cell also uses the currently
      %selected P-v render mode and alignment.
      renderOpts=get(c.x.proprender,'UserData');
      cellRender=renderOpts{get(c.x.proprender,'Value')};
      
      if row<1 | col<1
         c.att.TableTitle=cellText;
         c.att.TitleRender=cellRender;
         entry=LocTitleEntry(c);
      else
         alignVals=get(c.x.alignbtn,'value');
         alignVals=[alignVals{:}];
         alignIndex=find(alignVals==1);
         if length(alignIndex)>0
            alignIndex=alignIndex(1);
         else
            alignIndex=1;
         end
         
         cellAlign=get(c.x.alignbtn(alignIndex),'UserData');
         
         entry=c.att.TableContent(row,col);
         entry.text=cellText;
         entry.align=cellAlign;
         entry.render=cellRender;
         c.att.TableContent(row,col)=entry;
      end
      
      newModeValue=get(c.x.SingleValueMode,'Value');
      
      if newModeValue~=c.att.SingleValueMode
         c=ChangeMode(c);
      else
         RenderCell(entry,handles);
      end
      
      %Another cell may have been selected while we were in
      %waitfor mode.  Update c.x.currcell to reflect this
      if all(ishandle(allCells))
         leftCells=c.x.leftCell;
         lcSize=size(leftCells);
         i=1;
         indexFound=logical(0);
         h=c.x.titleHandles.leftCell;
         if strcmp(get(h,'Selected'),'on')
            row=0;
            col=0;
            indexFound=logical(1);
         else
            while i<=lcSize(1) & ~indexFound
               j=1;
               while j<=lcSize(2) & ~indexFound
                  h=leftCells{i,j};
                  if ishandle(h)
                     if strcmp(get(h,'Selected'),'on')
                        row=i;
                        col=j;
                        indexFound=logical(1);
                     end
                  end
                  j=j+1;
               end
               i=i+1;
            end
         end
         
            
         c.x.currcell=[row,col];
         set(allCells,'selected','off');
         if row>0
            set([c.x.leftCell{row,col},c.x.rightCell{row,col}],...
               'selected','on');
         else
            set(c.x.titleHandles.leftCell,'selected','on');
         end
         
      end
      
   else
      %something went wrong and the handle no longer
      %exists.  This means that we probably shouldn't
      %update C
      c=[];
      %in rptcp/attribute if c does not return as a 
      %component, the pointer will not update
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ColumnSelect(c,col)

if ~strcmp(LocSelectionType(c),'normal')
   return
end

linH=c.x.colLine(col);
axH=get(linH,'Parent');
figH=get(axH,'Parent');

set(linH,'UserData',logical(1));
oldX=get(linH,'Xdata');
oldX=oldX(1);


%tableCoords=LocCoordTransform(axH,[0 1 1 1]);
%minX=tableCoords(1);
%maxX=tableCoords(1)+tableCoords(3);
cWid=validatecolumns(c);
minX=sum(cWid(1:col-1))/sum(cWid)+.05;
maxX=sum(cWid(1:col+1))/sum(cWid)-.05;

set(linH,...
   'Linestyle','-');
if maxX>minX
   oldProps=struct('WindowButtonMotionFcn',...
      get(figH,'WindowbuttonMotionFcn'),...
      'WindowButtonUpFcn',get(figH,'WindowButtonUpFcn'),...
      'Interruptible',get(figH,'Interruptible'),...
      'Pointer','arrow');
   
   set(figH,...
      'Pointer','left',...
      'Interruptible','on',...
      'WindowButtonUpFcn',['set(' num2str(linH,32) ...
         ',''UserData'',logical(0))'],...
      'WindowButtonMotionFcn','pause(0),drawnow');
   
   while get(linH,'UserData')
      currMousePos=get(axH,'CurrentPoint');      
      newX=min(maxX,max(minX,currMousePos(1,1)));      
      set(linH,'Xdata',[newX newX]);
      pause(0);
   end
   
   currMousePos=get(axH,'CurrentPoint');
   newX=min(maxX,max(minX,currMousePos(1,1)));
   
   allX=get(c.x.colLine,'Xdata');
   endX=[1 1];
   if isempty(allX)
      allX={endX};
   elseif ~iscell(allX)
      allX={ allX ; endX};
   else
      allX=[allX ; {endX}];
   end
   
   prevWid=0;
   for i=1:length(allX)
      currX=allX{i}(1);
      cWid(i)=currX-prevWid;
      prevWid=currX;      
   end
   
   [newWidths,c]=validatecolumns(c,cWid);
   
   set(figH,oldProps);
   %redraw will set the linestyle back to normal
   c=Redraw(c);   
   c=CellSelect(c);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   c=TextSelect(c,row,cell)

c=CellSelect(c,row,cell);

set(c.x.text(row,cell),'editing','on')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   c=ZoomClick(c,z)
%z>0 is zoom in
%z<0 is zoom out

magamount=1.25;
if z>0
   c.x.mag=c.x.mag*magamount;
else
   c.x.mag=c.x.mag/magamount;
end

c=NewView(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LayoutClick(c,index);

set(findall(allchild(c.x.window),'type','text'),...
   'editing','off');

row=max(1,c.x.currcell(1));
col=max(1,c.x.currcell(2));

%set(c.x.text,'Editing','off');
%set(c.x.titleText,'Editing','off');


entry=c.att.TableContent(row,col);
defaultCell=struct('align',entry.align,...
   'text','',...
   'render',entry.render);

[numRows,numCols]=size(c.att.TableContent);

[colWid,c]=validatecolumns(c);

colWid=c.att.ColWidths;

switch index
case 1  %add column to left
   c.att.TableContent(:,col+1:end+1)=...
      c.att.TableContent(:,col:end);
   
   for i=1:numRows
      c.att.TableContent(i,col).text='';
   end
   %[c.att.TableContent(1:numRows,col).text]=deal('');
   
   cwMean=2*mean(colWid);
   
   c.att.ColWidths=[colWid(1:2*col),...
         [.3 .7]*cwMean,...
         colWid(2*col+1:end)];
   c.x.currcell=[row col+1];
case 2  %delete column
   c.att.TableContent=...
      c.att.TableContent(1:end,[1:col-1,col+1:end]);
   c.att.ColWidths=colWid([1:2*col-1,2*(col+1):end]);
   
   c.x.currcell=[row min(col,numCols-1)];
   
case 3  %add row above
   c.att.TableContent(row+1:end+1,:)=...
      c.att.TableContent(row:end,:);
   for i=1:numCols
      c.att.TableContent(row,i).text='';
   end   
   %[c.att.TableContent(row,:).text]=deal('');   
   c.x.currcell=[row+1 col];
case 4  %delete row
   c.att.TableContent=...
      c.att.TableContent([1:row-1,row+1:end],1:end);
   c.x.currcell=[min(row,numRows-1) col];
case 5 %add column to right
    cwMean=2*mean(colWid);
    if col<numCols
        c.att.TableContent(:,col+2:end+1)=...
            c.att.TableContent(:,col+1:end);
        c.att.ColWidths=[colWid(1:2*(col+1)),...
                [.3 .7]*cwMean,...
                colWid(2*(col+2):end)];
    else
        c.att.ColWidths=[colWid,[.3 .7]*cwMean];
    end
    c.att.TableContent(:,col+1)=c.att.TableContent(:,col);
    
    for i=1:numRows
        c.att.TableContent(i,col+1).text='';
    end
    c.x.currcell=[row col];
    %[c.att.TableContent(1:numRows,col).text]=deal('');
case 6 %add row below
    if row<numRows
        c.att.TableContent(row+2:end+1,:)=...
            c.att.TableContent(row+1:end,:);
    end
    c.att.TableContent(row+1,:)=c.att.TableContent(row,:);
    
    for i=1:numCols
        c.att.TableContent(row+1,i).text='';
    end
    c.x.currcell=[row col];
end


numRows=max(1,size(c.att.TableContent,1));
currcenter=get(c.x.slider(2),'Value');
if currcenter>numRows
   set(c.x.slider(2),'Value',numRows,'Max',numRows);
else
   set(c.x.slider(2),'Max',numRows);
end


c=Redraw(c);
c=CellSelect(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=PropListSelect(c)

if strcmp(LocSelectionType(c),'open')
   c=AddProp(c);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=AddProp(c)

if ~isempty(c.x.currcell)   
   set(findall(allchild(c.x.window),'type','text'),...
      'editing','off');
   
   row=c.x.currcell(1);
   col=c.x.currcell(2);
   
   if row<1 | col<1
      replaceValues=logical(0);
      cellHandles=c.x.titleHandles;
      %we are editing the caption
   else
      cellHandles=c.x.cellHandles(row,col);
      if c.att.SingleValueMode
         replaceValues=logical(1);
      else
         replaceValues=logical(0);
      end
   end
   
   list=get(c.x.proplist,'String');
   listIndex=get(c.x.proplist,'Value');
   listname=list{listIndex};
   
   
   if replaceValues
      currtext=['%<',listname,'>'];
   else
      prevText=singlelinetext(c,get(cellHandles.codeText,'String'),' ');
      %need some sort of protection for nx2 text arrays
      currtext=[prevText,' %<',listname,'>'];
   end
   
   set(cellHandles.codeText,'String',currtext);   
   
   if row<1 | col<1
      c.att.TableTitle=currtext;
      entry=LocTitleEntry(c);
   else
      c.att.TableContent(row,col).text=currtext;
      entry=c.att.TableContent(row,col);
   end
   
   RenderCell(entry,cellHandles);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=SelectPreset(c)

if get(c.x.presetpop,'Value')>1
   set(c.x.presetaddbtn,'enable','on');
else
   set(c.x.presetaddbtn,'enable','off');
end   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ApplyPreset(c);

list=get(c.x.presetpop,'String');

c=applypresettable(rptproptable,c,...
   list{get(c.x.presetpop,'Value')});



tSize=size(c.att.TableContent);
if min(tSize)>0
   c.x.currcell=[1 1];
else
   c.x.currcell=[0 0];
end

set(c.x.SingleValueMode,'value',c.att.SingleValueMode);

set(c.x.presetpop,'Value',1)
set(c.x.presetaddbtn,'enable','off');

set(c.x.slider(1),'value',.5); %X value

%tSize(1) is the number of rows
set(c.x.slider(2),...  
   'Min',0,...
   'Max',tSize(1),...
   'value',tSize(1)/2); %Y axis control



c=Redraw(c);
c=CellSelect(c,c.x.currcell(1),c.x.currcell(2),0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  c=ChangeMode(c);

c.att.SingleValueMode=get(c.x.SingleValueMode,'value');

c=Redraw(c);
c=CellSelect(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=ToggleBorder(c,whichBorder,row,col);

if nargin<4
   row=c.x.currcell(1);
   col=c.x.currcell(2);
end

if strcmp(whichBorder,'frame')
   c.att.isBorder=~c.att.isBorder;   
   
   if c.att.isBorder
      bColor=[0 0 0];
      rightOK=[2,3];
      bottomOK=[1,3];
   else
      bColor=ltGrey;
      rightOK=[0,1];
      bottomOK=[0,2];
   end
   
   set(c.x.mainBorder,'EdgeColor',bColor);
   
   %set right and bottom cell borders to match frame border
   tSize=size(c.att.TableContent);
   for i=1:tSize(1)
      if ~any(find(rightOK==c.att.TableContent(i,end).border))
         c.att.TableContent(i,end).border=...
            LocToggleValue(c.att.TableContent(i,end).border,logical(1));
         
         RenderCell(c.att.TableContent(i,end),...
            c.x.cellHandles(i,end));
      end
   end
   for i=1:tSize(2)
      if ~any(find(bottomOK==c.att.TableContent(end,i).border))
         c.att.TableContent(end,i).border=...
            LocToggleValue(c.att.TableContent(end,i).border,logical(0));
         
         RenderCell(c.att.TableContent(end,i),...
            c.x.cellHandles(end,i));
      end
   end
   
else
   switch whichBorder
   case 'left'
      horiz=logical(1);
      col=col-1;
   case 'top'
      horiz=logical(0);
      row=row-1;
   case 'bottom'
      horiz=logical(0);
   case 'right'
      horiz=logical(1);
   end
   c.att.TableContent(row,col).border=...
      LocToggleValue(c.att.TableContent(row,col).border,horiz);
   
   RenderCell(c.att.TableContent(row,col),...
      c.x.cellHandles(row,col));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tog,isOn]=LocToggleValue(orig,isHoriz);

%   case 0 %no border
%   case 1 %bottom only
%   case 2 %right only
%   case 3 %bottom and right

if isHoriz
   switch orig
   case 0
      tog=2;
      isOn=logical(1);
   case 1
      tog=3;
      isOn=logical(1);
   case 2
      tog=0;
      isOn=logical(0);
   case 3
      tog=1;
      isOn=logical(0);
   end   
else
   switch orig
   case 0
      tog=1;
      isOn=logical(1);
   case 1
      tog=0;
      isOn=logical(0);
   case 2
      isOn=logical(1);
      tog=3;
   case 3
      tog=2;
      isOn=logical(0);
   end   
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocPointerData(c);
%NOT USED ANYMORE - sets pointer to "left arrow" over resize column lines

cHandles=c.x.colLine;
c.x.ComponentPointer=[];

for i=length(cHandles):-1:1
   xData=get(cHandles(i),'Xdata');
   yData=get(cHandles(i),'Ydata');
   
   c.x.ComponentPointer(i)=struct('Area',...
      LocCoordTransform(c.x.window,[xData(1) yData(1) 0 yData(2)]),...
      'Pointer','left');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function figPos=LocCoordTransform(ax,axPos)

axFigPos=get(ax,'Position');
axXlim=get(ax,'Xlim');
axYlim=get(ax,'Ylim');

subMat=[axXlim(1) axYlim(1) 0 0];
%xScale=(axXlim(2)-axXlim(1))/axFigPos(3);
%yScale=(axYlim(2)-axYlim(1))/axFigPos(4);
xScale=axFigPos(3)/(axXlim(2)-axXlim(1));
yScale=axFigPos(4)/(axYlim(2)-axYlim(1));

multMat=[xScale yScale xScale yScale];
addMat=[axFigPos(1) axFigPos(2) 0 0];

figPos=max((axPos-subMat).*multMat+addMat,[0 0 2 2]);

%create patches to show area of transform
%for debugging purposes
%myFig=get(ax,'Parent');
%tpatch=uicontrol('style','frame','units','points',...
%   'position',figPos,...
%   'parent',myFig,...
%   'enable','inactive',...
%   'BackgroundColor','red',...
%   'ButtonDownFcn','delete(gcbo)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  c=InitializeContextMenu(c,type,row,col)

if nargin<4
   col=c.x.currcell(2);
   if nargin<3
      row=c.x.currcell(1);
      if nargin<2
         type='main';
      end
   end
end

numRows=size(c.att.TableContent);
numCols=numRows(2);
numRows=numRows(1);

cmi=c.x.contextmenuItems;

allItems=cmi.all;
disableItems=[];
checkItems=[];

if c.att.isBorder
   checkItems=[checkItems cmi.mainFrame];
end

if row<1 | col<1
   %we are dealing with a title
   disableItems=[disableItems cmi.mainJust cmi.mainBorder ...
         cmi.jleft cmi.jcenter cmi.jright cmi.jdouble ...
         cmi.bleft cmi.btop cmi.bbottom cmi.bright ...
         cmi.mainLayout];   
   renderType=c.att.TitleRender;
else
   currCell=c.att.TableContent(row,col);
   if row==1 %deal with the top border
      disableItems=[disableItems cmi.btop];
      if c.att.isBorder
         checkItems=[checkItems cmi.btop];
      end
   else
      upperBorder=c.att.TableContent(row-1,col).border;
      if upperBorder==1 | upperBorder==3
         checkItems=[checkItems cmi.btop];
      end
   end
   
   %if row==numRows %deal with the bottom border
   %   disableItems=[disableItems cmi.bbottom];
   %   if c.att.isBorder
   %      checkItems=[checkItems cmi.bbottom];
   %   end
   %else        
      if currCell.border==1 | currCell.border==3
         checkItems=[checkItems cmi.bbottom];
      end
   %end
   
   if col==1 %deal with the left border
      disableItems=[disableItems cmi.bleft];
      if c.att.isBorder
         checkItems=[checkItems cmi.bleft];
      end
   else
      leftBorder=c.att.TableContent(row,col-1).border;
      if leftBorder==2 | leftBorder==3
         checkItems=[checkItems cmi.bleft];
      end
   end
   
   %if col==numCols %deal with the right border
   %   disableItems=[disableItems cmi.bright];
   %   if c.att.isBorder
   %      checkItems=[checkItems cmi.bright];
   %   end
   %else        
      if currCell.border==2 | currCell.border==3
         checkItems=[checkItems cmi.bright];
      end
   %end
   
   
   %deal with centering control
   switch currCell.align
   case 'l'
      checkItems=[checkItems cmi.jleft];
   case 'r'
      checkItems=[checkItems cmi.jright];
   case 'c'
      checkItems=[checkItems cmi.jcenter];
   case 'j'
      checkItems=[checkItems cmi.jdouble];
   end
   
   renderType=currCell.render;
   
   %deal with enabling/unenabling delete row/column items
   if numCols==1
       disableItems=[disableItems cmi.layout(3)];
   end
   if numRows==1
       disableItems=[disableItems cmi.layout(6)];
   end
   
end

renderCodes=get(c.x.proprender,'UserData');
if isnumeric(renderType)
   renderIndex=min(max(renderType,1),length(renderCodes));
   cellRenderCode=renderCodes{renderIndex};
   if row<1 | col<1
      c.att.TitleRender=cellRenderCode;
   else
      c.att.TableContent(row,col).render=cellRenderCode;
   end   
else
   renderIndex=find(strcmp(renderCodes,renderType));
   if length(renderIndex)>0
      renderIndex=renderIndex(1);
   else
      renderIndex=1;
      cellRenderCode=renderCodes{renderIndex};
      if row<1 | col<1
         c.att.TitleRender=cellRenderCode;
      else
         c.att.TableContent(row,col).render=cellRenderCode;
      end   
   end
end
checkItems=[checkItems cmi.render(renderIndex)];


set(allItems,'Enable','on','Checked','off');
set(disableItems,'Enable','off');
set(checkItems,'Checked','on');
drawnow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RenderCell(entry,handles);


lXpos=get(handles.leftCell,'Xdata');

middleY=mean(get(handles.leftCell,'Ydata'));

if ~isempty(handles.rightCell)
   dummyComp.att.SingleValueMode=logical(1);
   [leftString,rightString]=parseproptext(dummyComp,entry,1);
   
   rXpos=get(handles.rightCell,'Xdata');
   
   textString={leftString;rightString};
   
   switch entry.align
   case 'l'
      lX=min(lXpos)+.01;
      rX=min(rXpos)+.01;
      textHorizAlign={'left';'left'};
      
   case 'r'
      lX=max(lXpos)-.01;
      rX=max(rXpos)-.01;
      hAlign='right';
      textHorizAlign={'right';'right'};
      
   case 'c'
      lX=max(lXpos)-.01;
      rX=min(rXpos)+.01;
      
      textHorizAlign={'right';'left'};
      
   otherwise
      lX=min(lXpos)+.01;
      rX=max(rXpos)-.01;
      textHorizAlign={'left';'right'};
   end
   
   textPos={[lX middleY];[rX middleY]};
   
else
   dummyComp.att.SingleValueMode=logical(0);
   [leftString,rightString]=parseproptext(dummyComp,entry,1);
   
   textString={leftString};
   
   switch entry.align
   case 'l'
      x=min(lXpos)+.01;;
      hAlign='left';
   case 'r'
      x=max(lXpos)-.01;
      hAlign='right';
   otherwise
      x=mean(lXpos);
      hAlign='center';
   end
   
   textPos={[x middleY]};
   textHorizAlign={hAlign};
   
end

set([handles.leftText,handles.rightText],...
   {'Position'},textPos,...
   {'String'},textString,...
   {'HorizontalAlignment'},textHorizAlign);

switch entry.border
case 0 %no border
   bottomColor=ltGrey;
   rightColor=ltGrey;
case 1 %bottom only
   bottomColor=[0 0 0];
   rightColor=ltGrey;
case 2 %right only
   bottomColor=ltGrey;
   rightColor=[0 0 0];
case 3 %bottom and right
   bottomColor=[0 0 0];
   rightColor=[0 0 0];
end

set([handles.bottomLine],'Color',bottomColor);
set([handles.middleLine,handles.rightLine],...
   'Color',rightColor);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocTitleEntry(c,entry);
%c=LocTitleEntry(c,entry)
%entry=LocTitleEntry(c)

if nargin<2
   out=struct('align','c',...
      'text',{c.att.TableTitle},...
      'border',0,...
      'render',{c.att.TitleRender});
else
   out=c;
   out.att.TableTitle=entry.text;
   out.att.TitleRenter=entry.render;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function greyColor=ltGrey(isTrue)

if nargin<1 | ~isTrue
   greyColor=[.8 .8 .8];
else
   greyColor=[0  0 0];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sType=LocSelectionType(c)

sType=get(c.x.all.Parent,'SelectionType');


