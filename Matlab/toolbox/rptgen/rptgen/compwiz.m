function out=compwiz(action,w,varargin)
%COMPWIZ - Report Generator component creation tool
%   The component creation tool creates a framework for
%   custom Report Generator components.
%
%   Warning: This tool creates components according to the Version 1.x
%   API.  Components created here will not function in the Report
%   Generator Editor.
%
%   See also SETEDIT, REPORT, RPTLIST, RPTCONVERT

%
%  Help from v1:
%   The component creation wizard contains five pages
%   which gather the information needed to set up
%   a Report Generator component.
%
%   1) Component Category - set the general category for
%           the new component.  Can select from
%           existing categories or create a new one.
%   2) Component Name - set the common name, function
%           name, and directory where the component
%           is located.
%   3) Component Attributes - set the switches which
%           appear on the "Options" page and affect
%           how the component behaves during generation.
%   4) Component Methods - decide whether to inherit
%           default OUTLINESTRING and ATTRIBUTE 
%           behavior or to create custom methods.
%   5) Confirm Selections - review decisions made
%           and click "create" to write the component.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:47 $

if nargin==0
	if true; %Component creation not shipping in R14 (RptgenML.v1mode)
		uiwizard compwiz;
	else
		%This is the only code for handling v2.x
		cbkCreateComponent(RptgenML.Root);
	end
else
   if nargin<2 | isempty(w)
      fig=gcbf;
      w=get(fig,'UserData');
   else
      fig=[];
   end
   
   out=feval(['Loc' action],w,varargin{:});
   
   if ~isempty(fig)
      set(fig,'UserData',out);
   end
end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These functions deal with the "main" part of  %
% the wizard.                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function skipname=LocMainSkipTo(w);
%This function checks "w" to see if it is 
%permissible to "skip".  If not, returns empty.

skipname='ConfirmPage';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  w=LocMainInitialize(w);
%This function initializes "w"

w.data.FileName='ccu_mycomp';
w.data.Path=pwd;
w.data.Name='My Component';
w.data.Type='CU';
w.data.newTypeID='XX';
w.data.newTypeName='New Component Category';
w.data.Desc='A new component.';
w.data.IsLoop=logical(0);
w.data.att=LocGetEmptyAttributesStructure;
w.data.isAttributeFile=1;
%w.data.isInitializeFile=0;
w.data.isOutlinestringFile=1;

w.options.FirstPage='TypePage';
w.options.Name='Component Creation Wizard';
w.options.isSkipTo=logical(1);
w.options.isStatusBar=logical(1);
w.options.SkipString='Skip to End >>';
w.options.isCancel=logical(1);
w.options.isRoadmap=logical(1);
w.options.isTitle=logical(0);
w.options.PageSize=[300 200];
w.options.FigureTag='rptgen_compwiz_Figure';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These functions deal with the "Type" page     %       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=LocTypePageInformation(w)

info.Title='Component Category';
info.Pathlist = {1 'NamePage'};
info.Whichpath=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocTypePagePreDraw(w);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocTypePageDraw(w);


w.h.typetext=uicontrol(w.hg.all,...
   'Visible','off',...
   'Style','text',...
   'String','Component category ',...
   'HorizontalAlignment','left');

[compTypes,allComp]=LocAllComponents;

compTypes=allcomptypes(rptparent);

typeID={compTypes.Type, 'NEWTYPE'};
typeName={compTypes.Fullname, '**Make New Component Category**'};

index=find(strcmp(typeID,w.data.Type));
if isempty(index)| index==length(typeID)
   index=length(typeID);
   customEnable='on';
else
   index=index(1);
   customEnable='off';
end

w.h.typepop=uicontrol(w.hg.all,...
   'Visible','off',...
   'Style','listbox',...
   'String',typeName,...
   'UserData',typeID,...
   'BackgroundColor',[1 1 1],...
   'Value',index,...
   'ListboxTop',index,...
   'HorizontalAlignment','left',...
   'Callback','compwiz TypeChange;');

w.h.cuIDtext=uicontrol(w.hg.all,...
   'Visible','off',...
   'Style','text',...
   'String',' Category ID ',...
   'HorizontalAlignment','left');

w.h.cuIDedit=uicontrol(w.hg.all,...
   'Visible','off',...
   'Style','edit',...
   'BackgroundColor',[1 1 1],...
   'Enable',customEnable,...
   'Callback','compwiz CustomEdit;',...
   'HorizontalAlignment','Left');

w.h.cuDESCtext=uicontrol(w.hg.all,...
   'Visible','off',...
   'Style','text',...
   'String',' Category name ',...
   'HorizontalAlignment','left');

w.h.cuDESCedit=uicontrol(w.hg.all,...
   'Visible','off',...
   'Style','edit',...
   'Enable',customEnable,...
   'BackgroundColor',[1 1 1],...
   'Callback','compwiz CustomEdit;',...
   'HorizontalAlignment','Left');

posH=[w.h.typetext w.h.typepop w.h.cuIDtext w.h.cuIDedit ...
      w.h.cuDESCtext w.h.cuDESCedit];

typeExtent=get(w.h.cuIDtext,'Extent');

typeWidth=typeExtent(3)+2*w.hg.pad;

listHt=w.hg.Ylim-w.hg.Yzero-3*w.hg.barht-w.hg.pad;

barht=w.hg.barht;
pad=w.hg.pad;
allWidth=w.hg.Xlim-w.hg.Xzero;

set(posH,{'Position'},...
   {[w.hg.Xzero w.hg.Ylim-barht allWidth barht];...
      [w.hg.Xzero w.hg.Ylim-barht-listHt allWidth listHt];...
      [w.hg.Xzero w.hg.Yzero typeWidth barht];...
      [w.hg.Xzero w.hg.Yzero+barht typeWidth barht];...
      [w.hg.Xzero+typeWidth w.hg.Yzero allWidth-typeWidth barht];...
      [w.hg.Xzero+typeWidth w.hg.Yzero+barht allWidth-typeWidth barht]});

w=LocTypeChange(w);

set(posH,'Visible','on')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  w=LocTypeChange(w);

typeCode =get(w.h.typepop,'UserData');
typeDesc =get(w.h.typepop,'String');
typeIndex=get(w.h.typepop,'Value');

listDesc=typeDesc{typeIndex};
listCode=typeCode{typeIndex};

w.data.Type=listCode;

if ~strcmp(listCode,'NEWTYPE')
   enable='off';
   editStrings={listCode;listDesc};
   statString=sprintf('Use the "%s" Setup File Editor category.',listDesc);
else
   editStrings={w.data.newTypeID;w.data.newTypeName};
   enable='on';
   statString='Enter a two-letter identifier code and description for your new Category';
end

set(w.h.StatusBar,'String',statString);
set([w.h.cuIDedit w.h.cuDESCedit],...
   'Enable',enable,...
   {'String'},editStrings);

w=LocChangeName(w);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   w=LocCustomEdit(w)

getID=get(w.h.cuIDedit,'String');

types=get(w.h.typepop,'UserData');

if length(getID)<2
   errMsg='Error - identifiers should be 2 characters long';   
   getID=w.data.newTypeID;
elseif ~isempty(find(strcmpi(types,getID(1:2))))
   errMsg=sprintf('Error - Identifier %s is already being used.',upper(getID(1:2)));   
   getID=w.data.newTypeID;
elseif length(getID)>2
   errMsg='Warning - identifiers should be 2 characters long';
   getID=upper(getID(1:2));
else
   errMsg='';
   getID=upper(getID);
end

w.data.newTypeID=getID;
set(w.h.cuIDedit,'String',getID);
w.data.newTypeName=get(w.h.cuDESCedit,'String');

set(w.h.StatusBar,'String',errMsg);


w=LocChangeName(w);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocChangeName(w)
%this function changes the default name of the component

if ~strcmp(w.data.Type,'NEWTYPE')
   type=lower(w.data.Type);
   name=get(w.h.typepop,'String');
   name=name{get(w.h.typepop,'Value')};
else
   type=lower(w.data.newTypeID);
   name=w.data.newTypeName;
end

w.data.FileName=['c',type,'_mycomp'];
w.data.Name=sprintf('My %s Component',upper(type));
w.data.Desc=['A ',name,' component.'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocTypePageExit(w,caller);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These functions deal with the "Name" page            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=LocNamePageInformation(w)

info.Title='Component Name';
info.Pathlist = {1 'AttPage'};
info.Whichpath=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocNamePagePreDraw(w);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocNamePageDraw(w);

textstring={'Name '
   'Function name '
   'Parent directory '
   'Description '};
editParam={'Name'
   'FileName'
   'Path'
   'Desc'};

textwidth=80;
btnwidth=0;
for i=1:length(textstring)
   pos=[w.hg.Xzero w.hg.Ylim-w.hg.barht*i textwidth w.hg.barht];
   w.h.ntext(i)=uicontrol(w.hg.all,...
      'Style','text',...
      'Visible','off',...
      'String',textstring{i},...
      'HorizontalAlignment','right',...
      'Position',pos);  
   newx=pos(1)+pos(3);
   pos=[newx pos(2) w.hg.Xlim-newx-btnwidth pos(4)];
   w.h.nedit(i)=uicontrol(w.hg.all,...
      'Style','edit',...
      'Visible','off',...
      'BackgroundColor',[1 1 1],...
      'String',getfield(w.data,editParam{i}),...
      'Callback',['compwiz(''UpdateName'',[],''' editParam{i},''');'],...
      'HorizontalAlignment','left',...
      'Position',pos);   
end

pos=[w.hg.Xzero pos(2)-2*w.hg.barht w.hg.Xlim-w.hg.Xzero w.hg.barht];
w.h.acheck=uicontrol(w.hg.all,...
   'Style','checkbox',...
   'Visible','off',...
   'String','Component can contain subcomponents',...      
   'Callback',['compwiz(''UpdateName'',[],''IsLoop'');'],...
   'HorizontalAlignment','left',...
   'Max',logical(1),...
   'Min',logical(0),...
   'Value',w.data.IsLoop,...
   'Position',pos);

set([w.h.ntext w.h.nedit w.h.acheck],'Visible','on');

%pos=[w.hg.figdims(3)-w.hg.pad-btnwidth,...
%      w.hg.figdims(4)-50-w.hg.barht*3,...
%      btnwidth,...
%      w.hg.barht];
%w.h.pathbtn=uicontrol(w.hg.all,...
%   'Style','pushbutton',...
%   'String','...',...
%   'Callback','compwiz PathBtn',...
%   'HorizontalAlignment','center',...
%   'Position',pos);

w=LocUpdateName(w,'FileName');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocUpdateName(w,whichParam);


switch whichParam
case 'Name'
   w.data=setfield(w.data,whichParam,get(w.h.nedit(1),'String'));
case 'FileName'
   
   [newName,errMsg]=rptgenutil(...
      'VariableNameCheck',w.h.nedit(2),...
      w.data.FileName,logical(0));
   
   newName=lower(newName);
   set(w.h.nedit(2),'String',newName);
   w.data.FileName=newName;
   
   [allType,allComp]=LocAllComponents;
   
   if any(strcmp(allComp,newName))
      errMsg='Warning: this component already exists';
      w=LocImportComponent(w,newName);
   else
      %w=LocImportComponent(w,'');
   end
   set(w.h.acheck,'Value',w.data.IsLoop);

   
   set(w.h.StatusBar,'String',errMsg);
case 'Path'
   w.data=setfield(w.data,whichParam,get(w.h.nedit(3),'String'));
case 'Desc'
   w.data=setfield(w.data,whichParam,get(w.h.nedit(4),'String'));   
case 'IsLoop'
   w.data.IsLoop=get(w.h.acheck,'Value');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocImportComponent(w,newName);

if isempty(newName)
   
   w.data.IsLoop=logical(0);
   
   w.data.isAttributeFile=logical(1);
   w.data.isOutlinestringFile=logical(1);
   
   w.data.att=LocGetEmptyAttributesStructure;
else
   c=unpoint(feval(newName));
   
   if isstruct(c.att)
      attNames=fieldnames(c.att);
   else
      attNames={};
   end
   
   for i=length(attNames):-1:1
      atx=getattx(c,attNames{i});
      
      w.data.att(i)=struct('String',atx.String,...
         'UIcontrol',atx.UIcontrol,...
         'Default',{atx.Default},...
         'Name',attNames{i},...
         'Type',atx.Type);   
   end
   w.data.IsLoop=isparent(c);
   
   
   %if the methods exist, don't overwrite
   %them with new 
   allMethods=methods(newName);
   
   w.data.isAttributeFile=~any(strcmp(allMethods,'attribute'));
   w.data.isOutlinestringFile=~any(strcmp(allMethods,'outlinestring'));
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   w=LocPathBtn(w)

[filename,pathname]=uiputfile(w.data.Path,'Select File in Parent Directory');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocNamePageExit(w,caller);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These functions deal with the page "att"      %     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=LocAttPageInformation(w)

info.Title='Component Attributes';
info.Pathlist = {1 'MethodsPage'};
info.Whichpath=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocAttPagePreDraw(w);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocAttPageDraw(w);

titleWidth=50;

pos=[w.hg.Xzero+titleWidth-30-w.hg.pad w.hg.Yzero+150 30 30];
w.h.new=uicontrol(w.hg.all,...
   'Style','pushbutton',...
   'String','New',...
   'Callback','compwiz NewAtt;',...
   'Position',pos);
pos(2)=pos(2)-pos(4)-w.hg.pad;

w.h.del=uicontrol(w.hg.all,...
   'Style','pushbutton',...
   'Callback','compwiz DelAtt;',...
   'String','Del',...
   'Position',pos);

pos(1)=w.hg.Xzero+titleWidth;
pos(2)=w.hg.Yzero+5*w.hg.barht;
pos(3)=w.hg.Xlim-pos(1);
pos(4)=w.hg.Ylim-pos(2);
w.h.attlist=uicontrol(w.hg.all,...
   'Style','listbox',...
   'BackgroundColor','white',...
   'Callback','compwiz SelectAttList;',...
   'FontName',get(0,'fixedwidthfontname'),...
   'Position',pos);

whichAtt={'Name' 'Type' 'Default' 'UIcontrol' 'String'};
whichAttTitle={'Field name '
   'Data type '
   'Default value '
   'Control type '
   'Att. name '};

controlWidth=(w.hg.Xlim-w.hg.Xzero)-titleWidth;
yPos=pos(2)-w.hg.barht;

for i=1:length(whichAtt)   
   w.h=setfield(w.h,[whichAtt{i} 'Title'],uicontrol(w.hg.all,...
      'Style','text',...
      'String',whichAttTitle{i},...
      'HorizontalAlignment','right',...
      'Position',[w.hg.Xzero yPos titleWidth w.hg.barht]));
   
   w.h=setfield(w.h,whichAtt{i},uicontrol(w.hg.all,...
      'Style','edit',...
      'HorizontalAlignment','left',...
      'String','yo',...
      'BackgroundColor','white',...
      'Callback',['compwiz(''ChangeAttField'',[],''' whichAtt{i} ''');'],...
      'Position',[w.hg.Xzero+titleWidth yPos controlWidth w.hg.barht]));
   yPos=yPos-w.hg.barht;
end

set(w.h.UIcontrol,'style','popupmenu');
set(w.h.Type,...
   'style','popupmenu',...
   'UserData',{'LOGICAL' 'ENUM' 'NUMBER' 'STRING' 'CELL' 'OTHER'},...
   'String',{'Logical T/F' 'Enumerated List' 'Number' ...
      'Character String' 'Cell Array' 'Other (struct, object)'});
   
w=LocAttRedrawAll(w);
w=LocSelectAttList(w);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocAttRedrawAll(w,selectIndex)

if isempty(w.data.att)
   set(w.h.attlist,...
      'Max',2,...
      'Value',[],...
      'String',{});
   set(w.h.Name,...
      'String','',...
      'UserData','<%NEWATT>');
   set(w.h.Default,...
      'Enable','off',...
      'String','''''');
   set(w.h.Type,'Enable','off');
   set(w.h.UIcontrol,'Enable','off');
   set(w.h.String,'Enable','off');
   set(w.h.del,...
      'Enable','off');
else
   if nargin<2 | isempty(selectIndex)
      selectIndex=get(w.h.attlist,'Value');
   end
   
   [myStruc{1:2:2*length(w.data.att)-1}]=deal(w.data.att.Name);
   [myStruc{2:2:2*length(w.data.att)}]=deal(w.data.att.Default);
   
   set(w.h.attlist,...
      'Max',1,...
      'Value',selectIndex,...
      'String',LocStructString(w.data.att));
   set(w.h.Type,'Enable','on');
   set(w.h.Default,'Enable','on');
   set(w.h.UIcontrol,'Enable','on');
   set(w.h.String,'Enable','on');
   set(w.h.del,...
      'Enable','on');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   w=LocNewAtt(w)

set(w.h.Name,'Enable','on',...
   'UserData','<%NEWATT>',...
   'String','');
set(w.h.Default,...
   'Enable','off',...
   'String','''''');
set(w.h.String,'String','','Enable','off');
set(w.h.UIcontrol,'Enable','off');
set(w.h.Type,'Enable','off');
set(w.h.del,'Enable','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   w=LocDelAtt(w);

currAtt=get(w.h.attlist,'Value');
w.data.att=[w.data.att(1:currAtt-1),...
      w.data.att(currAtt+1:end)];

if isempty(w.data.att)
   currAtt=[];
elseif currAtt>length(w.data.att)
   currAtt=currAtt-1;
end

w=LocAttRedrawAll(w,currAtt);
w=LocSelectAttList(w);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocSelectAttList(w)

index=get(w.h.attlist,'Value');
if ~isempty(index)
   myStruc=w.data.att(index);
   set([w.h.Name w.h.Type w.h.Default w.h.Type ...
         w.h.UIcontrol w.h.String w.h.del],...
      'Enable','on');
   set(w.h.Name,'UserData',myStruc.Name);

else
   myStruc=struct('String','',...
      'UIcontrol','edit',...
      'Default','',...
      'Name','',...
      'Type','STRING');
end

set([w.h.Name w.h.Default w.h.String],{'String'},...
   {myStruc.Name;myStruc.Default;myStruc.String});

allTypes=get(w.h.Type,'UserData');
typeIndex=find(strcmp(allTypes,myStruc.Type));
set(w.h.Type,'Value',typeIndex);
myStruc.UIcontrol=LocValidateControl(w,myStruc.Type,myStruc.UIcontrol);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocChangeAttField(w,whichAtt)

index=get(w.h.attlist,'Value');
if ~isempty(index)
   myStruc=w.data.att(index);
else
    myStruc=struct('String','',...
   'enumValues',{{}},...
   'enumNames',{{}},...
   'UIcontrol','edit',...
   'Default','',...
   'Name','',...
   'Type','STRING',...
   'NumberRange',[]);
%   myStruc=struct('String','',...
%      'UIcontrol','edit',...
%      'Default','',...
%      'Name','',...
%      'Type','STRING');
end

switch whichAtt
case 'Name'
   prevname=get(w.h.Name,'UserData');
   if strcmp(prevname,'<%NEWATT>')
    myStruc=struct('String','',...
   'enumValues',{{}},...
   'enumNames',{{}},...
   'UIcontrol','edit',...
   'Default','',...
   'Name','',...
   'Type','STRING',...
   'NumberRange',[]);
      isNew=logical(1);
      index=length(w.data.att)+1;
   else
      isNew=logical(0);
   end
   
   [newname,errMsg]=rptgenutil(...
      'VariableNameCheck',w.h.Name,...
      prevname,logical(0));
   errMsg = strrep(errMsg,'variable','field');
   errMsg = strrep(errMsg,'Variable','Field');
   set(w.h.StatusBar,'String',errMsg);
   
   newstring=newname;
   
   set(w.h.StatusBar,'String','');
   if isempty(newname)
      newname=prevname;
      newstring=prevname;
   else
      if ~strcmp(newname,prevname)         
         %check for uniqueness in naming
         if length(find(strcmp({w.data.att.Name},newname)))>0
            errMsg='Attribute names must be unique';
            %setting index to empty tells it not to update the structure
            newname=prevname;
            if isNew
               newstring='';
            else
               newstring=prevname;
            end          
            index=[];
         end
         
      end
   end
   set(w.h.StatusBar,'String',errMsg);
   set(w.h.Name,'String',newstring,'UserData',newname);
   
   myStruc.Name=newname;
   
case 'Default'
   myStruc.Default=LocValidateString(w,myStruc.Type,...
      get(w.h.Default,'String'));
case 'Type'   
   allTypes=get(w.h.Type,'UserData');
   typeIndex=get(w.h.Type,'Value');
   myStruc.Type=allTypes{typeIndex};
   myStruc.UIcontrol=LocValidateControl(w,myStruc.Type,myStruc.UIcontrol);
   myStruc.Default=LocValidateString(w,myStruc.Type,myStruc.Default);
      
case 'UIcontrol'
   allControls=get(w.h.UIcontrol,'UserData');
   idxControls=get(w.h.UIcontrol,'Value');
   myStruc.UIcontrol=allControls{idxControls};
case 'String'
   myStruc.String=get(w.h.String,'String');   
end


if ~isempty(index)
   w.data.att(index)=myStruc;
   w=LocAttRedrawAll(w,index);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vString=LocValidateString(w,vType,vString)

q='''';

errorMsg='';
switch vType
case 'LOGICAL'
   switch lower(vString)
   case {'t' 'on' 'true' '1' 'logical(1)'}
      vString='logical(1)';
   case {'f' 'off' 'false' '0' 'logical(0)'}
      vString='logical(0)';
   otherwise
      vString='logical(1)';
      errorMsg='Values should be logical(1) or logical(0)';
   end
case 'ENUM'
   %we are expecting a string or number
   if isempty(vString)
      vString=[q q];
   else
      if vString(1)==q
         %if the first character is a quote
         if ~vString(end)==q | length(vString)==1
            vString=[vString q];
         end
      elseif ~isempty(str2num(vString))
         %if it's a number
         %don't do anything
      elseif any(strcmp({'logical(1)','logical(0)'},vString))
         %if it's a logical value
         %don't do anything
      else
         if ~vString(end)==q
            vString=[vString q];
         else
            vString=[q vString q];
         end
      end      
   end
case 'NUMBER'
   if ~strcmp(vString,'[]')
      if isempty(str2num(vString))
         vString='[]';
         errorMsg='Values should be numeric.';
      end
   end
case 'STRING' 
   if isempty(vString)
      vString=[q q];
   else
      if vString(1)~=q;
         vString=[q vString];
      end
      if vString(end)~=q | length(vString)==1
         vString=[vString q];
      end
   end
case 'CELL'
   if ~any(findstr(vString,'{'))
      vString=['{' vString];
   end   
   if ~any(findstr(vString,'}'))
      vString=[ vString '}'];
   end
otherwise  %case 'OTHER',[3]);
   %do not change the string
end

set(w.h.Default,'String',vString)
set(w.h.StatusBar,'String',errorMsg);   



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocAttPageExit(w,caller);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%not callbacks - used by other parts of AttPage

function controlType=LocValidateControl(w,myType,myControl);

controlNames={'radiobutton' %1
   'checkbox' %2
   'edit' %3
   'slider' %4
   'listbox' %5
   'popupmenu' %6
   'multiedit' %7
   'togglebutton'}; %8

allControls=struct('LOGICAL',[2 1 5 6 8],...
   'ENUM',[6 1 5 8],...
   'NUMBER',[3 4],...
   'STRING',[3 7],... 
   'CELL',[3 7],...
   'OTHER',[3]);

validControls=controlNames(getfield(allControls,myType));
controlIndex=find(strcmp(validControls,myControl));
if isempty(controlIndex)
   controlIndex=1;
else
   controlIndex=controlIndex(1);
end

myStruc.UIcontrol=validControls{controlIndex};

set(w.h.UIcontrol,...
   'UserData',validControls,...
   'String',validControls,...
   'Value',controlIndex);

controlType=validControls{controlIndex};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These functions deal with the page            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=LocMethodsPageInformation(w)

info.Title='Component Methods';
info.Pathlist = {1 'ConfirmPage'};
info.Whichpath=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocMethodsPagePreDraw(w);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocMethodsPageDraw(w);

textstring={'Create custom attributes method'
   'Create custom outlinestring method'};
valfrom={w.data.isAttributeFile
   w.data.isOutlinestringFile};

for i=1:length(textstring)
   pos=[w.hg.Xzero w.hg.Ylim-w.hg.barht*i ...
         w.hg.Xlim-w.hg.Xzero w.hg.barht];
   w.h.mcheck(i)=uicontrol(w.hg.all,...
      'Style','checkbox',...
       'String',textstring{i},...
      'Callback','compwiz MethUpdate;',...
      'HorizontalAlignment','left',...
      'Value',valfrom{i},...
      'Position',pos);   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocMethUpdate(w);

editstring={'Attribute'
   'Outlinestring'};

for i=1:length(editstring)
   w.data=setfield(w.data,['is' editstring{i} 'File'],...
      get(w.h.mcheck(i),'Value'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocMethodsPageExit(w,caller);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These functions deal with the page            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=LocConfirmPageInformation(w)

info.Title='Confirm Selections';
info.Pathlist = {-1 'Page'};
info.Whichpath=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocConfirmPagePreDraw(w);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocConfirmPageDraw(w);

set(w.h.Next,'String','Create')

cstring={sprintf('New Component: %s',w.data.Name)
   w.data.Desc
   [w.data.Path filesep '@' w.data.FileName]};

if w.data.IsLoop
   cstring={cstring{:},'Can contain subcomponents'};
end

cstring={cstring{:},'','Component Attributes - '};
attstring=LocStructString(w.data.att);
cstring={cstring{:},attstring{:}};

methNames={xlate('Attribute')
   xlate('Outlinestring')};
for i=1:length(methNames)
   if getfield(w.data,['is' methNames{i} 'File'])
      methNames{i}=sprintf('  Create blank %s file.',  methNames{i});
   else
      methNames{i}=sprintf('  Inherit existing %s file.',  methNames{i});
   end
end

cstring={cstring{:},'', sprintf('Standard Methods - %s', methNames{:})};

w.h.confirmbox=uicontrol(w.hg.all,...
   'style','listbox',...
   'Min',0,'Max',2,'Enable','inactive',...
   'Position',[w.hg.Xzero w.hg.Yzero w.hg.Xlim-w.hg.Xzero w.hg.Ylim-w.hg.Yzero],...
   'String',cstring);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=LocConfirmPageExit(w,caller);

if strcmp(caller,'Next')
   set(w.h.figure,'Pointer','watch');
   set(w.h.StatusBar,'String','Creating component....');
   createcomp(w.data);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compname=createcomp(data)

data.CR=char([13 10]);

data.newpath=LocCreateDirectory(data);
LocWriteRptcompsFile(data);
LocWriteCreationMethod(data);
LocWriteGetinfo(data);
LocWriteExecuteMethod(data)

methods={'Attribute'
   'Outlinestring'};

for i=1:length(methods)
   if getfield(data,['is' methods{i} 'File'])
      feval(['LocBlank' methods{i} 'File'],data);
   end
end
LocMiscFiles(data);

try
   %rehash the search table so it can find objects
   rehash('toolboxreset');
end


LocRedrawComponentsList;

compname=data.FileName;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compDir=LocCreateDirectory(data)

[status,errormsg]=mkdir(data.Path,['@' data.FileName]);
if status==0
   compDir=data.Path;
elseif status==2
   %directory already exists!
   compDir=[data.Path filesep '@' data.FileName];
else
   %directory created successfully.
   compDir=[data.Path filesep '@' data.FileName];
end

path(path,data.Path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocWriteRptcompsFile(data);

r=rptparent;

rptcompsFile=[data.Path filesep 'rptcomps.xml'];

allTypes=allcomptypes(r,rptcompsFile);
allComps=allcomps(r,rptcompsFile);

if strcmp(data.Type,'NEWTYPE')
   index=length(allTypes)+1;
   allTypes(index).Type=data.newTypeID;
   allTypes(index).Fullname=data.newTypeName;
end

if ~any(strcmp({allComps.Class},data.FileName))
   allComps(end+1).Class=data.FileName;
end

existingComments='';
commentTag=set(sgmltag,'data',existingComments,...
   'tag','comment',...
   'expanded',logical(0));

idTag=set(sgmltag,'tag','id','expanded',logical(0));
nameTag=set(sgmltag,'tag','name','expanded',logical(0));
typeTag=set(sgmltag,'tag','type','data',{idTag nameTag});

typeData={};
for i=length(allTypes):-1:1
   typeTag.data{1}.data=allTypes(i).Type;
   typeTag.data{2}.data=allTypes(i).Fullname;
   typeData{i}=typeTag;   
end

typelistTag=set(sgmltag,'tag','typelist',...
   'data',typeData);

compData={};
for i=length(allComps):-1:1
   compData{i}=set(sgmltag,'tag','c',...
      'data',allComps(i).Class,...
      'expanded',logical(0));
end

complistTag=set(sgmltag,'tag','complist',...
   'data',compData);

regTag=set(sgmltag,'tag','registry',...
   'data',{commentTag typelistTag complistTag});

fid=fopen(rptcompsFile,'w');
if fid>0
   fprintf(fid,char(regTag));
   fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocWriteCreationMethod(data)

fName=lower(data.FileName);

constructorString=[...
      'function c=' fName '(varargin)' data.CR ...
      '%' data.Name data.CR ...
      '%  ' data.Desc data.CR ...
      data.CR ...
      LocFileHeader, ...
      data.CR ...
      'c=rptgenutil(''EmptyComponentStructure'',''' fName ''');' data.CR ...
      'c=class(c,c.comp.Class,rptcomponent);' data.CR ...
      'c=buildcomponent(c,varargin{:});' data.CR];
   

LocWriteFile([data.newpath filesep data.FileName '.m'],...
   [constructorString]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocWriteGetinfo(data)

if strcmp(data.Type,'NEWTYPE')
   cType=data.newTypeID;
else
   cType=data.Type;
end

giString=['function out=getinfo(c)' data.CR...
      '%GETINFO returns basic component information' data.CR...
      data.CR ...
      LocFileHeader, ...
      data.CR ...
      '%---------------- DO NOT EDIT THIS LINE ---------------' data.CR ...
      'out=getprotocomp(c);' data.CR...
      data.CR...
      '%--------------- COMPONENT NAME AND TYPE --------------' data.CR ...
      'out.Name = ''' data.Name ''';' data.CR...
      'out.Type = ''' cType ''';' data.CR...
      'out.Desc = ''' data.Desc ''';' data.CR];

if data.IsLoop
   giString=[giString,'out.ValidChildren={logical(1)};', data.CR, data.CR];
else
   giString=[giString, data.CR];
end

aString=''; %contains the main c.att information
xString=''; %contains the graphical c.attx information

for i=1:length(data.att)         
   aString=[aString,'out.att.' data.att(i).Name ' = ' ...
         data.att(i).Default ';' data.CR];
   
   xBegin=['out.attx.' data.att(i).Name '.'];
   
   dString=data.att(i).String;
   if isempty(dString)
      dString=data.att(i).Name;
   end
  
   xString=[xString,...
         xBegin,'String=','''' dString ''';' data.CR ...
         xBegin,'Type=','''' data.att(i).Type ''';' data.CR ...
         xBegin,'UIcontrol=','''' data.att(i).UIcontrol ''';' data.CR];
   
   switch data.att(i).Type
   case 'ENUM'
      xString=[xString,...
            xBegin,'enumValues=','{' data.att(i).Default '};' data.CR ...
            xBegin,'enumNames=','{' data.att(i).Default '};' data.CR];
   case 'NUMBER'
      loRange=-inf;
      hiRange=inf;
      xString=[xString,...
            xBegin,'numberRange=[' num2str(loRange) ...
            ' ' num2str(hiRange) '];' data.CR];
   end   
   xString=[xString data.CR];
end

aHelp=[data.CR ...
      '%---------------------- ATTRIBUTES --------------------' data.CR ...
      '%The out.att.XXX section sets attribute defaults.' data.CR ...
      data.CR];

xHelp=[data.CR ...
      '%------------------ ATTRIBUTE DISPLAY -----------------' data.CR ...
      '%The out.attx.XXX section sets attribute GUI information.' data.CR ...
      '%Each .attx structure has the following fields:' data.CR ...
      '% .String - Appears as a text field next to the UIcontrol' data.CR ...
      '% .Type - data type of the corresponding attribute.' data.CR ...
      '%      STRING - character string' data.CR ...
      '%      NUMBER - scalar or vector number ' data.CR ...
      '%      LOGICAL - boolean logical(1)/logical(0) ' data.CR ...
      '%      ENUM - enumerated list of STRING, NUMBER, or LOGICAL' data.CR ...
      '%      CELL - cell array ' data.CR ...
      '%      OTHER - structure or object' data.CR ...
      '%         note: "OTHER" has no automated uicontrol updating' data.CR ...
      '% .enumValues - options for an enumerated list (.Type=''ENUM'')' data.CR ...
      '% .enumNames - display representation of .enumValues' data.CR ...
      '%         note: must be same length as .enumValues' data.CR ...
      '%         note: empty enumNames implies display from enumValues' data.CR ...
      '% .UIcontrol - type of control to use in GUI' data.CR ...
      '% .numberRange - min and max values (.Type-''NUMBER'')' data.CR ...
      data.CR];

LocWriteFile([data.newpath filesep 'getinfo.m'],...
   [giString aHelp aString xHelp xString]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocWriteExecuteMethod(data)

exString=['function out=execute(c)' data.CR ...
      '%EXECUTE returns a report element during generation' data.CR ...
      data.CR ...
      LocFileHeader, ...
      data.CR ...
      'out=sgmltag;' data.CR];

if data.IsLoop
   exString=[exString data.CR...
         'ChildComponentPointers=children(c);' data.CR ...
         'out=[out;runcomponent(ChildComponentPointers)];' data.CR];
end

LocWriteFile([data.newpath filesep 'execute.m'],exString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocBlankOutlinestringFile(data)

olString=['function strout=outlinestring(c)' data.CR ...
      '%OUTLINESTRING display short component description' data.CR ...
      '%   STR=OUTLINESTRING(C) Returns a terse description of the' data.CR ...
      '%   component in the setup file editor report outline.  The' data.CR ...
      '%   default outlinestring method returns the component''s name.' data.CR ...
      data.CR ...
      LocFileHeader, ...
      data.CR ...
      'info=getinfo(c);' data.CR ...
      'strout=info.Name;'];

LocWriteFile([data.newpath filesep 'outlinestring.m'],olString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocBlankAttributeFile(data)

fileString=['function c=attribute(c,action,varargin)' data.CR ...
      '%ATTRIBUTE launches the setup file editor options page' data.CR ...
      '   %C=ATTRIBUTE(C,''start'') is called when the page is drawn' ...
      data.CR ...
      '   %C=ATTRIBUTE(C,''resize'') is called when the page is resized' ...
      data.CR ...
      '' data.CR ...
      LocFileHeader, ...   
      '' data.CR ...
      'c=feval(action,c,varargin{:});' data.CR ...
      data.CR ...
      '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' data.CR ...
      'function c=start(c)' data.CR ...
      '' data.CR ...
      '%controlsframe creates a nice-looking border' data.CR ...
      '%which can surround UICONTROLS.  Controlsframe' data.CR ...
      '%must be run before controlsmake in order to get' data.CR ...
      '%the stacking order right.  A frame requires the' data.CR ...
      '%use of a custom c.x.LayoutManager.' data.CR ...
      '' data.CR ...
      '%frameHandle=controlsframe(c,''Frame Title'');' data.CR ...
      '' data.CR ...
      '%controlsmake creates the UICONTROLS.' data.CR ...
      '%they are passed back in c.x with fieldnames' data.CR ...
      '%mirroring the attribute name.  For example,' data.CR ...
      '%c.att.Foo creates a uicontrol with handle' data.CR ...
      '%c.x.Foo.  If the control creates a text field' data.CR ...
      '%(for example a compound text/edit) the text' data.CR ...
      '%field''s handle is c.x.FooTitle' data.CR ...
      '' data.CR ...
      '%controlsmake uses getinfo(c) to obtain the information' data.CR ...
      '%it needs to automatically create uicontrols.  ' data.CR ...
      '%Information is stored in c.attx.Foo' data.CR ...
      '' data.CR ...
      'c=controlsmake(c);' data.CR ...
      '' data.CR ...
      '%the attribute page is by default rendered in a' data.CR ...
      '%two-column layout.  To change the layout of the' data.CR ...
      '%uicontrols, change c.x.LayoutManager.' data.CR ...
      '' data.CR ...
      'c=resize(c);' data.CR ...
      '' data.CR ...
      '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' data.CR ...
      'function c=refresh(c)' data.CR ...
      '' data.CR ...
      '%refresh is called anytime a "start" would' data.CR ...
      '%be called but the page is already active' data.CR ...
      '%Example: moving, deactivating, select outline' data.CR ...
      '' data.CR ...
      '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' data.CR ...
      'function c=resize(c)' data.CR ...
      '' data.CR ...
      '%controlsresize returns the lowest Y position' data.CR ...
      '%reached by any uicontrols in c.x.lowLimit' data.CR ...
      '' data.CR ...
      'c=controlsresize(c);' data.CR ...
      '' data.CR ...
      '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' data.CR ...
      'function c=Update(c,whichControl,varargin);' data.CR ...
      '' data.CR ...
      '%Update callbacks are called individually from' data.CR ...
      '%each uicontrol with a whichControl value of' data.CR ...
      '%the attribute name.  c.att.Foo calls from ' data.CR ...
      '%c.x.Foo with whichControl==''Foo''' data.CR ...
      '' data.CR ...
      'c=controlsupdate(c,whichControl,varargin{:});' data.CR];

LocWriteFile([data.newpath filesep 'attribute.m'],...
   fileString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocMiscFiles(data)

subsrefStr=['function out=subref(A,S)' data.CR ...
      '%SUBSREF Subscripted reference' data.CR ...
      LocFileHeader, ...
      data.CR ...
      '% this function causes all of the object''s fields to be public' data.CR ...
      data.CR ...
      'out=builtin(''subsref'',A,S);'];
LocWriteFile([data.newpath filesep 'subsref.m'],...
   subsrefStr);

subsasgnStr=['function out=subsasgn(varargin)' data.CR ...
      '%SUBSASGN Subscripted assignment' data.CR ...
      LocFileHeader, ...
      data.CR ...
      '% this function causes all of the objesct''.s fields to be public' data.CR ...
      data.CR ...
      'out=builtin(''subsasgn'',varargin{:});'];
LocWriteFile([data.newpath filesep 'subsasgn.m'],...
   subsasgnStr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocWriteFile(fileName,writeString)
fid=fopen(fileName,'w');
if fid>0
   fprintf(fid,'%c',writeString);
   ok=fclose(fid);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function message=LocFileHeader

%CR=sprintf('\n');

%currDate=clock;
%DateString=['1997-' num2str(currDate(1))];

%The word copy-right has been split in order to avoid
%running afoul with the copy-right checker, which cues off
%of the unsplit word.

%message=['%   Copy' 'right (c) ' DateString ' by The MathWorks, Inc.' CR ...
%      '%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:47 $' CR ];

message='';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ss=LocStructString(att)

if isempty(att)
   ss={};
else
   [myStruc{1:2:2*length(att)-1}]=deal(att.Name);
   [myStruc{2:2:2*length(att)}]=deal(att.Default);
   
   ss=makepvstring(rptparent,struct(myStruc{:}));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allType,allComp]=LocAllComponents

persistent RPTGEN_COMPWIZ_ALLTYPES

if isempty(RPTGEN_COMPWIZ_ALLTYPES)
   RPTGEN_COMPWIZ_ALLTYPES=allcomptypes(rptparent);
   RPTGEN_COMPWIZ_ALLTYPES={RPTGEN_COMPWIZ_ALLTYPES.Type};
end

persistent RPTGEN_COMPWIZ_ALLCOMPS

if isempty(RPTGEN_COMPWIZ_ALLCOMPS)
   RPTGEN_COMPWIZ_ALLCOMPS=allcomps(rptparent);
   RPTGEN_COMPWIZ_ALLCOMPS={RPTGEN_COMPWIZ_ALLCOMPS.Class};
end

allType=RPTGEN_COMPWIZ_ALLTYPES;
allComp=RPTGEN_COMPWIZ_ALLCOMPS;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocRedrawComponentsList;
%If the setup file editor is up, have it update its
%list of components.

sfeFig=findall(allchild(0),'flat',...
   'type','figure',...
   'tag','Setup File Editor');

if ~isempty(sfeFig)
   g=rgstoregui;
   if isa(g,'rptgui')
      try
         oldVal=get(g.h.AddTab.complist,'Value');
         oldTop=get(g.h.AddTab.complist,'listboxtop');
         set(g.h.AddTab.complist,...
            'UserData',logical(1),...
            'Value',1,...
            'String','Adding newly created component to list...',...
            'FontAngle','italic',...
            'Enable','off');
      catch
         oldVal=1;
         oldTop=1;
      end
      
      try
         currTab=getcurrtab(g);
      catch
         currTab=1;
      end
      if currTab==2
         %tab 2 is up, so we must redraw the complist
         try
            rgstoregui(updateui(g,'NewTab'));
         end
         try
            set(g.h.AddTab.complist,...
               'Value',oldVal,...
               'ListboxTop',oldTop);
         end
      end
      
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function att = LocGetEmptyAttributesStructure

att=struct('String',{},...
   'enumValues',{},...
   'enumNames',{},...
   'UIcontrol',{},...
   'Default',{},...
   'Name',{},...
   'Type',{},...
   'NumberRange',{});
