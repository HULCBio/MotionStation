function f = error(this,str)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:15:11 $

w = 2.5;
h = 1;

oldunits = get(this,'Units');
set(this,'Units','inches');
p = get(this,'Position');
x = p(1) + p(3)/2 - w/2;
y = p(2) + p(4)/2 - h/2;

set(this,'Units',oldunits);

f = figure('WindowStyle','modal','Units','inches',...
           'Position',[x y w h],'Resize','off',...
           'NumberTitle','off','Menubar','none',...
           'Name','Error','IntegerHandle','off');

uicontrol('Style','text','String',str,...
          'Units','inches','Position',[w/2-2.3/2 h/2-0.2 2.3 0.6],...
          'HorizontalAlignment','center',...
          'BackgroundColor',get(f,'Color'));

uicontrol('Style','pushbutton','String','OK',...
          'Units','inches','Position',[w/2-0.25 h/2-0.4 0.5 0.3],...
          'HorizontalAlignment','center',...
          'Callback',{@closeErrorWindow f});

uiwait(f);

function closeErrorWindow(hSrc,event,window)

close(window)
