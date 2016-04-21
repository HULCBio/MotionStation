function text = frame(str, pos, lightColor),
%TEXT = FRAME( STR, POS, LIGHTCOLOR )

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:57:54 $

x = pos(1);
y = pos(2);
w = pos(3);
h = pos(4);

if (nargin<3), lightColor = get(0,'defaultuicontrolbackground'); end;

dark = .666*lightColor;
white = 'white';

top = y+h-1;
right = x+w-1;

topDark = uicontrol('style','text','pos',[x top w-1 1],'background',dark);
topWhite = uicontrol('style','text','pos',[x+1 top-1 w-2 1],'background',white);

leftDark = uicontrol('style','text','pos',[x y+1 1 h-1],'background',dark);
leftWhite = uicontrol('style','text','pos',[x+1 y+2 1 h-3],'background',white);

bottomDark = uicontrol('style','text','pos',[x+1 y+1 w-1 1],'background',dark);
bottomWhite = uicontrol('style','text','pos',[x y w 1],'background',white);

rightDark = uicontrol('style','text','pos',[right-1 y+2 1 h-2],'background',dark);
rightWhite = uicontrol('style','text','pos',[right y+1 1 h-1],'background',white);

text = uicontrol('style','text','string',str,'vis','off','background',lightColor);
ext = get(text,'extent');
tw = ext(3);
th = ext(4);
set(text,'pos',[x+10 top-th/2-1 tw th],'vis','on','enable','inactive');
