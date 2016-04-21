function c=controlsmake(c,whichControls)
%CONTROLSMAKE creates uicontrols for a component
%   C=CONTROLSMAKE(C,ALIST)
%   Where ALIST is a 1xN cell array containing a list of
%   attributes.  UIcontrols will be created and initialized
%   for these attributes according to their .attx settings.
%
%   If ALIST is not specified, all attributes are created.
%
%   Attribute controls are created with handle names 
%   c.x.AttributeName
%   If the attx.String property is not empty, a title
%   string will be created in c.x.AttributeNameTitle
%
%   A two-column layout is created by default in c.x.LayoutManager
% 
%   See also CONTROLSUPDATE, CONTROLSFRAME, CONTROLSRESIZE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:54 $

att=subsref(c,substruct('.','att'));
if nargin<2
   compInfo=getinfo(c);
   if isstruct(compInfo.att)
      whichControls=fieldnames(compInfo.att);
   else
      whichControls={};
   end
end

x=subsref(c,substruct('.','x'));

x.LayoutManager={};
x.TitleList=[];
x.UIcontrolList=[];
for i=1:length(whichControls)
   atx=getattx(c,whichControls{i});
   functionArguments={x.all,...
         [x.getobj ...
            '''Update'',''' whichControls{i} ''''],...
         atx,...
         getfield(att,whichControls{i})};
   
   controlTypes={
      'popupmenu'
      'listbox'
      'radiobutton'
      'edit'
      'slider'
      'togglebutton'
      'checkbox'
      'multiedit'
      'filebrowse'
   };
   if ~isempty(find(strcmpi(controlTypes,atx.UIcontrol)))
      [titleH,controlH]=feval(['LocMake' lower(atx.UIcontrol)],...
         functionArguments{:});
   else   
      titleH=[];
      controlH=[];
   end
   
   x=setfield(x,whichControls{i},controlH);
   %Set a the title, even if it is empty.
   x=setfield(x,[whichControls{i} 'Title'],titleH);
   
   clear newCH
   
   if length(controlH)>1
      switch atx.UIcontrol
      case 'radiobutton'
         newCH=num2cell(controlH');
      otherwise
         newCH=num2cell(controlH);
      end         
   else
      newCH=controlH;
   end
   x.LayoutManager(i,1:2)={titleH newCH};   
   x.TitleList=[x.TitleList titleH];
      
   x.UIcontrolList=[x.UIcontrolList controlH];
end

c=subsasgn(c,substruct('.','x'),x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tH,cH]=LocMakepopupmenu(allProp,...
   cbString,atx,currVal);

cUserData=atx.enumValues;
cString=atx.enumNames;
cValue=LocEnumIndex(atx.enumValues,currVal);

tH=LocMakeTitle(allProp,atx);
cH=uicontrol(allProp,...
   'style','popupmenu',...
   'UserData',cUserData,...
   'HorizontalAlignment','left',...
   'String',cString,...
   'BackgroundColor',[1 1 1],...
   'value',cValue,...
   'Callback',[cbString ');']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tH,cH]=LocMakefilebrowse(allProp,...
   cbString,atx,currVal);


if atx.isParsedText
   fgc=[0 0 1];
else
   fgc=[0 0 0];
end

tH=LocMakeTitle(allProp,atx);
editHandle=uicontrol(allProp,...
   'style','edit',...
   'HorizontalAlignment','left',...
   'String',currVal,...
   'BackgroundColor',[1 1 1],...
   'ForegroundColor',fgc,...
   'Callback',[cbString,',''edit'');']);
browseHandle=uicontrol(allProp,...
   'BackgroundColor',get(0,'DefaultUIcontrolBackgroundColor'),...
   'style','pushbutton',...
   'String','...',...
   'FontWeight','bold',...
   'Callback',[cbString,',''browse'');']);

cH=[editHandle browseHandle];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tH,cH]=LocMakelistbox(allProp,...
   cbString,atx,currVal);

cMin=0;
cMax=1;
switch atx.Type
case 'ENUM'
   cUserData=atx.enumValues;
   cString=atx.enumNames;
   cValue=LocEnumIndex(atx.enumValues,currVal);
case 'CELL'
   cUserData=currVal;
   cString=currVal;
   if isempty(currVal)
      cValue=[];
      cMin=0;
      cMax=2;
   else
      cValue=1;
   end
end

tH=LocMakeTitle(allProp,atx);
cH=uicontrol(allProp,...
   'style','listbox',...
   'UserData',cUserData,...
   'Min',cMin,'Max',cMax,...
   'HorizontalAlignment','left',...
   'String',cString,...
   'ForegroundColor',[0 0 0],...
   'BackgroundColor',[1 1 1],...
   'value',cValue,...
   'Callback',[cbString ');']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tH,cH]=LocMakeradiobutton(allProp,...
   cbString,atx,currVal);

tH=LocMakeTitle(allProp,atx);

for i=1:length(atx.enumValues)
   cH(i)=uicontrol(allProp,...
      'style','radiobutton',...
      'HorizontalAlignment','left',...
      'UserData',atx.enumValues{i},...
      'String',atx.enumNames{i},...
      'value',0,...
      'Callback',[cbString ',' num2str(i) ');']);
end

enumIndex=LocEnumIndex(atx.enumValues,currVal);
set(cH(enumIndex),'Value',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tH,cH]=LocMakeedit(allProp,...
   cbString,atx,currVal);

tH=LocMakeTitle(allProp,atx);

[editStr,editType]=LocVal2Str(currVal,atx.Type);

if atx.isParsedText
   fgc=[0 0 1];
else
   fgc=[0 0 0];
end



cH=uicontrol(allProp,...
   'style','edit',...
   'String',editStr,...
   'UserData',editType,...
   'HorizontalAlignment','left',...
   'ForegroundColor',fgc,...
   'BackgroundColor',[1 1 1],...
   'Callback',[cbString ');']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tH,cH]=LocMakemultiedit(allProp,...
   cbString,atx,currVal);

tH=LocMakeTitle(allProp,atx);

if atx.isParsedText
   fgc=[0 0 1];
else
   fgc=[0 0 0];
end

%switch class(currVal)
%case 'char'
%   currVal=cellstr(currVal);
%end

cH=uicontrol(allProp,...
   'style','edit',...
   'String',currVal,...
   'UserData',atx.Type,...
   'Max',2,'Min',0,...
   'ForegroundColor',fgc,...
   'HorizontalAlignment','left',...
   'BackgroundColor',[1 1 1],...
   'Callback',[cbString ');']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tH,cH]=LocMakeslider(allProp,...
   cbString,atx,currVal);

tH=LocMakeTitle(allProp,atx);

if atx.numberRange(1)>currVal | ...
      atx.numberRange(1)==-inf
   minValue=min(0,2*currVal);
else
   minValue=atx.numberRange(1);
end

if atx.numberRange(2)<currVal | ...
      atx.numberRange(2)==inf
   maxValue=max(1,2*currVal);
else
   maxValue=atx.numberRange(2);
end

cH=uicontrol(allProp,...
   'style','slider',...
   'Value',currVal,...
   'Min',minValue,... 
   'Max',maxValue,...
   'BackgroundColor',get(0,'DefaultUIcontrolBackgroundColor'),...
   'Callback',[cbString ');']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tH,cH]=LocMaketogglebutton(allProp,...
   cbString,atx,currVal);

%togglebuttons can be used by LOGICAL
%types (single control) or ENUM types
%(multiple controls)

switch atx.Type
case 'LOGICAL'
   tH=[];
   cH=uicontrol(allProp,...
      'style','togglebutton',...
      'BackgroundColor',get(0,'DefaultUIcontrolBackgroundColor'),...
      'String',atx.String,...
      'Value',currVal,...
      'Max',logical(1),'Min',logical(0),...
      'Callback',[cbString ');']);
case 'ENUM'   
   tH=LocMakeTitle(allProp,atx);
      
   for i=length(atx.enumValues):-1:1
      cH(i)=uicontrol(allProp,...
         'style','togglebutton',...
         'BackgroundColor',get(0,'DefaultUIcontrolBackgroundColor'),...
         'UserData',atx.enumValues{i},...
         'String',atx.enumNames{i},...
         'value',0,...
         'Callback',[cbString ',' num2str(i) ');']);
   end
   
   enumIndex=LocEnumIndex(atx.enumValues,currVal);
   set(cH(enumIndex),'Value',1);
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tH,cH]=LocMakecheckbox(allProp,...
   cbString,atx,currVal);

if length(atx.enumValues)==2
   maxVal=atx.enumValues{1};
   minVal=atx.enumValues{2};
else
   maxVal=logical(1);
   minVal=logical(0);
end

if ~isequal(currVal,maxVal) & ~isequal(currVal,minVal)
   currVal=maxVal;
end

tH=[];
cH=uicontrol(allProp,...
   'style','checkbox',...
   'String',atx.String,...
   'HorizontalAlignment','left',...
   'Value',currVal,...
   'Max',maxVal,'Min',minVal,...
   'Callback',[cbString ');']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tH=LocMakeTitle(allProp,atx)

if ~isempty(atx.String)
   tH=uicontrol(allProp,...
      'HorizontalAlignment','right',...
      'style','text',...
      'string',[xlate(atx.String) ' ']);   
else
   tH=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enumIndex=LocEnumIndex(enumValues,currVal)

if ischar(currVal) %looking for a string
   enumIndex=find(strcmp(enumValues,currVal));
else %looking for numbers
   enumIndex=[];
   i=1;
   numEnum=length(enumValues);
   currValSize=size(currVal);
   while i<=numEnum & isempty(enumIndex)
      if all(size(enumValues{i})==currValSize) & ...
            all(enumValues{i}==currVal)
         enumIndex=i;
      else
         i=i+1;
      end
   end
end

if isempty(enumIndex)
   enumIndex=1;
else
   enumIndex=enumIndex(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [string,type]=LocVal2Str(val,type)

if nargin<2 %best guess at type
   if islogical(val)
      type='LOGICAL';
   elseif isnumeric(val)
      type='NUMBER';
   elseif ischar(val)
      type='STRING';
   elseif iscell(val)
      type='CELL';
   else
      type='OTHER';
   end
end

switch upper(type)
case 'STRING'
   try
      string=strrep(val,sprintf('\n'),' ');
   catch
      string=val;
   end
case {'NUMBER' 'LOGICAL'}
   if size(val,1)>1
      [string,type]=LocVal2Str(val,'OTHER');
   else
      string=num2str(val);
   end
case 'ENUM'
   [string,type]=LocVal2Str(val);
case 'CELL'
   string='{';
   for i=1:size(val,1)
      for j=1:size(val,2)
         [tempstr,temptype]=LocVal2Str(val{i,j});
         switch upper(temptype)
         case 'STRING'
            string=[string,' ''',tempstr,''' '];
         case 'NUMBER'
            string=[string,' [',tempstr,'] '];
         case 'LOGICAL'
            string=[string,' logical([',tempstr,']) '];
         case 'CELL'
            string=[string,' ',tempstr,' '];
         case 'OTHER'
            string=[string,' ',tempstr,' '];
            type='OTHER';            
         end
      end
      string=[string,' ; '];
   end
   string=[string,'}'];
case 'OTHER'
   eval(['w=whos(''val'');'])
   string=['[' num2str(w.size(1)) 'x' num2str(w.size(2)) ...
         ' ' w.class ']' ];
end