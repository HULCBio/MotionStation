function c=attribute(c,action,varargin)
%ATTRIBUTE defines the component's setup file editor GUI.
%   C=ATTRIBUTE(C,'Action',argin1,argin2,argin3,....)


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:49 $

switch lower(action)
case 'start'
   c=LocStartGUI(c);
case 'editenter'
   c=LocEditEnter(c);
case 'popselect'
   c=LocPopSelect(c);
case 'mindisplaysize'
   c=MinDisplaySize(c);
case 'lbselect'
   c=LocLBSelect(c);
case 'refresh'
   c=LocRefresh(c);
case 'resize'
   c=LocResize(c);
otherwise
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocStartGUI(c)

info=getinfo(c);
x=subsref(c,substruct('.','x'));

info=getinfo(c);
if isstruct(info.att)
   x.attstr=fieldnames(info.att);
else
   x.attstr={};
end

c=subsasgn(c,substruct('.','x'),x);
x.lbstruct=LocMakeLBStruct(c);
c=subsasgn(c,substruct('.','x'),x);

lbstring=locgetlbstring(c);

x.desctext=uicontrol(x.all,...
   'style','text',...
   'string',[info.Name,': ',info.Desc],...
   'HorizontalAlignment','left');

x.listbox=uicontrol(x.all,...
   'style','listbox',...
   'string',lbstring',...
   'FontName',fixedwidthfont(c),...
   'Callback',[x.getobj,'''lbselect'');'],...
   'BackgroundColor',[1 1 1],...   
   'Value',1);

x.editbox=uicontrol(x.all,...
   'HorizontalAlignment','left',...
   'TooltipString','Edit attribute values here',...
   'BackgroundColor',[1 1 1]);

c=subsasgn(c,substruct('.','x'),x);

c=LocLBSelect(c);
c=LocResize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocRefresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocResize(c);

pad=10;
x=subsref(c,substruct('.','x'));


tabwidth=x.xext-x.xzero;
tabht=x.ylim-x.yorig;

barht=15;
descHt=min(2*barht,tabht*.1);

listHt=min(tabht-2*pad-descHt-barht,barht*(length(x.attstr)+2));

pos=[x.xzero+pad x.ylim-descHt tabwidth-2*pad descHt];
set(x.desctext,'Position',pos);

pos(4)=listHt;
pos(2)=pos(2)-pos(4);
set(x.listbox,'Position',pos);

pos(4)=barht;
pos(2)=pos(2)-barht;
set(x.editbox,'Position',pos);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ms=MinDisplaySize(c);

ms=[40 60];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocPopSelect(c);

x=subsref(c,substruct('.','x'));


menustring=get(x.editbox,'String');
menuvals=get(x.editbox,'UserData');
index=get(x.editbox,'Value');

currattindex=get(x.listbox,'Value');

c=subsasgn(c,...
   substruct('.','att','.',x.attstr{currattindex}),...
   menuvals{index});

x.lbstruct=setfield(x.lbstruct,...
   x.attstr{currattindex},...
   menustring{index});

c=subsasgn(c,substruct('.','x'),x);

set(x.listbox,'string',locgetlbstring(c))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocEditEnter(c)

x=subsref(c,substruct('.','x'));

currattindex=get(x.listbox,'Value');


stringval=get(x.editbox,'String');   
type=get(x.editbox,'UserData');


[washval,ok]=locstr2val(stringval,type);

if ok
   c=subsasgn(c,...
      substruct('.','att','.',x.attstr{currattindex}),...
      washval);
   
   x.lbstruct=setfield(x.lbstruct,x.attstr{currattindex},stringval);
else
   oldval=subsref(c,substruct('.','att','.',x.attstr{currattindex}));
   set(x.editbox,'String',oldval);
end

c=subsasgn(c,substruct('.','x'),x);

set(x.listbox,'string',locgetlbstring(c))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocLBSelect(c)

x=subsref(c,substruct('.','x'));

info=getinfo(c);

currattindex=get(x.listbox,'Value');

if ~isempty(x.attstr)
   val=subsref(c,substruct('.','att','.',x.attstr{currattindex}));
   attx=getattx(c,x.attstr{currattindex});
   switch lower(attx.UIcontrol)
   case {'popupmenu' 'listbox' 'radiobutton' 'checkbox'}
      c=LocPopup(c,attx.enumNames,attx.enumValues,val);
   case {'edit' 'slider'}
      c=LocEdit(c,attx,val);
   end
else
   set(x.listbox,'Enable','off')
   set(x.editbox,'Style','edit','Enable','off')
end

c=subsasgn(c,substruct('.','x'),x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function c=LocPopup(c,menutext,menuvals,val)

x=subsref(c,substruct('.','x'));

index=findinlist(c,menuvals,val);
if index<1
   index=1;
end

set(x.editbox,...
   'Style','popupmenu',...
   'Enable','on',...
   'String',menutext,...
   'Callback',[x.getobj,'''popselect'');'],...
   'Value',index,...
   'UserData',menuvals);

c=subsasgn(c,substruct('.','x'),x);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocEdit(c,attx,val)

x=subsref(c,substruct('.','x'));


[str,type]=locVal2Str(val,attx.Type);

if strcmpi(type,'OTHER')
   edenable='off';
else
   edenable='on';
end

set(x.editbox,...
   'Style','edit',...
   'String',str,...
   'Callback',[x.getobj,'''editenter'');'],...
   'Enable',edenable,...
   'UserData',type);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lbStruct=LocMakeLBStruct(c);

x=subsref(c,substruct('.','x'));

info=getinfo(c);

lbStruct={};

for i=1:length(x.attstr)
   att=x.attstr{i};
   val=subsref(c,substruct('.','att','.',x.attstr{i}));
   attx=getattx(c,x.attstr{i});
   
   switch upper(attx.Type)
   case 'LOGICAL'
      if val
         stringval='True';
      else
         stringval='False';
      end
   case 'ENUM'
      index=findinlist(c,attx.enumValues,val);
      if index<1
         [stringval,type]=locVal2Str(val);
      else
         stringval=attx.enumNames{index};
      end
   otherwise
      [stringval,type]=locVal2Str(val,attx.Type);
   end  
   %want to eventually use attx.Name here
   lbStruct=setfield(lbStruct,att,stringval);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ListString=locgetlbstring(c);

x=subsref(c,substruct('.','x'));


ListString=makepvstring(c,x.lbstruct);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [string,type]=locVal2Str(val,type)

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
   string=strrep(val,sprintf('\n'),' ');
case {'NUMBER' 'LOGICAL'}
   if size(val,1)>1
      [string,type]=locVal2Str(val,'OTHER');
   else
      string=num2str(val);
   end
case 'ENUM'
   [string,type]=locVal2Str(val);
case 'CELL'
   string='{';
   for i=1:size(val,1)
      for j=1:size(val,2)
         [tempstr,temptype]=locVal2Str(val{i,j});
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [val,ok]=locstr2val(str,type)

val='';
ok=logical(1);
switch type
case 'STRING'
   val=str;
case 'NUMBER'
   val=str2double(str);
case 'CELL'
   try
      val=eval(str);
   catch
      ok=logical(0);
   end
end

