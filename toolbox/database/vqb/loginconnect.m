function c = loginconnect(datasource)
%LOGINCONNECT Datasource connection.
%   LOGINCONNECT(DATASOURCE) Prompts for the datasource username and password.

%   Author(s): C.F.Garvin, 08-25-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.4 $   $Date: 2004/04/06 01:05:54 $

%Try connection with stored or no username or password
f = findobj('Tag','SQLDLG');
uobj = findobj(f,'Tag','UserNames');
pobj = findobj(f,'Tag','Passwords');
sobj = findobj(f,'Tag','sources');
sval = get(sobj,'Value');
uudata = get(uobj,'Userdata');
pudata = get(pobj,'Userdata');
if isempty(uudata)
  u = '';
  p = '';
else
  u = uudata{sval};
  p = pudata{sval};
end  
if isunix
  load datasource
  i = find(strcmp(datasource,srcs(:,1)));
  c = database(datasource,u,p,srcs{i,2},srcs{i,3});
else 
  c = database(datasource,u,p);
end
if ~strcmp(class(c.Handle),'double')
  return
end

%Build dialog to prompt for username and password
h = figure('Numbertitle','off','Menubar','none');

try
  pos = get(h,'Position');
catch
  querybuilder('sources')   %Trap double click of source list
  return
end

dfp = get(0,'DefaultFigurePosition');
mfp = [560 420];    %Reference width and height
bspc = mean([5/mfp(2)*dfp(4) 5/mfp(1)*dfp(3)]);
bhgt = 20/mfp(2) * dfp(4);
bfr = bhgt;
bwid = 80/mfp(1) * dfp(3);
set(h,'Name',['Datasource: ' datasource],'Tag','usernamepassworddialog',...
  'Position',[pos(1) pos(2) 2*bfr+3*bspc+2*bwid 2*bfr+5*bspc+4*bhgt])
pos = get(h,'Position');
rgt = pos(3);
top = pos(4);

uicontrol('Style','text','String','UserName:',...
  'Horizontalalignment','left',...
  'Position',[bspc+bfr top-bhgt-bspc-bfr bwid bhgt]);
uicontrol('Style','text','String','Password:',...
  'Horizontalalignment','left',...
  'Position',[bspc+bfr top-2*(bhgt+bspc)-bfr bwid bhgt]); 
uicontrol('Style','edit','Tag','username',...
  'Horizontalalignment','left','Backgroundcolor','white',...
  'Position',[2*bspc+bfr+bwid top-bhgt-bspc-bfr bwid bhgt]); 
uicontrol('Style','edit','Tag','password','Fontname','wingdings',...
  'Horizontalalignment','left','Backgroundcolor','white',...
  'Position',[2*bspc+bfr+bwid top-2*(bhgt+bspc)-bfr bwid bhgt]);
uicontrol('String','OK','Callback','uiresume',... 
  'Position',[bspc+bfr+bwid/2 top-3*(bhgt+bspc)-bfr-bspc bwid bhgt]);
uicontrol('String','Cancel','Callback','close',...
  'Position',[bspc+bfr+bwid/2 top-4*(bhgt+bspc)-bfr-bspc bwid bhgt]);
set(gcf,'Keypressfcn','uiresume')

uiwait;

%Retrieve username and password and try to make connection
u = get(findobj('Tag','username'),'String');
p = get(findobj('Tag','password'),'String');

if isunix     %Read configuration file
  c = database(datasource,u,p,srcs{i,2},srcs{i,3});
else
  c = database(datasource,u,p);
end

if ~strcmp(class(c.Handle),'double')
  if ~isempty(uobj)
    uudata{sval} = u;
    pudata{sval} = p;
    set(uobj,'Userdata',uudata)
    set(pobj,'Userdata',pudata)
  end
else
  errordlg(['Unable to connect to datasource ' datasource])
  set(findobj('Type','figure'),'Pointer','arrow')
end
close(findobj('Tag','usernamepassworddialog'));
