function Handles = dee4plti()
%DEE4PLTI Initialize the draw_spring figure window.
%   DEE4PLTI creates and initializes figure window for draw_spring.
 
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.14 $

% Revised Karen D. Gondoly 7-12-96

global Handles;

fh = figure;

thisblock=gcb;

set(fh,'Name','SPRING / MASS',...
        'NumberTitle','Off',...
        'Backingstore','Off',...
        'Units','Pixels',...
        'Position',[562 700 491 290]);

mh = uimenu('Label','Plot');
         uimenu(mh,'Label','Close',...
        'Callback',['if get_param(''',thisblock,''',''parameters''), set_param(''',thisblock,''',''parameters'',''0'');end; clear Handles; close']);

ah = axes;

axis([-1  10  -1.1  1.1]);
axis('off');
set(ah,'drawmode','fast','Clipping','off');

set(ah,'Units','Normal','Position',[.05 .05 .9 .9]);

% Draw the wall at x=0;
xf = [-.10 -.10];
yf = [-1 1];
ch = line(xf,yf);set(ch,'Visible','on','LineWidth',7,'Color',[.50 .50 .40]);

% mass1 is a block centered at x1
xm1 = [-.35, .35  .35 -.35]+3;
ym1 = [-.3  -.3   .3   .3];
m1h = patch(xm1,ym1,'b');set(m1h,'Visible','Off');

% mass2 is centered at x2
xm2 = [-.35, .35 .35 -.35]+6;
ym2 = [-.3 -.3 0.3 0.3];
m2h = patch(xm2,ym2,'c');set(m2h,'Visible','Off');


% draw spring #1
theta1 = asin((3-.35)/6);

pinX1 = sin(theta1)*[0 .5 1.5 2.5 3.5 4.5 5.5 6];
pinY1 = 0.5*cos(theta1)*[0 -1 1 -1 1 -1 1 0];

s1h=line(pinX1,pinY1);set(s1h,'Visible','Off','LineWidth',2);

% draw spring #2
theta2 = asin((2.3)/6);

pinX2 = sin(theta2)*[0 .5 1.5 2.5 3.5 4.5 5.5 6]+3.35;
pinY2 = 0.5*cos(theta2)*[0 -1 1 -1 1 -1 1 0];

s2h=line(pinX2,pinY2);set(s2h,'Visible','Off','LineWidth',2);

%draw the damper (two lines)
xd1 = [0.0 1.5];
xd2 = [1.5 3];
yd = [0.6 0.6];
d1h = line(xd1,yd);set(d1h,'Visible','Off','LineWidth',6,'color','red');
d2h = line(xd2,yd);set(d2h,'Visible','Off','LineWidth',12,'color',[.6 .25 .3]);


Handles = [m1h m2h s1h s2h d1h d2h];
set(fh,'UserData',Handles);
set(Handles,'Erasemode','background');
set_param(thisblock,'parameters','1');

