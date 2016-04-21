function p=rptsp(in)
%RPTSP - Report Generator Setup File Pointer
%   Points to a figure which has the setup file as
%   its user data and all components as uimenu
%   pointers.  Undo buffer is saved as a uicontextmenu.
%   RPTSP(RPTSETUPFILE) returns a pointer to the setup file object
%   RPTSP(RPTCP) returns a pointer to the component's setup file
%   RPTSP('clipboard') returns a pointer to the clipboard
%   RPTSP(H) where H is a figure handle designates H as a setfile pointer

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:28 $

if nargin<1
   in=[];
end


if isa(in,'rptsp')
   p=in;
elseif isa(in,'rptsetupfile')
   p=rptsp(in.ref.ID);
   in.ref.ID=p;
   set(p.h,'UserData',in);
else
   if isa(in,'rptcp')
      p.h=ParentFigure(in.h);
   elseif ishandle(in) & strcmp(get(in,'type'),'figure')
      p.h=in;
   elseif ischar(in) & in(1)=='c'
      p.h=LocClipboard;
   else
      p.h=LocMakeFigure;
   end
   p=class(p,'rptsp');
   superiorto('rptsetupfile','rptcomponent');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=LocClipboard;

clipTag='RPTGEN_COMPONENT_CLIPBOARD';

h=findobj(allchild(0),...
   'type','figure',...
   'tag',clipTag);
if ~isempty(h)
   h=h(1);
else
   %there is no clipboard - must create one
   h=LocMakeFigure;
   set(h,...
      'Name','Report Generator Component Clipboard',...
      'Tag',clipTag);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=LocMakeFigure

h=figure('BackingStore','off',...
   'CloseRequestFcn','set(gcbf,''Visible'',''off'');',...
   'HandleVisibility','off',...
   'HitTest','off',...
   'IntegerHandle','off',...
   'Interruptible','off',...
   'MenuBar','none',...
   'Name','Report Generator Setup File Hidden Figure',...
   'NumberTitle','off',...
   'Position',[100 100 50 50],...
   'Renderer','painters',...
   'RendererMode','manual',...
   'Tag','RPTGEN_SETFILE_FIGURE',...
   'Visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig=ParentFigure(obj)

if length(obj)>0
   obj=obj(1);
   while ishandle(obj) & ~strcmp(get(obj,'type'),'figure')
      obj=get(obj,'Parent');
   end
else
   obj=-1;
end

if ishandle(obj) & strcmp(get(obj,'type'),'figure')
   fig=obj;
else
   fig=LocMakeFigure;
end