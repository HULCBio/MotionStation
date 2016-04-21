function xpctargetspy(flag)
% XPCTARGETSPY - xPC Target Spy GUI
%
%    XPCTARGETSPY opens the xPC Target Spy window which allows you to display
%    the output to the target screen on your host PC. The behavior of
%    XPCTARGETSPY depends on the value of property TargetScope of your current
%    xPC Environment. If TargetScope is disabled, the Text output is
%    continuously transferred every second to the host and displayed in the
%    figure. If TargetScope is enabled the Graphics screen transfer is NOT
%    continuously invoked. To initiate the update of the screen content you
%    have to left-click with the mouse into the Target Spy window. This is due
%    the much higher data volume to upload when the target graphics card is in
%    VGA mode.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.9.2.1 $ $Date: 2004/04/22 01:36:36 $

persistent lock;
global bar;

vgamap=[0,0,0;
        0,0,0.8;
        0,0.8,0;
        0,0.8,0.8;
        0.8,0,0;
        0.8,0,0.8;
        0.7,0.2,0.2;
        0.7,0.7,0.7;
        0.8,0.8,0.8;
        0,0,1;
        0,1,0;
        0,1,1;
        1,0,0;
        1,0,1;
        1,1,0;
        1,1,1];


if nargin==0

   lock=0;

  set(0,'ShowHiddenHandles','on');
  h_main=get(0, 'Children');
  opened=strmatch('Real-Time xPC Target Spy', get(h_main, 'Name'));
  if (length(opened) > 1)               % Typically not expected to happen
    error(sprintf(['More than one window open with the name ' ...
                   '''Real-Time xPC Target Spy'': please close these \n' ...
                   'and run xpctargetspy again.']));
  end
  set(0,'ShowHiddenHandles','off');

  if isempty(opened) & nargin == 0

    hfig=figure;

    set(hfig,'Name','Real-Time xPC Target Spy');
    set(hfig,'Units','pixels')
    set(hfig,'Position',[50,50,640,480])
    set(hfig,'MenuBar','none','NumberTitle','off');
    set(hfig,'ColorMap',vgamap);
    set(hfig,'Color',[0,0,0]);
    set(hfig,'CloseRequestFcn','xpctargetspy(-1)');
    userdata.mode=0;
    set(hfig,'UserData',userdata);
    set(hfig,'HandleVis','off');

    defxpctimer(5,1000,'xpctargetspy');

  end

  if ~isempty(opened) & nargin == 0
    figure(h_main(opened));
    if xpcgate('istgscope')
      draw_graph(h_main(opened));
    else
      draw_text(h_main(opened));
    end
  end

elseif flag==-2
   if ~lock
     figure(gcbf);
     lock=1;
     draw_graph(gcbf);
     lock=0;
   else
     figure(bar);
   end

elseif flag==-1
  stopxpctimer(5)
  set(0,'ShowHiddenHandles','on');
  delete(gcf);
  set(0,'ShowHiddenHandles','off');
elseif flag==5

  %stopxpctimer(5);

  set(0,'ShowHiddenHandles','on');
  h_main=get(0, 'Children');
  opened=strmatch('Real-Time xPC Target Spy', get(h_main, 'Name'));

  hfig=h_main(opened);
  userdata=get(hfig,'UserData');

  res=xpcgate('istgscope');

  if isempty(res)
    % currently in zero mode
    if userdata.mode==0
      figure(hfig);
      userdata.htext=create_text;
    end
    % currently in text mode
    if userdata.mode==1
    end

    % currently in graph mode
    if userdata.mode==2
      delete_graph(hfig);
      figure(hfig);
      userdata.htext=create_text;
    end
    userdata.mode=1;


  elseif res
    % currently in zero mode
    if userdata.mode==0
      userdata.himg=create_graph;
    end
    % currently in text mode
    if userdata.mode==1
      delete_text(hfig);
      figure(hfig);
      userdata.himg=create_graph;
    end
    % currently in graph mode
    if userdata.mode==2
      %update_graph(hfig);
    end
    userdata.mode=2;

  else

    % currently in zero mode
    if userdata.mode==0
      userdata.htext=create_text;
    end
    % currently in text mode
    if userdata.mode==1
      draw_text(hfig);
    end
    % currently in graph mode
    if userdata.mode==2
      delete_graph(hfig);
      figure(hfig);
      userdata.htext=create_text;
    end
    userdata.mode=1;

  end

  set(hfig,'UserData',userdata);

  set(0,'ShowHiddenHandles','off');

  defxpctimer(5,1000,'xpctargetspy');

end

function delete_text(hfig)

rows=25;
cols=80;

userdata=get(hfig,'UserData');
for i=1:rows
  delete(userdata.htext(i));
end


function delete_graph(hfig)

userdata=get(hfig,'UserData');
delete(userdata.himg);

function htext=create_text

rows=25;
cols=80;

htext=zeros(1,rows);
for i=1:rows
  htext(i)=uicontrol(...
      'Style','Text',...
      'String','',...
      'Units','Normalized',...
      'HorizontalAlignment','left',...
      'FontName','Fixedsys',...
      'Position',[0,1-1/rows-1/rows*(i-1),1,1/rows],...
      'ForegroundColor',[1,1,1],...
      'BackgroundColor',[0,0,0]);
end
s=char(32*ones(rows,cols));
s=reshape(s,cols,rows)';
for i=1:rows
  set(htext(i),'String',s(i,:));
end


function himg=create_graph

userdata=get(gcf,'Userdata');

set(gca,'Units','normalized');
set(gca,'Position',[0,0,1,1]);
set(gca,'Visible','off');
himg=image(zeros(480,640));
userdata.himg=himg;
set(himg,'ButtonDownFcn','xpctargetspy(-2)');
set(himg,'EraseMode','Background');
set(gcf,'UserData',userdata);
draw_graph(gcf);


function draw_text(hfig)

rows=25;
cols=80;

userdata=get(hfig,'UserData');

s = xpcgate('sendmsg','1020;',rows*cols);
s=reshape(s,cols,rows)';
for i=1:rows
  set(userdata.htext(i),'String',s(i,:));
end



function draw_graph(hfig)

global bar;

userdata=get(hfig,'UserData');

set(hfig,'Pointer','Watch');
posfig=get(hfig,'Position');
bar=waitbar(0,'Screen Upload...');
set(bar,'Units','Pixels');
posbar=get(bar,'Position');
xposbar=posfig(1)+posfig(3)/2-posbar(3)/2;
yposbar=posfig(2)+posfig(4)/2-posbar(4)/2;
posbar=[xposbar,yposbar,posbar(3:4)];
set(bar,'Position',posbar);
set(bar,'Name','Update Target Spy');
waitbar(0/100);

rows=480;
cols=640;
scr=[];
packsize=10;
start=0;

i=0;
scr=zeros(1,rows*cols);
xpcgate('settgscopeupdate',0);
while(rows>i)
  msg = ['069,',num2str(i),',',num2str(packsize), ';'];
  str = xpcgate('sendmsg', msg, packsize*cols);
  scr(i*cols+1:i*cols+packsize*cols)=str;
  i=i+packsize;
  waitbar(i/rows);
end;
xpcgate('settgscopeupdate',1);

imggg=reshape(abs(scr)-64,cols,rows)';
set(userdata.himg,'CData',imggg);
close(bar);
set(hfig,'Pointer','Arrow');

%% EOF xpctargetspy.m