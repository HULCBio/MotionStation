function c=controlsupdate(c,whichControl,varargin)
%CONTROLSUPDATE handles the callbacks of components
%   C=CONTROLSUPDATE(C,'ControlName',options...)
%
%   See also CONTROLSMAKE, CONTROLSRESIZE, CONTROLSFRAME

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:56 $

x=subsref(c,substruct('.','x'));

atx=getattx(c,whichControl);

%controlTypes={'popupmenu' 'listbox' 'radiobutton' 'edit' ...
%      'slider' 'togglebutton' 'checkbox' 'filebrowse'};

newVal=feval(['LocValue' atx.UIcontrol],x,atx,varargin{:});

c=subsasgn(c,substruct('.','att','.',whichControl),newVal);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attValue=LocValuepopupmenu(x,atx)

objHandle=getfield(x,atx.Name);
enumIndex=get(objHandle,'Value');
allValues=get(objHandle,'UserData');
if iscell(allValues)
   attValue=allValues{enumIndex};
else
   attValue=allValues(enumIndex);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attValue=LocValuefilebrowse(x,atx,action)

objHandle=getfield(x,atx.Name);
editHandle=objHandle(1);

isUpdate=logical(1);
if strcmp(action,'browse')
   [startDir startFile startExt startVer]=fileparts(which(atx.Current));
   if isempty(startDir)
       startDir=pwd;
   end
     
   if isempty(startExt)
       startExt=['*.' atx.Ext];
   else
       startExt=['*' startExt];
   end
   
   [fileName,pathName] = uigetfile(...
       fullfile(startDir,startExt),...
      'Select a File');
   
   if ~isnumeric(fileName)
      attValue=fullfile(pathName,fileName);
      set(editHandle,'String',attValue);
   else
      attValue=atx.Current;   
   end
else
   attValue=get(editHandle,'String');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attValue=LocValuelistbox(x,atx)

switch atx.Type
case 'ENUM'
   objHandle=getfield(x,atx.Name);
   enumIndex=get(objHandle,'Value');
   allValues=get(objHandle,'UserData');
   if iscell(allValues)
      attValue=allValues{enumIndex};
   else
      attValue=allValues(enumIndex);
   end
otherwise
   %don't change anything
   attValue=atx.Current;
end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attValue=LocValueradiobutton(x,atx,enumIndex)

objHandle=getfield(x,atx.Name);
set(objHandle,'value',0);
set(objHandle(enumIndex),'value',1);

attValue=get(objHandle(enumIndex),'UserData');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attValue=LocValueslider(x,atx)

objHandle=getfield(x,atx.Name);
attValue=get(objHandle,'Value');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attValue=LocValuetogglebutton(x,atx,index)

objHandle=getfield(x,atx.Name);
switch atx.Type
case 'LOGICAL'
   attValue=get(objHandle,'Value');
case 'ENUM'
   set(objHandle,'Value',0);
   set(objHandle(index),'Value',1);
   attValue=get(objHandle(index),'UserData');   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attValue=LocValuecheckbox(x,atx)
objHandle=getfield(x,atx.Name);
attValue=get(objHandle,'Value');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attValue=LocValuemultiedit(x,atx)

objHandle=getfield(x,atx.Name);
objValue=get(objHandle,'String');

switch atx.Type
case 'STRING'
   attValue=char(objValue);
case 'NUMBER'
   attValue=str2double(char(objValue));
   if isnan(attValue)
      attValue=atx.Current;
   end
case 'CELL';
   if iscell(objValue)
      attValue=objValue;
   else
      attValue=cellstr(objValue);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attValue=LocValueedit(x,atx)

objHandle=getfield(x,atx.Name);
editString=get(objHandle,'String');

[attValue,ok]=locstr2val(editString,atx.Type);
if ~ok
   attValue=atx.Current;
   set(objHandle,'String',locVal2Str(attValue));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [val,ok]=locstr2val(str,type)

val='';
ok=logical(1);
switch type
case 'STRING'
   val=str;
case 'NUMBER'
    if isempty(str)
        val=[];
        ok=logical(1);
    elseif (any(str==' ') | ...
            any(str=='[') | ...
            any(str==',') | ...
            any(str==';'))
        [val,ok] = str2num(str);
    else
        val=str2double(str);
        if isnan(val)
            ok=logical(0);
        end
    end
case 'LOGICAL'
   val=logical(str2double(str));
case 'CELL'
   try
      val=eval(str);
   catch
      ok=logical(0);
   end
end

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